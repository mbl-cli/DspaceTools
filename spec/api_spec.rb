require "spec_helper"

describe 'api' do
  before(:all) do
    @api_string = "&api_key=jdoe_again&api_digest="
    @admin_api_string = "&api_key=admin&api_digest="
  end

  it 'should be possible to authorize by username and password' do
    get('/rest/authentication_test.xml?email=jdoe@example.com&password=secret')
    last_response.status.should == 200
    last_response.body.match("John").should be_true
  end
  
  it 'should not authorize with wrong username and password' do
    get('/rest/authentication_test.xml?email=someone@example.com&password=secret')
    last_response.status.should == 401
    last_response.body.match("Not authorized").should be_true
  end

  it 'should be possible to authorize by api_key and api_digest' do
    path = "/rest/authentication_test.xml" 
    get("%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]) #using 2nd private key for jdoe
    last_response.status.should == 200
    last_response.body.match("John").should be_true
  end
  
  it 'should not authorize by wrong api_key and api_digest' do
    path = "/rest/authentication_test.xml" 
    get("%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'bad_private_key')]) 
    last_response.status.should == 401
    last_response.body.match("Not authorized").should be_true
  end

  it 'should return data for item which is publicly accessible' do
    stub_request(:get, /.*items\/1702.*/).to_return(open(File.join(HTTP_DIR, "/item1702.xml")))
    url = "/rest/items/1702.xml"
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == "1702"
  end
  
  it 'should not show restricted item without authorization' do
    url = "/rest/items/1704.xml"
    get(url)
    last_response.status.should ==401 
    url = "/rest/items/1782.xml"
    get(url)
    last_response.status.should ==401 
  end

  it 'should show not authorized for unexisting items too' do
    stub_request(:get, /.*items\/9999.*/).to_return(open(File.join(HTTP_DIR, "/404_item.xml")))
    url = "/rest/items/9999.xml"
    get(url)
    last_response.status.should == 401
  end

  it 'should show restricted item to authorized user' do
    path = "/rest/items/1704.xml"
    stub_request(:get, /.*items\/1704.*/).to_return(open(File.join(HTTP_DIR, "/item1704.xml")))
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == "1704"
  end
  
  it 'should show restricted item to authorized group' do
    path = "/rest/items/1782.xml"
    stub_request(:get, /.*items\/1782.*/).to_return(open(File.join(HTTP_DIR, "/item1782.xml")))
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == "1782"
  end
  
  it 'should show restricted item to admins' do
    path = "/rest/items/1782.xml"
    stub_request(:get, /.*items\/1782.*/).to_return(open(File.join(HTTP_DIR, "/item1782.xml")))
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == "1782"
  end

  it 'should filter restricted information from returned document' do 
    stub_request(:get, /.*items\/1702.*/).to_return(open(File.join(HTTP_DIR, "/item1702.xml")))
    url = "/rest/items/1702.xml"
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == "1702"
    doc.xpath('//communityentityid').select do |element|
      element.xpath('id').text == '6'
    end.should be_empty
    doc.xpath('//communityentityid').select do |element|
      element.xpath('id').text == '4'
    end.should_not be_empty
  end

  it 'should filter restricted information from bulk queries' do 
    stub_request(:get, /communities/).to_return(open(File.join(HTTP_DIR, "/communities.xml")))
    url = "/rest/communities.xml"
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('//communities').select do |element|
      element.xpath('id').text == '6'
    end.should be_empty
    doc.xpath('//communities').select do |element|
      element.xpath('id').text == '4'
    end.should_not be_empty
  end

  it "should not filter restricted information for admins" do
    stub_request(:get, /communities/).to_return(open(File.join(HTTP_DIR, "/communities.xml")))
    path = "/rest/communities.xml"
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('//communities').select do |element|
      element.xpath('id').text == '6'
    end.should_not be_empty
    doc.xpath('//communities').select do |element|
      element.xpath('id').text == '4'
    end.should_not be_empty
  end



  # it 'should be able to get handles for authorized access of restricted file' do
  #   stub_request(:get, /.*items\\/2807.*/).to_return(open(File.join(HTTP_DIR, "/item2807.xml")))
  #   path = "/rest/handle.xml"
  #   url = "%s?%s%s&handle=http://hdl.handle.net/10776/2740" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
  #   get(url)
  #   last_response.status.should == 303
  #   follow_redirect!
  #   last_response.status.should == 200
  #   last_response.body.match(/<id type='number'>2807<\\/id>/).should be_true
  # end

  # it 'should restrict file from viewing if not authorized' do
  #   path = "/rest/handle.xml"
  #   url1 = "%s?handle=http://hdl.handle.net/10776/2740" % [path]
  #   url2 = "%s?%s%s&handle=http://hdl.handle.net/10776/2740" % [path, @api_string, ApiKey.digest(path, 'bad_digest')]
  #   [url1, url2].each do |url|
  #     get(url)
  #     last_response.status.should == 303
  #     follow_redirect!
  #     last_response.status.should == 401
  #     last_response.body.match("Not authorized").should be_true
  #   end
  # end

end

