class DspaceTools::DspaceDb::Base
  def self.resource_number
    DspaceTools::RESOURCE_TYPE_IDS[self]
  end

  def self.find_id(hsh = {})
    id = hsh.values[0].to_i
    return nil unless id.is_a?(Fixnum) || id.to_s == hsh.values[0]
    hsh.values[0] = id
    self.where(hsh).first
  end

  def self.table_params(hsh)
    self.table_name = hsh[:table_name] if hsh[:table_name]
    self.primary_key = hsh[:primary_key] if hsh[:primary_key]
  end
end

module Resource

  def resource_type
    DspaceTools::RESOURCE_TYPE[resource_type_id][:klass]
  end

  def resource
    return nil unless resource_id
    resource_type.find(resource_id)
  end

end
