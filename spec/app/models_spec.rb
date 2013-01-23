require_relative "../spec_helper"

describe Eperson do

  it 'should instantiate' do
    e = Eperson.where(:email => 'jdoe@example.com').first
    e.class.should == Eperson
    e.firstname.should == 'John'
    e.api_keys.size.should > 1
    e.groups.size.should > 0
    Eperson.resource_number.should == 7
  end

end

describe ApiKey do
  it 'should instantiate' do
    ak = ApiKey.where(:eperson_id => 1).first
    ak.class.should == ApiKey
  end

  it 'should be able to have more than one api key per eperson' do
    aks = ApiKey.where(:eperson_id => 1)
    aks.size.should > 1
    aks = ApiKey.where(:eperson_id => 2)
    aks.size.should == 1
  end

  it "should be able to get digest as a class and instance methods" do
    ApiKey.digest('onetwo', 'abcdef').should == '805d5daf'
    ApiKey.where(:eperson_id => 1)[-1].digest('onetwo').should == '805d5daf'
  end
end

describe Handle do

  it 'should not have a resource number' do
    Handle.resource_number.should be_nil
  end

  it 'should instantiate' do
    h = Handle.where(:handle => "123/123").first
    h.class.should == Handle
    h.resource_type.should == Item
    h.resource.should == Item.find(1)
    h.path.should == '/rest/items/1'
  end

  it 'should modify path' do
    h = Handle.where(:handle => "123/123").first
    original_fullpath = "http://example.org/rest/handle.xml?handle=http://hdl.handle.net/123/123&api_key=jdoe_again&api_digest=8a5dabc2"
    original_path = "/rest/handle.xml"
    new_path = h.fullpath(original_fullpath, original_path)
    new_path.should == "http://example.org/rest/items/1.xml?handle=http://hdl.handle.net/123/123&api_key=jdoe_again&api_digest=bf0f9de3"
    original_fullpath = "http://example.org/rest/handle.xml?handle=http://hdl.handle.net/123/123&api_key=jdoe_again&api_digest=8a5dabc2&some_param=2"
    original_path = "/rest/handle.xml"
    new_path = h.fullpath(original_fullpath, original_path)
    new_path.should == "http://example.org/rest/items/1.xml?handle=http://hdl.handle.net/123/123&api_key=jdoe_again&api_digest=bf0f9de3&some_param=2"
  end
end
