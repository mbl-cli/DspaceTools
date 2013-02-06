class ApiKey < ActiveRecord::Base
  belongs_to :eperson

  def self.digest(path, key)
    Digest::SHA1.hexdigest(path.to_s + key.to_s)[0..7]
  end

  def self.get_public_key
    key = 0
    while true do
      rand_max = 0xffffffff - 0x10000000
      key = rand(rand_max).+(0x10000000).to_s(16)
      break if ApiKey.where(:public_key => key).empty?
    end
    key
  end

  def self.get_private_key
    rand_max = 0xffffffffffffffff - 0x1000000000000000
    key = rand(rand_max).+(0x1000000000000000).to_s(16)
  end


  def digest(path)
    ApiKey.digest(path, private_key)
  end

  def valid_digest?(a_digest, path)
    digest(path) == a_digest
  end
end

class DSpaceCSV::DspaceDb::Base
  def self.resource_number
    DSpaceCSV::RESOURCE_TYPE_IDS[self]
  end
end

module Resource

  def resource_type
    DSpaceCSV::RESOURCE_TYPE[resource_type_id][:klass]
  end

  def resource
    return nil unless resource_id
    resource_type.find(resource_id)
  end

end

class AnonymousGroup
   
end

class Eperson < DSpaceCSV::DspaceDb::Base
  self.table_name = 'eperson'
  self.primary_key = 'eperson_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup'
  has_many :groups, :through => :eperson_groups
  has_many :api_keys

  def self.find(id_num)
    return nil unless id_num.is_a?(Fixnum)
    Eperson.where(:eperson_id => id_num).first
  end

  def is_admin?
    groups.include?(Group.find(1))
  end

  private

  def password; end
end

class EpersonGroup < DSpaceCSV::DspaceDb::Base
  self.table_name = 'epersongroup2eperson'
  belongs_to :group, :class_name => 'Group', :foreign_key => 'eperson_group_id'
  belongs_to :eperson, :class_name => 'Eperson', :foreign_key => 'eperson_id'
end

class Group < DSpaceCSV::DspaceDb::Base
  self.table_name = 'epersongroup'
  self.primary_key = 'eperson_group_id'
  has_many :eperson_groups, :class_name => 'EpersonGroup', :foreign_key => 'eperson_group_id'
  has_many :epersons, :through => :eperson_groups

  def self.find(id_num)
    return nil unless id_num.is_a?(Fixnum)
    return AnonymousGroup.new if id_num == 0
    Group.where(:eperson_group_id => id_num).first
  end
end

class Handle < DSpaceCSV::DspaceDb::Base
  include Resource
  self.table_name = 'handle'
  self.primary_key = 'handle_id'

  def path
    return nil unless resource_id
    "/rest/%s%s" % [DSpaceCSV::RESOURCE_TYPE[resource_type_id][:rest_path], resource_id] 
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

class Item < DSpaceCSV::DspaceDb::Base
  self.table_name = 'item'
  self.primary_key = 'item_id'
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'item_id'
  has_many :collections, :through => :collection_items

  def self.find(id_num)
    Item.where(:item_id => id_num).first
  end
end

class Collection < DSpaceCSV::DspaceDb::Base
  self.table_name = 'collection'
  self.primary_key = 'collection_id'
  has_many :collection_items, :class_name => 'CollectionItem', :foreign_key => 'collection_id'
  has_many :collections, :through => :collection_items
  
  def self.find(id_num)
    Collection.where(:collection_id => id_num).first
  end
end

class CollectionItem < DSpaceCSV::DspaceDb::Base
  self.table_name = 'collection2item'
  belongs_to :collection, :class_name => 'Collection', :foreign_key => 'collection_id'
  belongs_to :item, :class_name => 'Item', :foreign_key => 'item_id'
end

class Community < DSpaceCSV::DspaceDb::Base
  self.table_name = 'community'
  self.primary_key = 'community_id'

  def self.find(id_num)
    Community.where(:community_id => id_num).first
  end
end

class Bitstream < DSpaceCSV::DspaceDb::Base
  self.table_name = 'bitstream'
  self.primary_key = 'bitstream_id'
  
  def self.resource_number
    0
  end

  def self.find(id_num)
    Bitstream.where(:community_id => id_num).first
  end
end

class Resourcepolicy < DSpaceCSV::DspaceDb::Base
  include Resource
  self.table_name = 'resourcepolicy'
  self.primary_key = 'policy_id'
  
  def action
    DSpaceCSV::ACTION[action_id]
  end

  def group
    Group.find(epersongroup_id)
  end

  def eperson
    Eperson.find(eperson_id)
  end

end
  

