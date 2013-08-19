class DspaceToolsUi < Sinatra::Base

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

  get '/rest/bitstream/:id' do
    rest_request(params)
  end

  get '/rest/items/updates.:format' do
    rest_request(params)
  end

  get '/rest/handle/:num1/:num2.:format' do
    params["handle"] = "%s/%s" % [params["num1"], params["num2"]]
    handle = Handle.where(:handle => params["handle"]).first
    path = handle ? handle.path : nil
    if path
      redirect(handle.fullpath(request.fullpath, request.path_info), 303)
    else
      not_found
    end
  end

  # takes handles in the following format
  # /handle.xml?handle=http://hdl.handle.net/123/123
  get '/rest/handle.:format' do
    handle = params[:handle] ?  Handle.where(:handle => params["handle"].
                   gsub("http://hdl.handle.net/", '')).first : nil
    path = handle ? handle.path : nil
    if path
      redirect(handle.fullpath(request.fullpath, request.path_info), 303)
    else
      not_found
    end
  end

  get '/rest/authentication_test.:format' do
    rest_request(params)
  end

  get '/bitstream/handle/:num1/:num2/:filename' do
    path = request.fullpath
    RestClient.get(DspaceTools::Conf.dspace_repo + path)
  end

end
