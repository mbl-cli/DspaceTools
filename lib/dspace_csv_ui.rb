class DSpaceCsvUi < Sinatra::Base

  def rest_request(params)
    get_content_type(params)
    @request_user = DSpaceCSV.api_key_authorization(params, request.path) || DSpaceCSV.password_authorization(params)
    if request.path.match 'authentication_test'
      authentication_worked(params["format"]) || bad_authentication
    else
      handle_request
    end
  end

  private

  def handle_request
    if params[:id] && params[:id].to_i.is_a?(Fixnum)
      handle_single_request
    else
      #handle_bulk_request
    end
  end

  def handle_single_request
    can_access_the_entity? ? perform_request : bad_authentication
  end

  def can_access_the_entity?
    resource_path = request.path.split("/")[2]
    resource_number = DSpaceCSV::RESOURCE_TYPE_PATHS[resource_path]
    auth = Resourcepolicy.where(:resource_type_id => resource_number, :resource_id => params[:id])
    entity_public?(auth) || entity_authorized?(auth)
  end

  def entity_public?(auth)
    auth.select do |row|
      row.action_id == DSpaceCSV::ACTION_TYPE["READ"] && (row.eperson_id || row.epersongroup_id > 0) 
    end.empty?
  end

  def entity_authorized?(auth)
    false
  end

  def perform_request
    begin
      response = RestClient.get(DSpaceCSV::Conf.dspace_repo + request.fullpath)
      filter_response(response)
    rescue RestClient::Exception => e
      not_found
    end
  end

  def filter_response(response)
    response
  end

  def get_content_type(params)
    if params["format"] == "xml"
      content_type 'text/xml', :charset => 'utf-8'
    elsif params["format"] == "json"
      content_type 'application/json', :charset => 'utf-8'
    else
      content_type 'text/plain', :charset => 'utf-8'
    end
  end

  def authentication_worked(format)
    return nil unless @request_user
    if format == "xml"
      @request_user.to_xml
    else 
      @request_user.to_json
    end
  end

  def bad_authentication 
    throw(:halt, [401, "Not authorized. Did you submit correct email/password, or API key/digest pair?\n"]) 
  end

  def not_found
    throw(:halt, [404, "Resource is not found"])
  end

end
