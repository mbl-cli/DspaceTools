class Group < ActiveRecord::Base
  self.table_name = 'epersongroup'
  self.primary_key = 'eperson_group_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :epersons, :through => :eperson_groups
end
