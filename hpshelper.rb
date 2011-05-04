require "./lib/dspace_csv"
require "fileutils"
require "bundler/setup"

require "sinatra"
require "erb"

mime_type :csv, 'application/csv'

get '/' do
    erb :index
end

get '/formatting-rules' do
    erb :rules
end

get '/stsrepository-instructions' do
    erb :sts
end

get '/extra-help' do
    erb :help
end

get 'template.csv' do
    content_type :csv
    send_file 'template.csv'
end

post '/upload' do
    string = params["file"][:tempfile].read
    filename = params["file"][:filename]
    csv = DSpaceCSV.new(string, filename)
    zip = csv.transform_rows
    send_file zip, :type => :zip, :filename => "xml_files.zip"
end
