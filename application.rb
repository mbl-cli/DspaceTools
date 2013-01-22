#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/basic_auth'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative "./environment"


class DSpaceCsvGui < Sinatra::Base
  mime_type :csv, 'application/csv'
  register Sinatra::Flash
  register Sinatra::BasicAuth
  helpers Sinatra::RedirectWithFlash
  
  enable :sessions

  use Rack::Timeout
  Rack::Timeout.timeout = 9_000_000

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


  ###########################################################################
  #  API
  ###########################################################################
  def rest_request(params)
    current_user = DSpaceCSV.api_key_authorization(params, request.path) || DSpaceCSV.password_authorization(params)
    if current_user
      if params["format"] == "xml"
        content_type 'text/xml', :charset => 'utf-8'
      elsif params["format"] == "json"
        content_type 'application/json', :charset => 'utf-8'
      else
        content_type 'text/plain', :charset => 'utf-8'
      end
      RestClient.get(DSpaceCSV::Conf.dspace_repo + request.fullpath)
    else
      yield
    end
  end

  get '/rest/users.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email/password, or API key/digest pair?\n"]) }
  end

  get '/rest/users/:id.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end

  get '/rest/items.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end
  
  get '/rest/items/:id.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end

  get '/rest/collections.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end
  
  get '/rest/collections/:id.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end

  get '/rest/communities/:id.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end

  get '/rest/communities.:format' do
    rest_request(params) { throw(:halt, [401, "Not authorized. Did you submit correct email and password?\n"]) }
  end
  
  get '/rest/handle/:num1/:num2.:format' do
    params["handle"] = "%s/%s" % [params["num1"], params["num2"]]
    handle = Handle.where(:handle => params["handle"]).first
    path = handle ? handle.path : nil
    if path
      redirect(request.fullpath.gsub(request.path_info, "%s.%s" % [path, params["format"]]), 303)
    else
      throw(:halt, [404, "Unknown handle %s" % params["handle"]])
    end
  end
  
  protect  do
    get '/' do
        session[:current_user] = Eperson.where(:email => auth.credentials.first).first
        haml :index
    end

    get '/formatting-rules' do
        erb :rules
    end

    get '/stsrepository-instructions' do
        erb :sts
    end

    get '/extra-help' do
        erb :help
    end

    get 'template.csv' do
        content_type :csv
        send_file 'template.csv'
    end

    post '/upload' do
      begin
        DSpaceCSV::Uploader.clean(1)
        u = DSpaceCSV::Uploader.new(params)
        e = DSpaceCSV::Expander.new(u)
        t = DSpaceCSV::Transformer.new(e)
        if t.errors.empty?
          session[:path] = t.path
          session[:collection_id] = params["collection_id"]
          redirect '/upload_result', :warning => t.warnings[0]
        else
          redirect "/", :error => t.errors.join("<br/>")
        end
      rescue DSpaceCSV::CsvError => e
        redirect "/", :error => e.message 
      rescue DSpaceCSV::UploadError => e
        redirect "/", :error => e.message 
      end
    end

    post '/submit' do
      dscsv= DSpaceCSV.new(session[:path], session[:collection_id], session[:current_user])
      @map_file = dscsv.submit
      redirect '/upload_finished?map_file=' + URI.encode(@map_file)
    end

    get '/upload_result' do
      haml :upload_result
    end

    get '/upload_finished' do
      @map_file = params["map_file"]
      haml :upload_finished
    end
  end

  authorize do |username, password|
    !!DSpaceCSV.password_authorization({"email" => username, "password" => password})
  end

  run! if app_file == $0

end

