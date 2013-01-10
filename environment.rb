require "sinatra"
require "fileutils"
require "bundler/setup"
require "erb"
require "haml"
require "nokogiri"
require "zip/zip"
require "csv"
require "sinatra/activerecord"
require "rest-client"


module DSpaceCSV
  conf_data = YAML.load(open(File.join(File.dirname(__FILE__), "config", "config.yml")).read)
  Conf = OpenStruct.new(
    :root_path => File.dirname(__FILE__),
    :tmp_dir => conf_data['tmp_dir'],
    :remote_tmp_dir => conf_data['remote_tmp_dir'],
    :dspace_repo => conf_data['dspace_repo'],
    :dspace_path => conf_data['dspace_path'],
    :dspace_db => conf_data['dspace_db'],
    :dspace_dbuser => conf_data['dspace_dbuser'],
    :dspace_dbpass => conf_data['dspace_dbpass'],
    :remote_login => conf_data['remote_login'],
    :users => YAML.load(open(File.join(File.dirname(__FILE__), "config", "users.yml")).read),
    :valid_fields => YAML.load(open(File.join(File.dirname(__FILE__), "config", "valid_fields.yml")).read).map { |f| f.strip },
  )

end

set :database, "postgres://#{DSpaceCSV::Conf.dspace_dbuser}:#{DSpaceCSV::Conf.dspace_dbpass}@#{DSpaceCSV::Conf.dspace_db}/dspace"
  
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "app"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib", "dspace_csv"))
Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")) { |lib| require File.basename(lib, ".*") }
Dir.glob(File.join(File.dirname(__FILE__), "app", "**", "*.rb")) { |app| require File.basename(app, ".*") }
