require 'sinatra'
require 'fileutils'
require 'bundler/setup'
require 'erb'
require 'haml'
require 'zen-grids'
require 'nokogiri'
require 'zip/zip'
require 'csv'
require 'active_record'
require 'rest-client'
require 'logger'
require 'redcloth'


class DspaceTools < Sinatra::Base
  #set environment
  environment = ENV['RACK_ENV'] || ENV['RAILS_ENV']
  environment = (environment &&
    ['production', 'test', 'development'].include?(environment.downcase)) ?
    environment.downcase.to_sym : :development
  set :environment, environment

  conf = open(File.join(File.dirname(__FILE__), 'config', 'config.yml')).read
  conf_data = YAML.load(conf)
  Conf = OpenStruct.new(
    root_path: File.dirname(__FILE__),
    tmp_dir: conf_data['tmp_dir'],
    dropbox_dir: conf_data['dropbox_dir'],
    bitstream_path: conf_data['bitstream_path'],
    session_secret: conf_data['session_secret'],
    dspace_repo: conf_data['dspace_repo'],
    dspace_path: conf_data['dspace_path'],
    dspacedb: conf_data['dspacedb'][settings.environment.to_s],
    localdb: conf_data['localdb'][settings.environment.to_s],
    valid_fields: YAML.load(open(File.join(File.dirname(__FILE__),
                                              'config', 'valid_fields.yml')).
                                              read).map { |f| f.strip },
  )

  ##### Connect Databases #########
  ActiveRecord::Base.logger = Logger.new(STDOUT, :debug)
  ActiveRecord::Base.establish_connection(Conf.localdb)

  Thread.new do
    loop do
      sleep(60*30);
      ActiveRecord::Base.verify_active_connections!
    end
  end.priority = -10

  class DspaceDb
    class Base < ActiveRecord::Base
      self.abstract_class = true
    end
  end

  DspaceDb::Base.logger = Logger.new(STDOUT, :debug)
  DspaceDb::Base.establish_connection(Conf.dspacedb)
  #################################
end


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app', 'models'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app', 'routes'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib', 'dspace_tools'))

require 'base'
Dir.glob(File.join(File.dirname(__FILE__), 'app', '**', '*.rb')) do |app|
  require File.basename(app, '.*')
end

Dir.glob(File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')) do |lib|
  require File.basename(lib, '.*')
end
