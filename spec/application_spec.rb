require "spec_helper"

def credentials(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end

describe 'application.rb' do
  it 'should break on unknown user' do
    get '/', {}, {"HTTP_AUTHORIZATION" => credentials("unknown", "bad_pass")}
    last_response.status.should == 401
  end

  it 'should show the default index page' do
    get '/', {}, {"HTTP_AUTHORIZATION" => credentials("jdoe", "secret")}
    last_response.status.should == 200
    last_response.body.should include('CSV to DSpace XML')
  end

  it 'should upload file and show generated content' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_1, 'application/gzip')}, {"HTTP_AUTHORIZATION" => credentials("jdoe", "secret")})
    follow_redirect!
    last_response.body.should include('Check the correctness of generated files')
  end
  
  it 'should generate error if uploaded file is not a zip file' do
    authorize 'jdoe', 'secret'
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_NOT_ZIP, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Uploaded file is not in a valid zip format')
  end
  
  it 'should generate error if uploaded archive does not contain csv file' do
    authorize 'jdoe', 'secret'
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_NO_CSV, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Cannot find file with .csv extension')
  end
  
  it 'should generate error if uploaded archive has invalid csv file' do
    authorize 'jdoe', 'secret'
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_BAD_CSV, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('Cannot parse CSV file')
  end
  
  it 'should generate error if uploaded archive is missing the Filename field' do
    authorize 'jdoe', 'secret'
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_TYPO_IN_FILENAME_FIELD, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('No Filename field')
  end

  it 'should generate error if uploaded archive had more than one Filename field' do
    authorize 'jdoe', 'secret'
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_TWO_FILENAME_FIELDS, 'application/gzip')})
    follow_redirect!
    last_response.body.should_not include('Check the correctness of generated files')
    last_response.body.should include('More than one Filename fields')
  end
end
