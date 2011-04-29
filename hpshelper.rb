require "./lib/dspace_csv"
require "fileutils"
require "bundler/setup"

require "sinatra"
require "erb"

get '/' do
    erb :index
end

post '/upload' do
    puts params.inspect
    string = params["file"][:tempfile].read
    filename = params["file"][:filename]
    csv = DSpaceCSV.new(string, filename)
    zip = csv.transform_rows
    send_file zip, :type => :zip
    File.unlink(zip)
end

# load the csv into this csv
# do some sanity checks
# export
