require 'spec_helper'

describe 'api' do
  before(:all) do
    @api_string = '&api_key=jdoe_again&api_digest='
    @admin_api_string = '&api_key=admin&api_digest='
  end

  it 'should be possible to authorize by username and password' do
    get('/rest/authentication_test.xml?email=jdoe@example.com&password=secret')
    last_response.status.should == 200
    last_response.body.match('John').should be_true
  end

  it 'should not authorize with wrong username and password' do
    get('/rest/authentication_test.xml?email=someone@' +
        'example.com&password=secret')
    last_response.status.should == 401
    last_response.body.match('Not authorized').should be_true
  end

  it 'should be possible to authorize by api_key and api_digest' do
    path = '/rest/authentication_test.xml'
    # using 2nd private key for jdoe
    get("%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')])
    last_response.status.should == 200
    last_response.body.match('John').should be_true
  end

  it 'should not authorize by wrong api_key and api_digest' do
    path = '/rest/authentication_test.xml'
    get("%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'bad_private_key')])
    last_response.status.should == 401
    last_response.body.match('Not authorized').should be_true
  end

  it 'should return data for item which is publicly accessible' do
    stub_request(:get, /.*items\/1702.*/).
      to_return(open(File.join(HTTP_DIR, '/item1702.xml')))
    url = '/rest/items/1702.xml'
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == '1702'
  end

  it 'should not show restricted item without authorization' do
    url = '/rest/items/1704.xml'
    get(url)
    last_response.status.should ==401
    url = '/rest/items/1782.xml'
    get(url)
    last_response.status.should ==401
  end

  it 'should show not authorized for unexisting items too' do
    stub_request(:get, /.*items\/9999.*/).
      to_return(open(File.join(HTTP_DIR, '/404_item.xml')))
    url = '/rest/items/9999.xml'
    get(url)
    last_response.status.should == 401
  end

  it 'should show return not found for admin' do
    stub_request(:get, /.*items\/9999.*/).
      to_return(open(File.join(HTTP_DIR, '/404_item.xml')))
    path = '/rest/items/9999.xml'
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 404
  end

  it 'should show return server errors for admin' do
    stub_request(:get, /.*items\/9999.*/).
      to_return(open(File.join(HTTP_DIR, '/500.xml')))
    path = '/rest/items/9999.xml'
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 500
  end

  it 'should show restricted item to authorized user' do
    path = '/rest/items/1704.xml'
    stub_request(:get, /.*items\/1704.*/).
      to_return(open(File.join(HTTP_DIR, '/item1704.xml')))
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == '1704'
  end

  it 'should show restricted item to authorized group' do
    path = '/rest/items/1782.xml'
    stub_request(:get, /.*items\/1782.*/).
      to_return(open(File.join(HTTP_DIR, '/item1782.xml')))
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == '1782'
  end

  it 'should show restricted item to admins' do
    path = '/rest/items/1782.xml'
    stub_request(:get, /.*items\/1782.*/).
      to_return(open(File.join(HTTP_DIR, '/item1782.xml')))
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == '1782'
  end

  it 'should filter restricted information from returned document' do
    stub_request(:get, /.*items\/1702.*/).
      to_return(open(File.join(HTTP_DIR, '/item1702.xml')))
    url = '/rest/items/1702.xml'
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('/items/entityId').text.should == '1702'
    doc.xpath('//communityentityid').select do |element|
      element.xpath('id').text == '6'
    end.should be_empty
    doc.xpath('//communityentityid').select do |element|
      element.xpath('id').text == '4'
    end.should_not be_empty
  end

  it 'should filter restricted information from bulk queries' do
    stub_request(:get, /communities/).
      to_return(open(File.join(HTTP_DIR, '/communities.xml')))
    url = '/rest/communities.xml'
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

  it 'should show collection to its admin' do
    stub_request(:get, %r|collections/31|).
      to_return(open(File.join(HTTP_DIR, '/collection31.xml')))
    path = '/rest/collections/31.xml'
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('//entityId').text.should == '31'
  end

  it 'should not show collection to a registered but not authorized user' do
    path = '/rest/collections/31.xml'
    jane_api_string = '&api_key=&janedoe456api_digest='
    url = "%s?%s%s" % [path, jane_api_string, ApiKey.digest(path, '678990')]
    get(url)
    last_response.status.should == 401
  end

  it 'should not filter restricted information for admins' do
    stub_request(:get, /communities/).
      to_return(open(File.join(HTTP_DIR, '/communities.xml')))
    path = '/rest/communities.xml'
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

  it 'should allow access to a resource without explicit permissions\\
      only to admin' do
    stub_request(:get, %r|bitstream/4833|).
      to_return(open(File.join(HTTP_DIR, '/bitstream4833.xml')))
    path = '/rest/bitstream/4833.xml'
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('//entityId').text.should == '4833'
    url = "%s?%s%s" % [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 401
  end


  it 'should be able to translate handles into underlying object for\\
      restricted data' do
    stub_request(:get, %r|.*items/1704.*|).
      to_return(open(File.join(HTTP_DIR, '/item1704.xml')))
    path = '/rest/handle.xml'
    url = "%s?%s%s&handle=http://hdl.handle.net/10776/2740" %
          [path, @api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    last_response.status.should == 303
    follow_redirect!
    last_response.status.should == 200
    doc = Nokogiri.parse(last_response.body)
    doc.xpath('//entityId').text.should == '1704'
  end

  it 'should restrict file from viewing if not authorized' do
    path = '/rest/handle.xml'
    url1 = "%s?handle=http://hdl.handle.net/10776/2740" % [path]
    url2 = "%s?%s%s&handle=http://hdl.handle.net/10776/2740" %
            [path, @api_string, ApiKey.digest(path, 'bad_digest')]
    [url1, url2].each do |url|
      get(url)
      last_response.status.should == 303
      follow_redirect!
      last_response.status.should == 401
      last_response.body.match('Not authorized').should be_true
    end
  end

  it 'should get publicly available bitstream' do
    stub(Bitstream).find do
      Bitstream.new(bitstream_id: 4761,
                    bitstream_format_id: 18,
                    name: 'DSpace_logo.png',
                    size_bytes: 21000,
                    internal_id: '123456789123456789123456789',
                   )
    end
    stub.proxy(Bitstream).new do |obj|
      fdir = File.dirname(__FILE__)
      obj.path.match(%r|/12/34/56/123456789123456789123456789$|).should be_true
      stub(obj).path { |p| File.join(fdir, 'files', 'DSpace_logo_png') }
    end
    path = '/rest/bitstream/4761'
    get(path)
    lr = last_response
    lr.status.should == 200
  end

  it 'should not get unauthorized bitstream' do
    path = '/rest/bitstream/4832'
    get(path)
    last_response.status.should == 401
    last_response.body.match('Not authorized').should be_true
  end

  it 'should get authorized bitstream' do
    stub(Bitstream).find do
      Bitstream.new(bitstream_id: 4832,
                    bitstream_format_id: 18,
                    name: 'DSpace_logo.png',
                    size_bytes: 21000,
                    internal_id: '123456789123456789123456789',
                   )
    end
    stub.proxy(Bitstream).new do |obj|
      fdir = File.dirname(__FILE__)
      obj.path.match(%r|/12/34/56/123456789123456789123456789$|).should be_true
      stub(obj).path { |p| File.join(fdir, 'files', 'DSpace_logo_png') }
    end
    path = '/rest/bitstream/4832'
    url = "%s?%s%s" % [path, @admin_api_string, ApiKey.digest(path, 'abcdef')]
    get(url)
    lr = last_response
    lr.status.should == 200
  end

  it 'should return updates for items' do
    timestamps = Item.connection.execute("select last_modified from item
                         order by last_modified desc limit 5").
                         to_a.flatten.map { |i| i.to_s.gsub(' UTC','.123-00') }
    timestamps.size.should == timestamps.uniq.size
    ts = timestamps.last
    # stub_request(:get, %r|updates.xml|).
    #   to_return(rest_request(params))
    path = "/rest/updates/items.xml"
    params = "community=4&timestamp=#{URI.escape(ts)}" 
    url = "%s?%s%s%s" % [path, params, @admin_api_string, 
                          ApiKey.digest(path, 'abcdef')
                          ] 
    get(url)
    res = Nokogiri.parse(last_response.body)
    res.xpath('//items').size.should == 3
    url.gsub!('community=4', 'community=6')
    get(url)
    res = Nokogiri.parse(last_response.body)
    res.xpath('//items').size.should == 2

  end
end

