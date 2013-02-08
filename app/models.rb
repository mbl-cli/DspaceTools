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

class DspaceTools::DspaceDb::Base
  def self.resource_number
    DspaceTools::RESOURCE_TYPE_IDS[self]
  end

  def self.find_id(hsh = {})
    return nil unless hsh.values[0].is_a?(Fixnum)
    self.where(hsh).first
  end

  def self.table_params(hsh)
    self.table_name = hsh[:table_name] if hsh[:table_name]
    self.primary_key = hsh[:primary_key] if hsh[:primary_key]
  end
end

module Resource

  def resource_type
    DspaceTools::RESOURCE_TYPE[resource_type_id][:klass]
  end

  def resource
    return nil unless resource_id
    resource_type.find(resource_id)
  end

end

class AnonymousGroup
   
end

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

class Bitstream < DspaceTools::DspaceDb::Base
  self.table_params(:table_name => 'bitstream', :primary_key => 'bitstream_id')
  
  def self.resource_number
    0
  end

  def self.find(id_num)
    self.find_id(:bitstream_id => id_num)
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
  

