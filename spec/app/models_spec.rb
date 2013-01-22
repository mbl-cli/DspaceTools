require_relative "../spec_helper"

describe Eperson do

  it 'should instantiate' do
    e = Eperson.where(:email => 'jdoe@example.com').first
    e.class.should == Eperson
    e.firstname.should == 'John'
    e.api_keys.size.should > 1
    e.groups.size.should > 0
  end

end

describe ApiKey do
  it 'should instantiate' do
    ak = ApiKey.where(:eperson_id => 1).first
    ak.class.should == ApiKey
  end

  it 'should be able to have more than one api key per eperson' do
    aks = ApiKey.where(:eperson_id => 1)
    aks.size.should > 1
    aks = ApiKey.where(:eperson_id => 2)
    aks.size.should == 1
  end
end

