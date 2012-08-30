require "spec_helper"

describe 'main application' do


  specify 'should show the default index page' do
    get '/'
    last_response.body.should include('CSV to DSpace XML')
  end

  it 'should save classification file keeping different versions' do
    post('/upload', :file => Rack::Test::UploadedFile.new(UPLOAD_1, 'application/gzip'))
    last_response.body.should include('dspace_directory_structure.rb')
  end

end
