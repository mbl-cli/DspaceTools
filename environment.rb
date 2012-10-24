require "sinatra"
require "fileutils"
require "bundler/setup"
require "erb"
require "haml"
require "nokogiri"
require "zip/zip"
require "csv"


module DSpaceCSV
  conf_data = YAML.load(open(File.join(File.dirname(__FILE__), "config", "config.yml")).read)
  Conf = OpenStruct.new(
    :root_path => File.dirname(__FILE__),
    :tmp_dir => conf_data['tmp_dir'],
    :remote_tmp_dir => conf_data['remote_tmp_dir'],
    :dspace_path => conf_data['dspace_path'],
    :remote_login => conf_data['remote_login'],
    :users => YAML.load(open(File.join(File.dirname(__FILE__), "config", "users.yml")).read),
    :valid_fields => YAML.load(open(File.join(File.dirname(__FILE__), "config", "valid_fields.yml")).read).map { |f| f.strip },
  )

end
  
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib", "dspace_csv"))
Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")) { |lib| require File.basename(lib, ".*") }
