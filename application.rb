#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative "./environment"


class DSpaceCsvUi < Sinatra::Base
  include RestApi
  mime_type :csv, 'application/csv'
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash
  
  enable :sessions

  use Rack::MethodOverride
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


  get '/rest/users.:format' do
    rest_request(params) 
  end

  get '/rest/users/:id.:format' do
    rest_request(params)
  end

  get '/rest/items.:format' do
    rest_request(params)
  end
  
  get '/rest/items/:id.:format' do
    rest_request(params)
  end

  get '/rest/collections.:format' do
    rest_request(params) 
  end
  
  get '/rest/collections/:id.:format' do
    rest_request(params)
  end

  get '/rest/communities/:id.:format' do
    rest_request(params)
  end

  get '/rest/communities.:format' do
    rest_request(params) 
  end
  
  get '/rest/harvest.:format' do
    rest_request(params)
  end
  
  get '/rest/harvest/:id.:format' do
    rest_request(params)
  end

  get '/rest/bitstream/:id.:format' do
    rest_request(params)
  end
  
  get '/rest/handle/:num1/:num2.:format' do
    params["handle"] = "%s/%s" % [params["num1"], params["num2"]]
    handle = Handle.where(:handle => params["handle"]).first
    path = handle ? handle.path : nil
    if path
      redirect(handle.fullpath(request.fullpath, request.path_info), 303)
    else
      throw(:halt, [404, "Unknown handle %s" % params["handle"]])
    end
  end

  #takes handles in the following format /handle.xml?handle=http://hdl.handle.net/123/123
  get '/rest/handle.:format' do
    handle = params[:handle] ? Handle.where(:handle => params["handle"].gsub("http://hdl.handle.net/", '')).first : nil
    path = handle ? handle.path : nil
    if path
      redirect(handle.fullpath(request.fullpath, request.path_info), 303)
    else
      throw(:halt, [404, "Unknown handle %s" % params["handle"]])
    end
  end

  get '/rest/authentication_test.:format' do
    rest_request(params)
  end

  get '/bitstream/handle/:num1/:num2/:filename' do
    path = request.fullpath
    RestClient.get(DSpaceCSV::Conf.dspace_repo + path)
  end
 
  before %r@^(?!/(login|rest|bitstream))@ do
    session[:previous_location] = (request.fullpath == "/login" ? "/" : request.fullpath )
    redirect "/login" unless session[:current_user] and session[:current_user].class.to_s == "Eperson"
  end

  get '/' do
    haml :index
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    eperson = DSpaceCSV.password_authorization({ "email" => params[:email], "password" => params[:password] })
    session[:current_user] = eperson if eperson
    redirect session[:previous_location] || "/" 
  end

  get "/logout" do
    session[:current_user] = nil
    redirect "/login"
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

  get '/api_keys' do 
    haml :api_keys
  end

  post '/api_keys' do
    ApiKey.create(:eperson_id => session[:current_user].eperson_id, :app_name => params[:app_name], :public_key => ApiKey.get_public_key, :private_key => ApiKey.get_private_key)
    redirect "/api_keys"
  end

  delete '/api_keys' do
    key = ApiKey.where(:public_key => params[:public_key]).first
    key.destroy if key
    redirect "/api_keys"
  end


  run! if app_file == $0

end

