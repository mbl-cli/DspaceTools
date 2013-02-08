class Handle < DspaceTools::DspaceDb::Base
  include Resource
  self.table_params(:table_name => 'handle', :primary_key => 'handle_id')

  def path
    return nil unless resource_id
    "/rest/%s%s" % [DspaceTools::RESOURCE_TYPE[resource_type_id][:rest_path], resource_id] 
  end

  def fullpath(original_fullpath, original_path)
    format = original_path.split(".")[-1]
    path_with_format = "%s.%s" % [path, format]
    public_key_match = original_fullpath.match(/api_key=([^&]+)(&|$)/)
    res = original_fullpath.gsub(original_path, path_with_format)
    if public_key_match
      ak = ApiKey.where(:public_key => public_key_match[1]).first
      digest = res.match(/(api_digest=)([^&]+)(&|$)/)
      if digest &&  ak.valid_digest?(digest[2], original_path)
        res.gsub!(/(api_digest=)([^&])+(&|$)/, '\1' + ak.digest(path_with_format) + '\3')
      end
    end
    res
  end
end

