#!/usr/bin/env ruby
require 'rack/timeout'
require 'sinatra'
require 'sinatra/basic_auth'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require_relative "./environment"

mime_type :csv, 'application/csv'

enable :sessions

protect  do
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
    DSpaceCSV::Uploader.clean(1)
    u = DSpaceCSV::Uploader.new(params)
    e = DSpaceCSV::Expander.new(u)
    t = DSpaceCSV::Transformer.new(e)
    session[:path] = t.path
    redirect '/upload_result'
  end

  post '/submit' do
  end

  get '/upload_result' do
    haml :upload_result
  end
end

authorize do |username, password|
  DSpaceCSV.authenticate(username, password)
end
