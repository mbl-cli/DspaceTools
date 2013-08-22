require_relative '../spec_helper'

describe ApiKey do

  it 'should instantiate' do
    ak = ApiKey.where(eperson_id: 1).first
    ak.class.should == ApiKey
  end

  it 'should be able to have more than one api key per eperson' do
    aks = ApiKey.where(eperson_id: 1)
    aks.size.should > 1
    aks = ApiKey.where(eperson_id: 2)
    aks.size.should == 1
  end

  it 'should be able to get digest as a class and instance methods' do
    ApiKey.digest('onetwo', 'abcdef').should == '805d5daf'
    ApiKey.where(eperson_id: 1)[1].digest('onetwo').should == '805d5daf'
  end

  it 'should generate public key' do
    key = ApiKey.get_public_key
    key.match(/[\h]{8}/).should_not be_nil
  end
  
  it 'should generate private key' do
    key = ApiKey.get_private_key
    key.match(/[\h]{16}/).should_not be_nil
  end

end

describe Eperson do

  it 'should instantiate' do
    e = Eperson.where(email: 'jdoe@example.com').first
    e.class.should == Eperson
    e.firstname.should == 'John'
    e.api_keys.size.should > 1
    e.groups.size.should > 0
    Eperson.resource_number.should == 7
  end

  it 'should have admin method' do
    e = Eperson.where(email: 'jdoe@example.com').first
    e.admin?.should == false
    e = Eperson.where(email: 'admin@example.com').first
    e.admin?.should be_true
  end

end

describe Group do

  it 'should have find method' do
    g = Group.first
    Group.find(g.eperson_group_id).should == g
  end

  it 'should have epsersons connected' do
    g = Group.first
    g.epersons[0].class.should == Eperson
    g.epersons.size.should > 0
  end

end

describe Handle do

  it 'should not have a resource number' do
    Handle.resource_number.should be_nil
  end

  it 'should instantiate' do
    h = Handle.where(handle: '123/123').first
    h.class.should == Handle
    h.resource_type.should == Item
    h.resource.should == Item.find(1)
    h.path.should == '/rest/items/1'
  end

  it 'should modify path' do
    h = Handle.where(handle: '123/123').first
    original_fullpath = 'http://example.org/rest/handle.xml' + 
      '?handle=http://hdl.handle.net/123/123' + 
      '&api_key=jdoe_again&api_digest=8a5dabc2'
    original_path = '/rest/handle.xml'
    new_path = h.fullpath(original_fullpath, original_path)
    new_path.should == 'http://example.org/rest/items/1.xml' + 
      '?handle=http://hdl.handle.net/123/123' + 
      '&api_key=jdoe_again&api_digest=bf0f9de3'
    original_fullpath = 'http://example.org/rest/handle.xml' + 
      '?handle=http://hdl.handle.net/123/123&api_key=jdoe_again' + 
      '&api_digest=8a5dabc2&some_param=2'
    original_path = '/rest/handle.xml'
    new_path = h.fullpath(original_fullpath, original_path)
    new_path.should == 'http://example.org/rest/items/1.xml' + 
      '?handle=http://hdl.handle.net/123/123&api_key=jdoe_again' + 
      '&api_digest=bf0f9de3&some_param=2'
  end
end

describe Bitstream do

  it 'should have 0 resource number' do
    Bitstream.resource_number.should == 0
  end

  it 'should have find method' do
    b = Bitstream.first
    Bitstream.find(b.bitstream_id).should == b
  end

  it 'should have path' do
    b = Bitstream.first
    b.path.match(%r|^/tmp/\d\d/\d\d/\d\d/[\d]*$|).should be_true
  end

  it 'should have mime type' do
    b = Bitstream.first
    b.mime.should == 'application/octet-stream'
  end

end

describe BitstreamFormat do

  it 'should not have resource number' do 
    BitstreamFormat.resource_number.should be_nil
  end

  it 'should find it' do
    bf = BitstreamFormat.first
    BitstreamFormat.find(bf.bitstream_format_id).should == bf
  end

end

describe Collection do

  it 'should have find method' do
    c = Collection.first
    Collection.find(c.collection_id).should == c
  end

end

describe Community do

  it 'should have find method' do
    c = Community.first
    Community.find(c.community_id).should == c
  end

end

describe CommunityItem do

  it 'should connect items and communities' do
    Community.find(6).items.size.should > 1
    item = Community.find(6).items[0]
    item.class.should == Item
    item.communities.size.should > 0
  end
end

describe Item do

  it 'should have find method' do
    item = Item.first
    Item.find(item.item_id).should == item
  end

  it 'should find updates without timestamps or group' do
    Item.updates(nil).size.should > 1000
    Item.updates('bad_ts').size.should == 0
  end

  it 'should find updates with timestamp without group' do
    ts = Item.all[-5].last_modified
    Item.updates(ts).size.should == 4
  end

  it 'should not break with a wrong group' do
    ts = Item.all[-5].last_modified
    Item.updates(ts, 'huh').size.should == 0
  end

  it 'should return updates for a group' do
    ts = Item.all[-5].last_modified
    Item.updates(ts, 4).size.should == 3
  end
end

describe Resourcepolicy do

  it 'should have action, group, or epserson' do
    r = Resourcepolicy.first
    r.action.should == 'READ'
    r.group.class.should == AnonymousGroup
    r.eperson.should be_nil
    r = Resourcepolicy.find(2)
    r.eperson.class.should == Eperson
  end

end
