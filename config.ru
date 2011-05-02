require 'rubygems'
require 'sinatra'

set :env, :production
disable :run

require 'hpshelper'

run Sinatra::Application

