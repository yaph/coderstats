require 'rubygems'

#PATH = File.expand_path(File.dirname(__FILE__))

require './db.rb'
require './webservice.rb'
require './user.rb'
require './repo.rb'
require './github.rb'
require './stats.rb'
require './achievements.rb'

#record_limit = 10
#lifetime = 604800 # 1 week in seconds

# more updates during initial development
record_limit = 20
lifetime = 172800 # 2 days

update_threshold = Time.now.utc - lifetime

db = Database.new().connect()
gh = Github.new(db)
user = User.new(db)
repo = Repo.new(db)
coll_user = user.get_coll

coll_user.find({ 'updated_at' => {'$lt' => update_threshold} }, :sort => 'updated_at').limit(record_limit).each do |u|
  puts 'Updating user %s' % u['gh_login']
  gh_user = gh.get_user(u['gh_login'])
  user.update(u, gh_user)
  gh_repos = gh.get_user_repos(u)
  if !gh_repos.empty?
    gh_repos.each { |r| repo.update_user_repo(u, r) }
    u['stats'] = Stats.new.get(gh_repos)
    u = Achievements.new.set_user_achievements(u)
    gh.update_stats(u)
  end
end
