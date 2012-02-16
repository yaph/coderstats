require 'rubygems'
require 'mongo'

dbhost = ENV['OPENSHIFT_NOSQL_DB_HOST']
dbport = ENV['OPENSHIFT_NOSQL_DB_PORT']
dbuser = ENV['OPENSHIFT_NOSQL_DB_USERNAME']
dbpass = ENV['OPENSHIFT_NOSQL_DB_PASSWORD']

puts dbhost, dbport, dbuser

db = Mongo::Connection.new(dbhost, dbport).db('coderstats')
auth = db.authenticate(dbuser, dbpass)

db.collection_names.each { |name| puts name }
