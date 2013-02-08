class Community < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'community', :primary_key => 'community_id')

  def self.find(id_num)
    self.find_id(:community_id => id_num)
  end
end

