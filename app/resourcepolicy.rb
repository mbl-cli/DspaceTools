class Resourcepolicy < DspaceTools::DspaceDb::Base
  include Resource
  self.table_params(:table_name => 'resourcepolicy', :primary_key => 'policy_id')
  
  def action
    DspaceTools::ACTION[action_id]
  end

  def group
    Group.find(epersongroup_id)
  end

  def eperson
    Eperson.find(eperson_id)
  end

end

