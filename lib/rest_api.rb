module RestApi

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
      handle_bulk_request
    end
  end

  def handle_single_request
    can_access_the_entity? ? perform_request : bad_authentication
  end

  def handle_bulk_request
    perform_request
  end

  def can_access_the_entity?
    resource_path = request.path.split("/")[2]
    resource_number = DSpaceCSV::RESOURCE_TYPE_PATHS[resource_path]
    auth = Resourcepolicy.where(:resource_type_id => resource_number, :resource_id => params[:id])
    entity_authorized?(auth)
  end

  def entity_authorized?(auth)
    restrictions = auth.select do |r|
      r.action_id == DSpaceCSV::ACTION_TYPE["READ"] && (r.eperson_id || (r.epersongroup_id && r.epersongroup_id > 0)) 
    end
    return true if restrictions.empty?
    return false unless @request_user
    authorizations = restrictions.select do |r|
      auth_group = @request_user.groups.map(&:eperson_group_id).include?(r.epersongroup_id)
      auth_user = @request_user.id == r.eperson_id
      auth_group || auth_user
    end
    authorizations.size > 0
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
    @doc = Nokogiri.parse(response.body)
    process_restrictions('//communities', Community)
    process_restrictions('//communityentityid', Community)
    process_restrictions('//collections', Collection)
    process_restrictions('//collectionentityid', Collection)
    process_restrictions('//items', Item)
    process_restrictions('//itementityid', Item)
    @doc.to_xml
  end

  def process_restrictions(an_xpath, klass)
    entities = @doc.xpath(an_xpath).inject({}) do |res, node|
      id = node.xpath('id').text.to_i
      id = node.xpath('entityId') unless id
      res[id] ? res[id] << node : res[id] = [node]
      res
    end
    restrictions = []
    unless entities.empty?
      restrictions = Resourcepolicy.where("resource_type_id = %s and action_id = %s and (eperson_id > 0 or epersongroup_id > 0) and resource_id in (%s)" % [klass.resource_number, DSpaceCSV::ACTION_TYPE["READ"], entities.keys.join(",")] )
    end
    if restrictions
      to_remove = {}
      restrictions.each do |r|
        to_remove[r.resource_id] = true unless to_remove[r.resource_id]
        auth_group = @request_user && @request_user.groups.map(&:eperson_group_id).include?(r.epersongroup_id)
        auth_user = @request_user && @request_user.id == r.eperson_id
        to_remove[r.resource_id] = false if (auth_group || auth_user)
      end
      to_remove.each do |id, remove|
        if remove
          entities[id].each {|node| node.remove}
        end
      end 
    end
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
    throw(:halt, [401, "Not authorized. Did you submit correct email/password, or API key/digest pair?"]) 
  end

  def not_found
    throw(:halt, [404, "Resource is not found"])
  end

end
