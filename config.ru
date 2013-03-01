require './application.rb'

set :run, false

configure(:production) do 
  puts 'prod'
  FileUtils.mkdir_p 'log' unless File.exists?('log')
  log = File.new("log/sinatra.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run DspaceToolsUi 
