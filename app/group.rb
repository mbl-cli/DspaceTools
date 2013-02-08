class Group < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'epersongroup', :primary_key => 'eperson_group_id')
  has_many :eperson_groups, :class_name => 'EpersonGroup', :foreign_key => 'eperson_group_id'
  has_many :epersons, :through => :eperson_groups

  def self.find(id_num)
    return AnonymousGroup.new if id_num == 0
    self.find_id(:eperson_group_id => id_num)
  end
end

