class Handle < ActiveRecord::Base
  self.table_name = 'handle'
  self.primary_key = 'handle_id'

  def path
    return nil unless resource_id
    "/rest/%s%s" % [DSpaceCSV::RESOURCE_TYPE[resource_type_id][:rest_path], resource_id] 
  end
end

