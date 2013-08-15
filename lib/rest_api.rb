module RestApi

  def rest_request(params)
    get_content_type(params)
    @request_user = DspaceTools.api_key_authorization(params, request.path) ||
      DspaceTools.password_authorization(params)
    if request.path.match 'authentication_test'
      authentication_worked(params['format']) || bad_authentication
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
    resource_path = request.path.split('/')[2]
    resource_number = DspaceTools::RESOURCE_TYPE_PATHS[resource_path]
    auth = Resourcepolicy.where(resource_type_id: resource_number,
                                resource_id: params[:id])
    entity_authorized?(auth)
  end

  def entity_authorized?(auth)
    return true if @request_user && @request_user.admin?
    permissions = auth.select do |r|
      return true if  DspaceTools::ACCESS_ACTIONS.include?(r.action_id) &&
        (r.epersongroup_id && r.epersongroup_id == 0)
      if @request_user
        return true if DspaceTools::ACCESS_ACTIONS.include?(r.action_id) &&
          (r.eperson_id && r.eperson_id == @request_user.eperson_id)
        return true if DspaceTools::ACCESS_ACTIONS.include?(r.action_id) &&
          (r.epersongroup_id && @request_user.groups.map(&:eperson_group_id).
           include?(r.epersongroup_id))
      end
    end
    false
  end

  def is_bitstream_file?
    !params['format'] && request.fullpath.match('bitstream')
  end

  def bitstream_file
    bts = Bitstream.find(params['id'])
    headers(
    'Content-Type'        => bts.mime || 'application/octet-stream',
    'Content-length'      => bts.size_bytes || 0,
    'Content-Disposition' => "attachment; filename=#{bts.name}")
    open(bts.path)
  end

  def perform_request
    return bitstream_file if is_bitstream_file?
    begin
      response = RestClient.get(DspaceTools::Conf.dspace_repo +
                                request.fullpath)
      filter_response(response)
    rescue RestClient::Exception => e
      code = e.message.to_i
      if code != 0
        throw(:halt, [e.message.to_i, e.message])
      else
        throw(:halt, [500, 'Server problem'])
      end
    end
  end

  def filter_response(response)
    return response if @request_user && @request_user.admin?
    @doc = Nokogiri.parse(response.body)
    [['//communities', Community],
     ['//communityentityid', Community], ['//collections', Collection],
     ['//collectionentityid', Collection], ['//items', Item],
     ['//itementityid', Item],
     ['//bitstream', Bitstream], ['//bitstreamentity', Bitstream],
     ['//bitstreamentityid', Bitstream]].
      each { |path, klass| filter(path, klass) }
    @doc.to_xml
  end

  def filter(an_xpath, klass)
    entities = get_entities(an_xpath)
    return if entities.empty?
    permissions = Resourcepolicy.where("resource_type_id = %s
                                        and action_id in (%s)
                                        and (eperson_id is not null
                                        or epersongroup_id is not null)
                                        and resource_id in (%s)" %
      [klass.resource_number,
       DspaceTools::ACCESS_ACTIONS.join(','),
       entities.keys.join(',')] )
    process_permissions(permissions, entities)
    remove_unauthorized_entities(entities)
  end

  def remove_unauthorized_entities(entities)
    entities.each do |id, value|
      if value[:remove]
        value[:nodes].each {|node| node.remove}
      end
    end
  end

  def process_permissions(permissions, entities)
    permissions.each do |r|
      auth_group = auth_user = false
      if r.epersongroup_id
        auth_group = r.epersongroup_id == 0 ||
          (@request_user &&
           @request_user.groups.map(&:eperson_group_id).
             include?(r.epersongroup_id))
      end
      if @request_user && r.eperson_id
        auth_user = @request_user.id == r.eperson_id
      end
      entities[r.resource_id][:remove] = false if (auth_group || auth_user)
    end
  end

  def get_entities(an_xpath)
    @doc.xpath(an_xpath).inject({}) do |res, node|
      id = node.xpath('id').text
      id = node.xpath('entityId').text if id.empty?
      unless id.empty?
        id = id.to_i
        res[id] ? res[id][:nodes] << node :
          res[id] = { nodes: [node], remove: true }
      end
      res
    end
  end

  def get_content_type(params)
    if params['format'] == 'xml'
      content_type 'text/xml', charset: 'utf-8'
    elsif params['format'] == 'json'
      content_type 'application/json', charset: 'utf-8'
    else
      content_type 'text/plain', charset: 'utf-8'
    end
  end

  def authentication_worked(format)
    return nil unless @request_user
    if format == 'xml'
      @request_user.to_xml
    else
      @request_user.to_json
    end
  end

  def bad_authentication
    throw(:halt, [401,
                  'Not authorized. ' +
                  'Did you submit correct email/password, ' +
                  'or API key/digest pair?'])
  end

  def not_found
    throw(:halt, [404, "Unknown handle %s" % params['handle']])
  end

end
