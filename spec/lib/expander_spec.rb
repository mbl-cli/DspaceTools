require "spec_helper"

describe DSpaceCSV::Expander do
  it 'should initialize with a new directory' do
    u = DSpaceCSV::Uploader.new(PARAMS_1)
    e = DSpaceCSV::Expander.new(u)
    e.uploader.class.should == DSpaceCSV::Uploader
    Dir.entries(e.path).include?('UploadTest.csv').should be_true
  end
end

