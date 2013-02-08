class Collection < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'collection', :primary_key => 'collection_id')
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'collection_id'
  has_many :collections, :through => :collection_items
  
  def self.find(id_num)
    self.find_id(:collection_id => id_num)
  end
end

