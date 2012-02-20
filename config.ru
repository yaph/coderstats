require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra_auth_github'
require './app.rb'

run Coderstats::App
