module Resource

  def resource_type
    DspaceTools::RESOURCE_TYPE[resource_type_id][:klass]
  end

  def resource
    return nil unless resource_id
    resource_type.find(resource_id)
  end

end
