require 'rack/test'
require_relative '../application.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }

UPLOAD_1 = File.join(File.dirname(__FILE__), 'files', 'UploadTest.csv')
