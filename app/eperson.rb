class Eperson < ActiveRecord::Base
  self.table_name = 'eperson'
  self.primary_key = 'eperson_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :groups, :through => :eperson_groups
end
