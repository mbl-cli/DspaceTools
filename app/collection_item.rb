class CollectionItem < DspaceTools::DspaceDb::Base
  self.table_name = 'collection2item'
  belongs_to :collection, :class_name => 'Collection', :foreign_key => 'collection_id'
  belongs_to :item, :class_name => 'Item', :foreign_key => 'item_id'
end

