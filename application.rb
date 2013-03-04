#!/usr/bin/env ruby

require 'zen-grids'
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative 'environment'
require_relative 'routes'
require_relative 'routes_api'

class DspaceToolsUi < Sinatra::Base
  include RestApi
  
  configure do
    mime_type :csv, 'application/csv'
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash
    Compass.add_project_configuration(File.join(File.dirname(__FILE__),  
                                                'config', 

                                                'compass.config'))    

    # Compass.configuration do |config|
    #   config.project_path = File.join(File.dirname(__FILE__), 'public')
    # end
    use Rack::MethodOverride
    use Rack::Timeout
    Rack::Timeout.timeout = 9_000_000

    use Rack::Session::Cookie, :secret => DspaceTools::Conf.session_secret

    set :scss, Compass.sass_engine_options
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
      @api_keys ||= ApiKey.where(eperson_id: session[:current_user_id])
    end

    def shorten(a_string, chars_num)
      a_string.gsub!(/\s+/, ' ')
      res = a_string[0..chars_num]
      if res != a_string
        res.gsub!(/\s[^\s]+$/, '...')
      end
      res
    end

    def api_url(resource, api_key, url_params = nil)
      path = "/rest/%s.xml" % resource
      params_str = "?"
      if api_key
        params_str += "api_key=" 
        params_str += "%s&api_digest=" % api_key.public_key
        params_str += api_key.digest(path)
      end
      params_str += "&%s" % url_params if url_params
      res = path
      res += params_str unless params_str == "?"
      res.gsub(%r|[/]+|, '/').gsub(/[&]+/, '&').gsub("?&", "?")
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

run DspaceToolsUi.new if DspaceToolsUi.app_file == $0
