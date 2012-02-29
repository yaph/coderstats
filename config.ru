require 'rubygems'
require 'bundler'
Bundler.require

require 'omniauth'
require 'omniauth-github'
require './app.rb'

run Coderstats::App
