class User

  def initialize(db)
    @db = db
    @coll = db.collection('users')

    # Github specific fields are prefixed with gh_ and automatically updated
    @user = {
      'login' => nil,           # can be set after user logged in
      'created_at' => nil,
      'updated_at' => nil,
      'name' => nil,
      'email' => nil,           # not displayed publicly
      'avatar_url' => nil,
      'show_avatar' => true,
      'opted_out' => false,
      'homepage' => nil,
      'location' => nil,
      'hireable' => nil,
      'company' => nil,
      'gh_login' => nil,        # only required field at the moment
      'gh_followers' => nil,
      'gh_type' => nil,
      'gh_public_gists' => nil,
      'gh_following' => nil,
      'gh_public_repos' => nil,
      'gh_html_url' => nil,
      'gh_created_at' => nil
    }
  end


  def get(gh_login)
    return @coll.find_one({ 'gh_login' => gh_login })
  end


  # currently only works with github data
  def create(data)
    now = Time.now.utc
    @user['created_at'] = now
    @user['updated_at'] = now
    
    # map data to fields
    @user['gh_login'] = data['login']
    @user['name'] = data['name']
    @user['email'] = data['email']
    @user['avatar_url'] = data['avatar_url']
    @user['homepage'] = data['blog']
    @user['location'] = data['location']
    @user['hireable'] = data['hireable']
    @user['company'] = data['company']
    @user['gh_followers'] = data['followers']
    @user['gh_type'] = data['type']
    @user['gh_public_gists'] = data['public_gists']
    @user['gh_following'] = data['following']
    @user['gh_public_repos'] = data['public_repos']
    @user['gh_html_url'] = data['html_url']
    @user['gh_created_at'] = data['created_at']

    return @coll.find_one({ '_id' => @coll.insert(@user) })
  end


  def update(user, data)
    user['updated_at'] = Time.now.utc

    # update github specific fields except created_at
    user['gh_followers'] = data['followers']
    user['gh_type'] = data['type']
    user['gh_public_gists'] = data['public_gists']
    user['gh_following'] = data['following']
    user['gh_public_repos'] = data['public_repos']
    user['gh_html_url'] = data['html_url']

    @coll.update({ '_id' => user['id'] }, user)
    return user
  end

end
