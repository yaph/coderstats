class Repo < Database

  def initialize(db)
    @db = db
    @coll = db.collection('repos')

    # repo data is automatically updated
    @repo = {
      'user_id' => nil,
      'open_issues' => nil,
      'watchers' => nil,
      'pushed_at' => nil,
      'homepage' => nil,
      'git_url' => nil,
      'updated_at' => nil,
      'fork' => nil,
      'forks' => nil,
      'language' => nil,
      'private' => nil,
      'size' => nil,
      'clone_url' => nil,
      'created_at' => nil,
      'name' => nil,
      'html_url' => nil,
      'description' => nil
    }
  end


  def create(data)

  end


  def update(repo, data)

  end


  def get_user_repos(user)

  end


  def get_user_repo(repo)

  end

end
