require "spec_helper"

DSPACE_MOCK = File.join(File.dirname(__FILE__), '..', 'bin', 'dspace_mock')

describe DspaceTools::BulkUploader do
  before(:all) do
    u = DspaceTools::Uploader.new(PARAMS_1)
    t = DspaceTools::Transformer.new(u)
    user = Eperson.find(3)
    @bu = DspaceTools::BulkUploader.new(t.path, 1, user)
  end

  it 'should initialize' do
    @bu.class.should == DspaceTools::BulkUploader
  end

  it 'should have dspace command' do
    @bu.dspace_command.class.should == String
    @bu.dspace_command.should_not == ''
  end

  it 'should submit data with success' do
    stub.proxy(@bu).dspace_command do |r| 
        mapfile = r.match(/-m ([^\s]*)/)[1].strip
        r.match('2>&1').should be_true
        "%s %s success" % [DSPACE_MOCK, mapfile]
    end
    mapfile = @bu.submit
    open(File.join(DspaceTools::Conf.root_path, 
                   'public', 'map_files', mapfile)).read.strip.should == '1 2'
  end

  it 'should give error if mapfile is empty' do
    stub.proxy(@bu).dspace_command do |r| 
        mapfile = r.match(/-m ([^\s]*)/)[1].strip
        "%s %s empty_mapfile" % [DSPACE_MOCK, mapfile]
    end
    lambda { @bu.submit }.should raise_error
  end

  it 'should give show problem from ci failure' do
    stub.proxy(@bu).dspace_command do |r| 
      "%s 2>&1" % DSPACE_MOCK
    end
    lambda { @bu.submit }.should raise_error
    begin
      @bu.submit
    rescue RuntimeError => e
      e.message.match('Dspace upload failed:').should be_true
      e.message.match('(TypeError)').should be_true
    end
  end

end
