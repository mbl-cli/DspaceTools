require "spec_helper"

describe DspaceTools::Uploader do

  before(:all) do
    DspaceTools::Uploader.clean(0)
  end
  
  it 'should initialize with a new directory' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    u.file[:filename].should == 'upload.zip'
    u.dir.should ~ /dspace_[\d]{10}/
    File.exists?(u.path).should be_true
    File.exists?(File.join(u.path, u.file[:filename])).should be_true
  end
end

