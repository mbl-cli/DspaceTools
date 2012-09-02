require "spec_helper"

def credentials(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end

describe 'application.rb' do

  it 'should show the default index page' do
    get '/', {}, {"HTTP_AUTHORIZATION" => credentials("jdoe", "secret")}
    last_response.body.should include('CSV to DSpace XML')
  end

  it 'should save classification file keeping different versions' do
    post('/upload', {:file => Rack::Test::UploadedFile.new(UPLOAD_1, 'application/gzip')}, {"HTTP_AUTHORIZATION" => credentials("jdoe", "secret")})
    follow_redirect!
    last_response.body.should include('Upload was successful')
  end

end
