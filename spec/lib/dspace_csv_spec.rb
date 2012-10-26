require "spec_helper"

describe DSpaceCSV do

  before(:all) do
    u = DSpaceCSV::Uploader.new(PARAMS_1)
    e = DSpaceCSV::Expander.new(u)
    @user = DSpaceCSV::Conf.users['jdoe']
    @collection_id = @user["default_collection_id"]
    @path = DSpaceCSV::Transformer.new(e).path
  end

  it "should submit data to dspace" do
    s = DSpaceCSV.public_methods.include?(:submit).should be_true
  end

end
