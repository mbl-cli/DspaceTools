require "spec_helper"

describe 'application.rb' do


  specify 'should show the default index page' do
    get '/'
    last_response.body.should include('CSV to DSpace XML')
  end

  it 'should save classification file keeping different versions' do
    post('/upload', :file => Rack::Test::UploadedFile.new(UPLOAD_1, 'application/gzip'))
    follow_redirect!
    last_response.body.should include('Upload was successful')
  end

end
