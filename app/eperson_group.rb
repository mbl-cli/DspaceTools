class EpersonGroup < ActiveRecord::Base
  self.table_name = 'epersongroup2eperson'
  belongs_to :group, :class_name => 'Group', :foreign_key => 'eperson_group_id'
  belongs_to :eperson, :class_name => 'Eperson', :foreign_key => 'eperson_id'
end
