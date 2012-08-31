require 'rack/test'
require_relative '../application.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }

UPLOAD_1 = File.join(File.dirname(__FILE__), 'files', 'UploadTest.csv')
UPLOAD_2 = File.join(File.dirname(__FILE__), 'files', 'upload.zip')

PARAMS_1 = {"file" => {:tempfile => open(UPLOAD_2), :filename => 'upload.zip'}}
