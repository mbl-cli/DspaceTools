require "spec_helper"

def credentials(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end

describe 'application.rb no login' do

  it 'should break on unknown user' do
    get '/', {}, {"HTTP_AUTHORIZATION" => credentials("unknown", "bad_pass")}
    last_response.redirect?.should be_true
    follow_redirect!
    last_response.successful?.should be_true
    last_response.body.match("Login to Dspace Tools").should be_true
  end
  
  it "should get login page" do
    get('/login')
    last_response.status.should == 200
    last_response.body.match(/Login to Dspace Tools/).should be_true
  end
end

describe 'application.rb with login' do

  before(:each) do 
    post("/login", :email => "jdoe@example.com", :password => "secret")
  end

  it 'should show the default index page' do
    get '/'
    last_response.status.should == 200
    last_response.body.should include('CSV to DSpace XML')
  end

  it 'should upload file and show generated content' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_1, 'application/gzip')})
    follow_redirect!
    last_response.body.should include('Check the correctness of generated files')
  end
  
  it 'should generate error if uploaded file is not a zip file' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_NOT_ZIP, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Uploaded file is not in a valid zip format')
  end
  
  it 'should encode latin1 uploaded file to UTF-8' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_LATIN1, 'application/gzip')})
    follow_redirect!
    last_response.body.should include('Check the correctness of generated files')
  end
  
  it 'should generate error if uploaded archive does not contain csv file' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_NO_CSV, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Cannot find file with .csv extension')
  end
  
  it 'should generate error if uploaded archive has a directory and does not contain csv file' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_DIR_NO_CSV, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Cannot find file with .csv extension')
  end
  
  it 'should generate error if uploaded file has many directories' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_MANY_DIRS, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Zip archive contains many folders')
  end
  
  
  it 'should generate error if uploaded archive has invalid csv file' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_BAD_CSV, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Cannot parse CSV file')
  end
  
  it 'should generate error if uploaded archive is missing the Filename field' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_TYPO_IN_FILENAME_FIELD, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('No Filename field')
  end

  it 'should generate error if uploaded archive had more than one Filename field' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_TWO_FILENAME_FIELDS, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('More than one Filename fields')
  end

  it 'should generate error if a file is not found in archive' do
    post('/upload', { :file => Rack::Test::UploadedFile.new(UPLOAD_MISSED_FILE, 'application/gzip') })
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('The following files are missed from archive: missed_file.xhtml')
  end

  it 'should generate a warning if there is an extra file in archive' do
    post('/upload', { :file => Rack::Test::UploadedFile.new(UPLOAD_EXTRA_FILE, 'application/gzip') })
    follow_redirect!
    last_response.body.should include('Check the correctness of generated files')
    last_response.body.should include('The following files are extra in archive: extra_file.xhtml')
  end
  
  it 'should generate an error if there is no title field' do
    post('/upload', { :file => Rack::Test::UploadedFile.new(UPLOAD_NO_TITLE_FIELD, 'application/gzip') })
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('No Title field')
  end
  
  it 'should generate an error if there is no rights field' do
    post('/upload', { :file => Rack::Test::UploadedFile.new(UPLOAD_NO_RIGHTS_FIELD, 'application/gzip') })
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('One of these fields must me in archive: Rights, Rights Copyright, Rights License, Rights URI')
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
    last_response.body.match("Login to Dspace Tools").should be_true
  end

end

