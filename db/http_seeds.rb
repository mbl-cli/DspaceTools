require_relative '../environment'
require_relative '../spec/spec_helper'
require_relative 'seeds'

exit if settings.environment != :test

FG.find_definitions

class HttpSeeder
  HTTP_DIR = File.join(File.dirname(__FILE__), '..', 'spec', 'http')

  def walk_xml
    communities = {}
    collections = {}
    items       = {}
    bitstreams  = {}
    Dir.entries(HTTP_DIR).each do |file|
      if file[-4..-1] == '.xml'
        xml_text = open(File.join(HTTP_DIR, file)).
          read.gsub(/.*(<\?xml)/m, '\1')
        @doc = Nokogiri.parse(xml_text)

       [
         ['//communityentityid', communities],
         ['//collectionentityid', collections],
         ['//itementityid', items],
         ['//bitstreamentityid', bitstreams]
       ].each {|i| collect_data(*i)}
      end
    end
    [
      [communities, :community, :community_id],
      [collections, :collection, :collection_id],
      [items, :item, :item_id],
      [bitstreams, :bitstream, :bitstream_id],
    ].each {|data| create_records(*data)}
  end

  def make_fake_policies
    FG.create(:resourcepolicy,
              :resource_type_id => Community.resource_number,
              :resource_id => 4, :epersongroup_id => 0)
    FG.create(:resourcepolicy,
              :resource_type_id => Community.resource_number,
              :resource_id => 6, :eperson_id => 1)
    FG.create(:resourcepolicy,
              :resource_type_id => Collection.resource_number,
              :resource_id => 6, :epersongroup_id => 0)
    FG.create(:resourcepolicy,
              :resource_type_id => Collection.resource_number,
              :resource_id => 7, :eperson_id => 1, :epersongroup_id => nil)
    FG.create(:resourcepolicy,
              :resource_type_id => Collection.resource_number,
              :action_id => 11, :resource_id => 31, :epersongroup_id => 2)
    FG.create(:resourcepolicy,
              :resource_type_id => Item.resource_number,
              :resource_id => 1702, :epersongroup_id => 0)
    FG.create(:resourcepolicy,
              :resource_type_id => Item.resource_number,
              :resource_id => 1704, :eperson_id => 1, :epersongroup_id => nil)
    FG.create(:resourcepolicy,
              :resource_type_id => Item.resource_number,
              :resource_id => 1782, :epersongroup_id => 2)
    FG.create(:resourcepolicy,
              :resource_type_id => Bitstream.resource_number,
              :resource_id => 4761, :epersongroup_id => 0)
    FG.create(:resourcepolicy,
              :resource_type_id => Bitstream.resource_number,
              :resource_id => 4762, :epersongroup_id => 1)
    FG.create(:resourcepolicy,
              :resource_type_id => Bitstream.resource_number,
              :resource_id => 4832, :eperson_id => 1)
  end

  def change_items_last_modified
    Item.all[-5..-1].reverse.each_with_index do |item, i|
      item.last_modified = Time.now - (i * 1000)
      item.save!
    end
  end

  def make_community_item
    Item.all[-4..-2].each do |item|
      c = Community.find(4)
      CommunityItem.create(item_id: item.item_id,
                           community_id: c.community_id)
    end
    Item.all[-2..-1].each do |item|
      c = Community.find(6)
      CommunityItem.create(item_id: item.item_id,
                           community_id: c.community_id)
    end
  end

  private

  def collect_data(an_xpath, a_hash)
    @doc.xpath(an_xpath).each do |node|
      a_hash[node.xpath('id').text.to_i] = 1
    end
  end

  def create_records(a_hash, a_type, id_name)
    a_hash.keys.each do |i|
      FG.create(a_type, id_name => i)
    end
  end

end


hs = HttpSeeder.new
hs.walk_xml
hs.make_fake_policies
hs.change_items_last_modified
hs.make_community_item
