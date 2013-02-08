class Bitstream < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'bitstream', :primary_key => 'bitstream_id')
  
  def self.resource_number
    0
  end

  def self.find(id_num)
    self.find_id(:bitstream_id => id_num)
  end
end

