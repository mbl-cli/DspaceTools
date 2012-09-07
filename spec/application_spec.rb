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

end
