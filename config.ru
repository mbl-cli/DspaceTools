require 'rubygems'
require 'sinatra'

set :env, :production
disable :run

require 'application'

run Sinatra::Application

