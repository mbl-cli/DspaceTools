require 'rack/timeout'
require "zen-grids"
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative './environment'

class SassEngine < Sinatra::Base
  
  set :views,   File.join(File.dirname(__FILE__), 'app', 'css', 'sass')
  
  get '/css/:filename.css' do
    scss params[:filename].to_sym
  end
  
end

class DspaceToolsUi < Sinatra::Base
  include RestApi
  
  configure do
    use SassEngine
    mime_type :csv, 'application/csv'
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash
    Compass.add_project_configuration(File.join(File.dirname(__FILE__),  
                                                'config', 
                                                'compass_config.rb'))    

    use Rack::MethodOverride
    use Rack::Timeout
    Rack::Timeout.timeout = 9_000_000

    use Rack::Session::Cookie, :secret => DspaceTools::Conf.session_secret
    # use Rack::Session::Pool, :secret => DspaceTools::Conf.session_secret
  end

  helpers do 
    include Sinatra::RedirectWithFlash
    include Rack::Utils

    alias_method :h, :escape_html
    
    def get_dir_structure(dir)
      res = []
      Dir.entries(dir).each do |e|
        if e.match /^[\d]{4}/
          res << [e, get_dir_content(File.join(dir, e))]
        end
      end
      res
    end

    def api_keys
      @api_keys ||= ApiKey.where(eperson_id: session[:current_user].eperson_id)
    end

    private

    def get_dir_content(dir)
      res = []
      Dir.entries(dir).each do |e|
        next if e.match /^[\.]{1,2}$/
        res << [e, '']
        if ['contents', 'dublin_core.xml'].include?(e)
          res[-1][1] = open(File.join(dir, e), "r:utf-8").read
        end
      end
      res
    end
  end

end

