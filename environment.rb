require "sinatra"
require "fileutils"
require "bundler/setup"
require "erb"
require "haml"
require "nokogiri"
require "zip/zip"
require "csv"
require "active_record"
require "rest-client"
require "logger"


class DSpaceCSV
  #set environment
  environment = ENV["RACK_ENV"] || ENV["RAILS_ENV"]
  set :environment, (environment && ["production", "test", "development"].include?(environment.downcase)) ? environment.downcase.to_sym : :development

  conf_data = YAML.load(open(File.join(File.dirname(__FILE__), "config", "config.yml")).read)
  Conf = OpenStruct.new(
    :root_path => File.dirname(__FILE__),
    :tmp_dir => conf_data['tmp_dir'],
    :remote_tmp_dir => conf_data['remote_tmp_dir'],
    :dspace_repo => conf_data['dspace_repo'],
    :dspace_path => conf_data['dspace_path'],
    :remote_login => conf_data['remote_login'],
    :dspacedb => conf_data['dspacedb'][settings.environment.to_s],
    :localdb => conf_data['localdb'][settings.environment.to_s],
    :users => YAML.load(open(File.join(File.dirname(__FILE__), "config", "users.yml")).read),
    :valid_fields => YAML.load(open(File.join(File.dirname(__FILE__), "config", "valid_fields.yml")).read).map { |f| f.strip },
  )

##### Connect Databases #########  
  ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  ActiveRecord::Base.establish_connection(Conf.localdb)

  class DspaceDb
    class Base < ActiveRecord::Base
      self.abstract_class = true
    end
  end

  DspaceDb::Base.logger = Logger.new(STDOUT, :debug)
  DspaceDb::Base.establish_connection(Conf.dspacedb)
#################################

end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "app"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib", "dspace_csv"))
Dir.glob(File.join(File.dirname(__FILE__), "app", "**", "*.rb")) { |app| require File.basename(app, ".*") }
Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")) { |lib| require File.basename(lib, ".*") }
