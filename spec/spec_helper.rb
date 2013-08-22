require 'coveralls'
Coveralls.wear!

ENV["RACK_ENV"] = 'test'

require "rack/test"
require "webmock/rspec"
require "base64"
require "factory_girl"
require_relative "../application.rb"

module RSpecMixin
  include Rack::Test::Methods
  def app() DspaceToolsUi end
end

RSpec.configure do |c|
  c.include RSpecMixin
  c.mock_with :rr
end

unless defined?(SPEC_CONSTANTS)
  DspaceTools::Conf.dropbox_dir = File.join(File.dirname(__FILE__), 'files')
  FG = FactoryGirl
  HTTP_DIR = File.join(File.dirname(__FILE__), "http")
  PARAMS_1 = { dir: 'upload', collection_id: 42 }
  SPEC_CONSTANTS = true
  DSPACE_MOCK = File.join(File.dirname(__FILE__), 'bin', 'dspace_mock')
end

#FG.find_definitions
