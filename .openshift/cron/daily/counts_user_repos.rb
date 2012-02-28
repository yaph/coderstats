require 'rubygems'
require 'logger'
require '../../../db.rb'

db = Database.new().connect()
coll = db.collection('counts_user_repos')
coll.find().each do |counts|
  puts counts.inspect
end
