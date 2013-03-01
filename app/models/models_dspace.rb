class AnonymousGroup
end

class Bitstream < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'bitstream', :primary_key => 'bitstream_id')
  
  def self.resource_number
    0
  end

  def self.find(id_num)
    self.find_id(:bitstream_id => id_num)
  end
end

class Collection < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'collection', :primary_key => 'collection_id')
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'collection_id'
  has_many :collections, :through => :collection_items
  
  def self.find(id_num)
    self.find_id(:collection_id => id_num)
  end
end

class CollectionItem < DspaceTools::DspaceDb::Base
  self.table_name = 'collection2item'
  belongs_to :collection, :class_name => 'Collection', :foreign_key => 'collection_id'
  belongs_to :item, :class_name => 'Item', :foreign_key => 'item_id'
end

class Community < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'community', :primary_key => 'community_id')

  def self.find(id_num)
    self.find_id(:community_id => id_num)
  end
end

class Eperson < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'eperson', :primary_key => 'eperson_id')
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :groups, :through => :eperson_groups
  has_many :api_keys

  def self.find(id_num)
    self.find_id(:eperson_id => id_num)
  end

  def admin?
    groups.include?(Group.find(1))
  end

  private

  def password; end
end

class EpersonGroup < DspaceTools::DspaceDb::Base
  self.table_name = 'epersongroup2eperson'
  belongs_to :group, :class_name => 'Group', :foreign_key => 'eperson_group_id'
  belongs_to :eperson, :class_name => 'Eperson', :foreign_key => 'eperson_id'
end

class Group < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'epersongroup', :primary_key => 'eperson_group_id')
  has_many :eperson_groups, :class_name => 'EpersonGroup', :foreign_key => 'eperson_group_id'
  has_many :epersons, :through => :eperson_groups

  def self.find(id_num)
    return AnonymousGroup.new if id_num == 0
    self.find_id(:eperson_group_id => id_num)
  end
end

class Handle < DspaceTools::DspaceDb::Base
  include Resource
  self.table_params(:table_name => 'handle', :primary_key => 'handle_id')

  def path
    return nil unless resource_id
    "/rest/%s%s" % [DspaceTools::RESOURCE_TYPE[resource_type_id][:rest_path], resource_id] 
  end

  def fullpath(original_fullpath, original_path)
    format = original_path.split(".")[-1]
    path_with_format = "%s.%s" % [path, format]
    public_key_match = original_fullpath.match(/api_key=([^&]+)(&|$)/)
    res = original_fullpath.gsub(original_path, path_with_format)
    if public_key_match
      ak = ApiKey.where(:public_key => public_key_match[1]).first
      digest = res.match(/(api_digest=)([^&]+)(&|$)/)
      if digest &&  ak.valid_digest?(digest[2], original_path)
        res.gsub!(/(api_digest=)([^&])+(&|$)/, '\1' + ak.digest(path_with_format) + '\3')
      end
    end
    res
  end
end

class Item < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'item', :primary_key => 'item_id')
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'item_id'
  has_many :collections, :through => :collection_items

  def self.find(id_num)
    self.find_id(:item_id => id_num)
  end
end

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

