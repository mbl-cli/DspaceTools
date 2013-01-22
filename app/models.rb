class ApiKey < ActiveRecord::Base
  belongs_to :eperson
end

class Eperson < DSpaceCSV::DspaceDb::Base
  self.table_name = 'eperson'
  self.primary_key = 'eperson_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :groups, :through => :eperson_groups
  has_many :api_keys

  private

  def password; end
end

class EpersonGroup < DSpaceCSV::DspaceDb::Base
  self.table_name = 'epersongroup2eperson'
  belongs_to :group, :class_name => 'Group', :foreign_key => 'eperson_group_id'
  belongs_to :eperson, :class_name => 'Eperson', :foreign_key => 'eperson_id'
end

class Group < DSpaceCSV::DspaceDb::Base
  self.table_name = 'epersongroup'
  self.primary_key = 'eperson_group_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup', :foreign_key => 'eperson_group_id'
  has_many :epersons, :through => :eperson_groups
end

class Handle < DSpaceCSV::DspaceDb::Base
  self.table_name = 'handle'
  self.primary_key = 'handle_id'

  def path
    return nil unless resource_id
    "/rest/%s%s" % [DSpaceCSV::RESOURCE_TYPE[resource_type_id][:rest_path], resource_id] 
  end
end
