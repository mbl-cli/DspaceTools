class Eperson < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'eperson', :primary_key => 'eperson_id')
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :groups, :through => :eperson_groups
  has_many :api_keys

  def self.find(id_num)
    self.find_id(:eperson_id => id_num)
  end

  def is_admin?
    groups.include?(Group.find(1))
  end

  private

  def password; end
end

