require 'rubygems'

PATH = File.expand_path(File.dirname(__FILE__))

require PATH + '/db.rb'
require PATH + '/webservice.rb'
require PATH + '/user.rb'
require PATH + '/repo.rb'
require PATH + '/github.rb'
require PATH + '/stats.rb'

# FIXME move to cron dir and less updates after initial development

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
  ghuser = gh.get_user(u['gh_login'])
  user.update(u, ghuser)
  ghrepos = gh.get_user_repos(u)
  if !ghrepos.empty?
    ghrepos.each { |r| repo.update_user_repo(u, r) }
  end
end
