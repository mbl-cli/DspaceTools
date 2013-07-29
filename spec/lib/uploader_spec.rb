require "spec_helper"

describe DspaceTools::Uploader do

  before(:all) do
    DspaceTools::Uploader.clean(0)
  end
  
  it 'should initialize with a tmp directory' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    u.incoming_path.match('upload').should be_true
    u.dir.should ~ /dspace_[\d]{10}/
    u.path.should ~ /tmp.*dspace/
  end
end

