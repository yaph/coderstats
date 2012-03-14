require 'json'

class Github < WebService

  def initialize(db)
    @db = db
    @is_new_user = false
  end


  def is_new_user()
    return @is_new_user
  end


  def get_data(url)
    resp = self.request(url)
    data = JSON.parse(resp.body)
    if ('Hash' == data.class.to_s && data.has_key?('message')) || ('Array' == data.class.to_s && data.empty?)
      return nil
    end
    return data
  end


  def get_user(name)
    return self.get_data("https://api.github.com/users/#{name}")
  end


  def get_user_repos(user)
    page = 1
    repos = []
    repocount = user['gh_public_repos']
    login = user['gh_login']
    while repocount > 0 and page <= 10
      url = "https://api.github.com/users/#{login}/repos?per_page=100&page=#{page}"
      data = self.get_data(url)
      if data
        repos |= data
      end
      page += 1
      repocount -= 100
    end
    return repos
  end


  def get_set_user(gh_login)
    # 1st try to load user from users collection
    user = User.new(@db)
    dbuser = user.get(gh_login)
    return dbuser if dbuser

    # load from web service
    ghuser = self.get_user(gh_login)
    raise "no user data: %s" % gh_login if ghuser.nil?

    # check again if user exists to avoid duplicate entries as a consequence of
    # different character chase, issue #1
    dbuser = user.get(ghuser['login'])
    return dbuser if dbuser

    # create user in users collection
    @is_new_user = true
    return user.create(ghuser)
  end


  def get_set_repos(user)
    repo = Repo.new(@db)
    user_repos = repo.get_user_repos(user)
    return user_repos if !user_repos.empty?

    ghrepos = self.get_user_repos(user)
    return nil if ghrepos.empty?

    # create user repos and return array
    dbrepos = []
    ghrepos.each { |r| dbrepos.push repo.create_user_repo(user, r) }
    return dbrepos
  end


  def update_stats(user)
    return false unless user['stats']

    achievement_count = user['achievements'].count()

    doc = {
      'user_id' => user['_id'],
      'gh_type' => user['gh_type'],
      'counts' => user['stats']['counts'],
      'achievement_count' => achievement_count
    }
    @db.collection('stats_users').update({'user_id' => user['_id']}, doc, {:upsert => true})

    # store achievements in dedicated collection
    if achievement_count > 0
      doc_a = {
        'user_id' => user['_id'],
        'gh_login' => user['gh_login'], # allows querying collection directly for badge display
        'achievements' => user['achievements'] # make all achievements accessible via one key
      }
      @db.collection('achievements').update({'user_id' => user['_id']}, doc_a, {:upsert => true})
    end
  end

end
