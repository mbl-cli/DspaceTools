#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative "./environment"

class DspaceToolsUi < Sinatra::Base
  include RestApi
  
  configure do
    mime_type :csv, 'application/csv'
    register Sinatra::Flash
    helpers Sinatra::RedirectWithFlash
    

    use Rack::MethodOverride
    use Rack::Timeout
    Rack::Timeout.timeout = 9_000_000

    enable :sessions
    set :session_secret, DspaceTools::Conf.session_secret
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
      @api_keys ||= ApiKey.where(:eperson_id => session[:current_user].eperson_id)
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

  run! if app_file == $0

end

