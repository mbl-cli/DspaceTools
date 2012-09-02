require 'rack/test'
require 'base64'
require_relative '../application.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }

unless defined?(SPEC_CONSTANTS)
  UPLOAD_1 = File.join(File.dirname(__FILE__), 'files', 'upload.zip')
  PARAMS_1 = {"file" => {:tempfile => open(UPLOAD_1), :filename => 'upload.zip'}}
  SPEC_CONSTANTS = true
end
