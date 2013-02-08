require "spec_helper"

describe DspaceTools do

  before(:all) do
    u = DspaceTools::Uploader.new(PARAMS_1)
    e = DspaceTools::Expander.new(u)
    @user = DspaceTools::Conf.users['jdoe']
    @collection_id = @user["default_collection_id"]
    @path = DspaceTools::Transformer.new(e).path
  end

  it "should submit data to dspace" do
    s = DspaceTools.instance_methods.include?(:submit).should be_true
  end

end
