require 'rubygems'
require 'logger'
require './db.rb'
require './github.rb'

record_limit = 10
lifetime = 604800 # 1 week in seconds
update_threshold = Time.now.utc - lifetime

db = Database.new().connect()
gh = Github.new(db)
user = User.new(db)
repo = Repo.new(db)
coll_user = user.get_coll

coll_user.find('updated_at' => {'$lt' => update_threshold}).limit(record_limit).each do |u|
  puts 'Updating user %s' % u['gh_login']
  ghuser = gh.get_user(u['gh_login'])
  user.update(u, ghuser)
  ghrepos = gh.get_user_repos(u)
  if !ghrepos.empty?
    ghrepos.each { |r| repo.update_user_repo(u, r) }
  end
end
