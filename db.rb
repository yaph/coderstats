require 'mongo'

class Database

  def initialize
    @dbhost = ENV['OPENSHIFT_NOSQL_DB_HOST']
    @dbport = ENV['OPENSHIFT_NOSQL_DB_PORT']
    @dbuser = ENV['OPENSHIFT_NOSQL_DB_USERNAME']
    @dbpass = ENV['OPENSHIFT_NOSQL_DB_PASSWORD']
  end

  def connect
    db = Mongo::Connection.new(@dbhost, @dbport).db('coderstats')
    auth = db.authenticate(@dbuser, @dbpass)
    return db
  end

end
