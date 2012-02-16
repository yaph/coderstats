require 'rubygems'
require 'json'
require 'net/http'
require 'bundler'
Bundler.require

require './app.rb'
run Sinatra::Application
