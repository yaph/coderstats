require 'rubygems'

PATH = File.expand_path(File.dirname(__FILE__))

require PATH + '/db.rb'
require PATH + '/webservice.rb'
require PATH + '/user.rb'
require PATH + '/repo.rb'
require PATH + '/github.rb'
require PATH + '/stats.rb'
require PATH + '/achievements.rb'

record_limit = 20
#lifetime = 604800 # 1 week in seconds
lifetime = 172800 # 2 days in seconds

update_threshold = Time.now.utc - lifetime

db = Database.new().connect()
gh = Github.new(db)
user = User.new(db)
repo = Repo.new(db)
coll_user = user.get_coll

coll_user.find({ 'updated_at' => {'$lt' => update_threshold} }, :sort => 'updated_at').limit(record_limit).each do |u|
  puts 'Fetch Github info for user %s' % u['gh_login']
  gh_user = gh.get_user(u['gh_login'])
  next if gh_user.nil?

  puts 'Updating user %s' % u['gh_login']
  user.update(u, gh_user)
  gh_repos = gh.get_user_repos(u)
  if !gh_repos.empty?
    gh_repos.each { |r| repo.update_user_repo(u, r) }
    u['stats'] = Stats.new.get(gh_repos)
    u = Achievements.new.set_user_achievements(u)
    gh.update_stats(u)
  end
end
