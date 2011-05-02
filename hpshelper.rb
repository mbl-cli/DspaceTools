require "lib/dspace_csv"

require 'rubygems'
require "fileutils"
require "bundler/setup"

require "sinatra"
require "erb"

get '/' do
    erb :index
end

get '/formatting_rules' do
    erb :rules
end

get 'template.csv' do
    send_file 'template.csv', :type => :csv
end

post '/upload' do
    string = params["file"][:tempfile].read
    filename = params["file"][:filename]
    csv = DSpaceCSV.new(string, filename)
    zip = csv.transform_rows
    send_file zip, :type => :zip, :filename => "xml_files.zip"
end
