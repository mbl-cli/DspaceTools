class DspaceToolsUi < Sinatra::Base

  before %r@^(?!/(login|rest|bitstream))@ do
    session[:previous_location] = request.fullpath
    redirect "/login" unless session[:current_user] and
                             session[:current_user].class.to_s == "Eperson"
  end

  get '/' do
    haml :index
  end

  get "/login" do
    haml :login
  end

  post "/login" do
    eperson = DspaceTools.password_authorization({ email: params[:email], 
                                                 password: params[:password] })
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
      DspaceTools::Uploader.clean(1)
      u = DspaceTools::Uploader.new(params)
      e = DspaceTools::Expander.new(u)
      t = DspaceTools::Transformer.new(e)
      if t.errors.empty?
        session[:path] = t.path
        session[:collection_id] = params["collection_id"]
        redirect '/upload_result', :warning => t.warnings[0]
      else
        redirect "/", :error => t.errors.join("<br/>")
      end
    rescue DspaceTools::CsvError => e
      redirect "/", :error => e.message 
    rescue DspaceTools::UploadError => e
      redirect "/", :error => e.message 
    end
  end

  post '/submit' do
    dscsv= DspaceTools.new(session[:path], 
                           session[:collection_id], 
                           session[:current_user])
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
    ApiKey.create(eperson_id:  session[:current_user].eperson_id,
                  app_name:    params[:app_name],
                  public_key:  ApiKey.get_public_key,
                  private_key: ApiKey.get_private_key)
    redirect "/api_keys"
  end

  delete '/api_keys' do
    key = ApiKey.where(:public_key => params[:public_key]).first
    key.destroy if key
    redirect "/api_keys"
  end

end
