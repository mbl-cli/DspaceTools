require 'spec_helper'

def credentials(username, password)
  'Basic ' + Base64.encode64("#{username}:#{password}")
end

describe 'application.rb no login' do

  it 'should return version number' do 
    DspaceTools.version.match(/[\d]+\.+[\d]+\.[\d]+/).should be_true
  end

  it 'should break on unknown user' do
    get '/', {}, { 'HTTP_AUTHORIZATION' => credentials('unknown', 'bad_pass') }
    last_response.redirect?.should be_true
    follow_redirect!
    last_response.successful?.should be_true
    last_response.body.match('Email').should be_true
  end
  
  it 'should get login page' do
    get('/login')
    last_response.status.should == 200
    last_response.body.match(/Email/).should be_true
  end
end

describe 'application.rb with login' do

  before(:each) do 
    post('/login', email: 'jdoe@example.com', password: 'secret')
  end

  it 'should show the default index page' do
    get '/'
    last_response.status.should == 200
    last_response.body.should include('Welcome')
  end

  it 'should upload file and show generated content' do
    post('/upload', { dir: 'upload',
                      collection_id: 42 })
    follow_redirect!
    files_warning = 'Check the correctness of generated files'
    last_response.body.should include(files_warning)
  end
  
  it 'should encode latin1 uploaded file to UTF-8' do
    post('/upload', { 
      dir: 'upload_latin1',
      collection_id: 42 })
    follow_redirect!
    files_warning = 'Check the correctness of generated files'
    last_response.body.should include(files_warning)
  end
  
  it 'should generate error if there is no collection id' do
    post('/upload', { 
      dir: 'upload', 
      collection_id: 0 })
    follow_redirect!
    files_warning = 'Check the correctness of generated files'
    collection_warning = 'Collection is not selected'
    last_response.body.should_not include(files_warning)
    last_response.body.should include(collection_warning)
  end
  
  it 'should generate error if uploaded archive does not contain csv file' do
    post('/upload', { 
      dir: 'no_csv', 
      collection_id: 42 })
    follow_redirect!
    files_warning = 'Check the correctness of generated files'
    last_response.body.should_not include(files_warning)
    last_response.body.should include('Cannot find file with .csv extension')
  end
  
  it 'should generate error if uploaded archive has invalid csv file' do
    post('/upload', { 
      dir: 'bad_csv',
      collection_id: 42 })
    follow_redirect!
    files_warning = 'Check the correctness of generated files'
    last_response.body.should_not include(files_warning)
    last_response.body.should include('Cannot parse CSV file')
  end
  
  it 'should generate error if uploaded archive is missing a Filename field' do
    post('/upload', { 
      dir: 'typo_in_filename_field',
      collection_id: 42 })
    follow_redirect!
    last_response.body.
      should_not include('Check the correctness of generated files')
    last_response.body.should include('No Filename field')
  end

  it 'should generate error if uploaded archive had more ' + 
     'than one Filename field' do
    post('/upload', { 
      dir: 'two_filename_fields',
      collection_id: 42 })
    follow_redirect!
    last_response.body.should_not 
       include('Check the correctness of generated files')
    last_response.body.should include('More than one Filename fields')
  end

  it 'should generate error if a file is not found in archive' do
    post('/upload', { 
      dir: 'missed_file',
      collection_id: 42})
    follow_redirect!
    last_response.body.should_not 
      include('Check the correctness of generated files')
    last_response.body.should 
      include('The following files are missed from archive: missed_file.xhtml')
  end

  it 'should generate a warning if there is an extra file in archive' do
    post('/upload', { 
      dir: 'extra_file',
      collection_id: 42 })
    follow_redirect!
    last_response.body.should 
      include('Check the correctness of generated files')
    last_response.body.should 
      include('The following files are extra in archive: extra_file.xhtml')
  end
  
  it 'should generate an error if there is no title field' do
    post('/upload', { 
      dir: 'no_title_field',
      collection_id: 42 })
    follow_redirect!
    last_response.body.should_not 
      include('Check the correctness of generated files')
    last_response.body.should include('No Title field')
  end
  
  it 'should generate an error if there is no rights field' do
    post('/upload', { 
      dir: 'no_rights_field',
      collection_id: 42 })
    follow_redirect!
    last_response.body.should_not 
      include('Check the correctness of generated files')
    last_response.body.should 
      include('One of these fields must me in archive: Rights, ')
  end

  it 'should finish upload to dspace' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    t = DspaceTools::Transformer.new(u)
    session = {
      current_user_id: 3,
      collection_id: 42,
      path: t.path,
    }
    stub.proxy(DspaceTools::BulkUploader).new do |obj|
      stub.proxy(obj).dspace_command do |r|
        mapfile = r.match(/-m ([^\\s]*)/)[1].strip
        "%s %s %s" % [DSPACE_MOCK, mapfile, 'success']
      end
    end
    post '/submit', {}, 'rack.session' => session
    follow_redirect!
    last_response.body.should include('Upload was successful')
  end
  
  it 'should not finish upload if mapfile is empty' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    t = DspaceTools::Transformer.new(u)
    session = {
      current_user_id: 3,
      collection_id: 42,
      path: t.path,
    }
    stub.proxy(DspaceTools::BulkUploader).new do |obj|
      stub.proxy(obj).dspace_command do |r|
        mapfile = r.match(/-m ([^\\s]*)/)[1].strip
        "%s %s" % [DSPACE_MOCK, mapfile]
      end
    end
    post '/submit', {}, 'rack.session' => session
    follow_redirect!
    last_response.body.should_not include('Upload was successful')
    last_response.body.should include('upload failed with empty mapfile')
  end
  
  it 'should not finish upload if dspace ci crashes' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    t = DspaceTools::Transformer.new(u)
    session = {
      current_user_id: 3,
      collection_id: 42,
      path: t.path,
    }
    stub.proxy(DspaceTools::BulkUploader).new do |obj|
      stub.proxy(obj).dspace_command do |r|
        raise('CRASH!!')
      end
    end
    post '/submit', {}, 'rack.session' => session
    follow_redirect!
    last_response.body.should_not include('Upload was successful')
    last_response.body.should include('CRASH!!')
  end

  it 'should show api key page' do
    get('/api_keys')
    last_response.status.should == 200
    last_response.body.match(/abcdef/).should be_true
  end

  it 'should create and delete api key' do
    ApiKey.all.each {|a| a.destroy if a.app_name == 'new_app'}
    keys_num = ApiKey.count
    authorize 'jdoe@example.com', 'secret'
    post('/api_keys', :app_name => 'new_app')
    last_response.status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.body.match(/new_app/).should be_true
    (ApiKey.count - keys_num).should == 1
    delete('/api_keys', :public_key => ApiKey.last.public_key)
    last_response.status.should == 302
    follow_redirect!
    last_response.status.should == 200
    last_response.body.match(/new_app/).should be_false
    (ApiKey.count - keys_num).should == 0
  end

  it 'should logout a user' do
    get('/')
    last_response.body.match(/Doe/).should be_true
    get('/logout')
    last_response.redirect?.should be_true
    follow_redirect!
    last_response.successful?.should be_true
    last_response.body.match(/Doe/).should be_false
    last_response.body.match("Email").should be_true
  end

end

