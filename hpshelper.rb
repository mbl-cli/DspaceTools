require "bundler/setup"

require "sinatra"
require "erb"

get '/' do
    erb :index
end

post '/upload' do
    unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
        erb :upload
    end
    while blk = tmpfile.read(65536)
        File.open(File.join(Dir.pwd,"public/uploads", name), "wb") { |f| f.write(tmpfile.read) }
    end
end
