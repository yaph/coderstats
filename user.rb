class User

  def initialize(db)
    @db = db
    @coll = db.collection('users')

    # Github specific fields are prefixed with gh_ and automatically updated
    @user = {
      'gh_login' => nil,        # only required field at the moment
      'login' => nil,           # can be set after user logged in
      'name' => nil,
      'email' => nil,           # not displayed publicly
      'avatar_url' => nil,
      'show_avatar' => true,
      'opted_out' => false,
      'homepage' => nil,
      'location' => nil,
      'hireable' => nil,
      'company' => nil,
      'gh_followers' => nil,
      'gh_type' => nil,
      'public_gists' => nil,
      'gh_following' => nil,
      'gh_public_repos' => nil,
      'gh_html_url' => nil,
      'gh_created_at' => nil
    }
  end


  def get(user)

  end


  def create(data)

  end


  def update(user, data)

  end

end
