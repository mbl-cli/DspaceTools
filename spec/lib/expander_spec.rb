require "spec_helper"

describe DspaceTools::Expander do
  it 'should initialize with a new directory' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    e = DspaceTools::Expander.new(u)
    e.uploader.class.should == DspaceTools::Uploader
    Dir.entries(e.path).include?('UploadTest.csv').should be_true
  end

  it 'should generate exception if file is not a zip file' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    e = DspaceTools::Expander.new(u)
  end
end

