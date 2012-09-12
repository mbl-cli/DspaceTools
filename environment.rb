require "sinatra"
require "fileutils"
require "bundler/setup"
require "erb"
require "haml"
require "nokogiri"
require "zip/zip"
require "csv"

module DSpaceCSV
  Conf = OpenStruct.new(
    :root_path => File.dirname(__FILE__),
    :tmpdir => "/tmp",
    :users => YAML.load(open(File.join(File.dirname(__FILE__), "config", "users.yml")).read),
    :valid_fields => YAML.load(open(File.join(File.dirname(__FILE__), "config", "valid_fields.yml")).read).map { |f| f.strip },
  )

  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib", "dspace_csv"))
  Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")) { |lib| require File.basename(lib, ".*") }
end
