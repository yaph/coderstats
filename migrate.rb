require 'rubygems'
require './webservice.rb'
require './db.rb'
require './user.rb'
require './repo.rb'

$db = Database.new().connect()

def get_set_user(gh_login)
  user = User.new($db)
  dbuser = user.get(gh_login)
  if dbuser
    return dbuser
  end

  # load from web service
  gh = Github.new()
  ghuser = gh.get_user(gh_login)
  if ghuser.nil?
    return nil
  end

  # create user in users collection
  return user.create(ghuser)
end


def get_set_repos(user)
  repo = Repo.new($db)
  user_repos = repo.get_user_repos(user)
  if !user_repos.empty?
    return user_repos
  end

  gh = Github.new()
  ghrepos = gh.get_user_repos(user)
  if ghrepos.empty?
    return nil
  end

  # create user repos and return array
  dbrepos = []
  ghrepos.each { |r| dbrepos.push repo.create_user_repo(user, r) }
  return dbrepos
end

ghcoll = $db.collection('github')
ghdata = ghcoll.find({}, :sort => ['updated_at', -1], :limit => 50)

ghdata.each do|u| 
  gh_login = u['login']
  user = get_set_user(gh_login)
  if user
    repos = get_set_repos(user)
  end
  ghcoll.remove({:_id => u['_id']});
end
