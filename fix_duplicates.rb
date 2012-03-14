require 'rubygems'
require './db.rb'

# find duplicate users
#var gh_login;
#db.users.find( {"gh_login":{$exists:true} }, {"gh_login":1} ).sort( {"gh_login":1} ).forEach( function(current) {
#  if(current.gh_login == gh_login){
#    db.duplicates.update( {"_id":current.gh_login}, { "$inc":{count:1} }, true);
#  }
#  gh_login = current.gh_login;
#});

db = Database.new().connect()
db.collection('duplicates').find.each do |dup|
  db.collection('users').find({'gh_login' => dup['_id']}).each do |user|
    uid = user['_id']
    db.collection('repos').remove({'user_id' => uid})
    db.collection('achievements').remove({'user_id' => uid})
    db.collection('stats_users').remove({'user_id' => uid})
    # finally remove from users collection
    db.collection('users').remove({'_id' => uid})
  end
end
