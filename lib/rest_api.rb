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
    return true if @request_user && @request_user.is_admin?
    permissions = auth.select do |r|
      return true if  DSpaceCSV::ACCESS_ACTIONS.include?(r.action_id) && (r.epersongroup_id && r.epersongroup_id == 0)
      if @request_user
        return true if DSpaceCSV::ACCESS_ACTIONS.include?(r.action_id) && (r.eperson_id && r.eperson_id == @request_user.eperson_id)
        return true if DSpaceCSV::ACCESS_ACTIONS.include?(r.action_id) && (r.epersongroup_id && @request_user.groups.map(&:eperson_group_id).include?(r.epersongroup_id))
      end
    end
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
    return response if @request_user && @request_user.is_admin?
    @doc = Nokogiri.parse(response.body)
    process_restrictions('//communities', Community)
    process_restrictions('//communityentityid', Community)
    process_restrictions('//collections', Collection)
    process_restrictions('//collectionentityid', Collection)
    process_restrictions('//items', Item)
    process_restrictions('//itementityid', Item)
    process_restrictions('//bitstream', Bitstream)
    # process_restrictions('//bitstreamentity', Bitstream)
    # process_restrictions('//bitstreamentityid', Bitstream)
    @doc.to_xml
  end

  def process_restrictions(an_xpath, klass)
    entities = @doc.xpath(an_xpath).inject({}) do |res, node|
      id = node.xpath('id').text
      id = node.xpath('entityId').text if id.empty?
      unless id.empty?
        id = id.to_i
        res[id] ? res[id][:nodes] << node : res[id] = { nodes: [node], remove: true }
      end
      res
    end
    return if entities.empty?
    permissions = Resourcepolicy.where("resource_type_id = %s and action_id in (%s) and (eperson_id is not null or epersongroup_id is not null) and resource_id in (%s)" % [klass.resource_number, DSpaceCSV::ACCESS_ACTIONS.join(","), entities.keys.join(",")] )
    permissions.each do |r|
      auth_group = auth_user = false
      if r.epersongroup_id
        auth_group = r.epersongroup_id == 0 || (@request_user && @request_user.groups.map(&:eperson_group_id).include?(r.epersongroup_id))
      end
      if @request_user && r.eperson_id
        auth_user = @request_user.id == r.eperson_id
      end
      entities[r.resource_id][:remove] = false if (auth_group || auth_user)
    end
    entities.each do |id, value|
      if value[:remove]
        value[:nodes].each {|node| node.remove}
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
