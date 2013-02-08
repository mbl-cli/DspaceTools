require "spec_helper"

describe DspaceTools::Transformer do
  it 'should initialize with a new directory' do
    u = DspaceTools::Uploader.new(PARAMS_1)
    e = DspaceTools::Expander.new(u)
    t = DspaceTools::Transformer.new(e)
    t.expander.class.should == DspaceTools::Expander
    t.path.should == File.join(u.path, 'dspace')
    Dir.entries(t.path).include?('0000').should be_true
    Dir.entries(t.path).include?('0001').should be_true
    Dir.entries(t.path).include?('0002').should be_true
    Dir.entries(File.join(t.path, '0000')).sort.should == [".", "..", "contents", "dublin_core.xml", "embryo128386.xhtml"]
  end
end

