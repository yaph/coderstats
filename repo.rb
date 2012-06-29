class Repo < Database

  def initialize(db)
    @db = db
    @coll = db.collection('repos')
  end

  # map data to fields currently only works with github data
  def get_user_repo_hash(user, data)
    return {
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
      'name' => data['name'],   # a unique name for a user repo
      'html_url' => data['html_url'],
      'description' => data['description']
    }
  end

  def create_user_repo(user, data)
    repo = self.get_user_repo_hash(user, data)
    @coll.insert(repo)
    return repo
  end

  # repo data is automatically updated
  def update_user_repo(user, repo)
    @coll.update(
      {'user_id' => user['_id'], 'name' => repo['name']},
      self.get_user_repo_hash(user, repo),
      {:upsert => true})
  end

  def get_user_repos(user)
    return @coll.find({'user_id' => user['_id']}).to_a
  end

  def delete_user_repo(user, repo)
    return @coll.remove({'user_id' => user['_id'], 'name' => repo['name']})
  end

end
