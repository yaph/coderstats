class Repo < Database

  def initialize(db)
    @db = db
    @coll = db.collection('repos')
  end

  # currently only works with github data
  def create_user_repo(user, data)
    # map data to fields
    repo = {
      'user_id' => user['_id'],
      'open_issues' => data['open_issues'],
      'watchers' => data['watchers'],
      'pushed_at' => data['pushed_at'],
      'homepage' => data['homepage'],
      'git_url' => data['git_url'],
      'updated_at' => data['updated_at'],
      'fork' => data['fork'],
      'forks' => data['forks'],
      'language' => data['language'],
      'private' => data['private'],
      'size' => data['size'],
      'clone_url' => data['clone_url'],
      'created_at' => data['created_at'],
      'name' => data['name'],
      'html_url' => data['html_url'],
      'description' => data['description']
    }

    @coll.insert(repo)
    return repo
  end


  # repo data is automatically updated
  def update_user_repo(repo, data)

  end


  def get_user_repos(user)
    return @coll.find({ 'user_id' => user['_id'] }).to_a
  end


  def get_user_repo(repo)

  end

end
