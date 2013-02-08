class Item < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'item', :primary_key => 'item_id')
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'item_id'
  has_many :collections, :through => :collection_items

  def self.find(id_num)
    self.find_id(:item_id => id_num)
  end
end

