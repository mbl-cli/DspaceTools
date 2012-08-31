require "sinatra"
require "fileutils"
require "bundler/setup"
require "erb"
require "nokogiri"
require "zip/zip"
require "csv"

module DSpaceCSV
  Conf = OpenStruct.new(
    :tmpdir => '/tmp',
  )

  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'dspace_csv'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) { |lib| require File.basename(lib, '.*') }
end
