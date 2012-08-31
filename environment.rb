require 'rubygems'
require "fileutils"
require "bundler/setup"
require "sinatra"
require "erb"
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'dspace_csv'

class DSpaceCSV
  Conf = OpenStruct.new(
    :tmpdir => '/tmp',
  )
end
