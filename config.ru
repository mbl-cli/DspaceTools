require './application.rb'

set :environment, :development

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run DspaceToolsUi.new
