class DspaceToolsUi < Sinatra::Base
  def user_collections(usr)
    res = nil
    if usr.admin?
      res = Collection.all
    else
      atype = DspaceTools::ACTION_TYPE
      groups = usr.groups.map(&:id).join(',')
      write_actions = [atype['WRITE'], 
                       atype['ADD'], 
                       atype['ADMIN']].join(',')
      q = "resource_type_id = %s 
          and (eperson_id = %s or epersongroup_id in (%s))
          and action_id in (%s)"
      q_params = [Collection.resource_number,
                  usr.id,
                  groups,
                  write_actions] 
      res = Resourcepolicy.select(:resource_id).
                     where(q % q_params).
                     map { |r| Collection.find(r.resource_id) }
    end
    res.sort_by(&:name)
  end

  def current_user
    usr_id = session[:current_user_id]
    @current_user ||= (usr_id ? Eperson.find(usr_id) : nil)
  end

  before %r@^(?!/(login|logout|css|rest|bitstream|favicon))@ do
    session[:previous_location] = request.fullpath
    redirect '/login' unless session[:current_user_id] &&
                             session[:current_user_id].to_i > 0
  end
  
  get '/css/:filename.css' do
    scss :"sass/#{params[:filename]}"
  end

  get '/' do
    haml :index
  end

  get '/login' do
    haml :login
  end

  post '/login' do
    eperson = DspaceTools.password_authorization(email: params[:email], 
                                                 password: params[:password])
    session[:current_user_id] = eperson.id if eperson
    redirect session[:previous_location] || '/' 
  end

  get '/logout' do
    session[:current_user_id] = nil
    redirect '/login'
  end

  get '/bulk_upload' do
    usr = current_user
    @collections = user_collections(usr)
    @dropbox = DspaceTools::Dropbox.new
    haml :bulk_upload
  end

  get '/formatting-rules' do
      haml :rules
  end

  get 'template.csv' do
      content_type :csv
      send_file 'template.csv'
  end

  post '/upload' do
    begin
      DspaceTools::Uploader.clean(1)
      u = DspaceTools::Uploader.new(params)
      t = DspaceTools::Transformer.new(u)
      if t.errors.empty?
        session[:path] = t.path
        session[:collection_id] = params['collection_id']
        redirect '/upload_result', warning: t.warnings[0]
      else
        redirect '/bulk_upload', error: t.errors.join('<br/>')
      end
    rescue DspaceTools::CsvError => e
      redirect '/bulk_upload', error: e.message 
    rescue DspaceTools::UploadError => e
      redirect '/bulk_upload', error: e.message 
    end
  end

  post '/submit' do
    begin
      bu = DspaceTools::BulkUploader.new(session[:path], 
                             session[:collection_id], 
                             current_user)
      @map_file = bu.submit
      redirect '/upload_finished?map_file=' + ::URI.encode(@map_file)
    rescue DspaceTools::ImportError => e
      redirect '/upload_result', error: e.message
    end
  end

  get '/upload_result' do
    haml :upload_result
  end

  get '/upload_finished' do
    @map_file = params['map_file']
    haml :upload_finished
  end

  get '/api_keys' do 
    haml :api_keys
  end

  post '/api_keys' do
    ApiKey.create(eperson_id:  session[:current_user_id],
                  app_name:    params[:app_name],
                  public_key:  ApiKey.get_public_key,
                  private_key: ApiKey.get_private_key)
    redirect '/api_keys'
  end

  delete '/api_keys' do
    key = ApiKey.where(public_key: params[:public_key]).first
    key.destroy if key
    redirect '/api_keys'
  end

  get '/api_examples' do
    haml :api_examples
  end

end
