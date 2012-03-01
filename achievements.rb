class Achievements

  def set_user_achievements(user)
    return user unless user['stats']
    user['achievements'] = {}
    self.methods.grep(/achievement_/).each {|method| self.send(method, user)}
    return user
  end


  def achievement_broadcaster(user)
    repos = user['stats']['counts']['owned']['total']
    watchers = user['stats']['counts']['owned']['watchercount']
    if repos and watchers and watchers >= 6 * repos
      user['achievements']['Broadcaster'] = "At least 6 times as many watchers (#{watchers}) as repos (#{repos}) across owned repositories."
    end
  end


  def achievement_hyperpolyglot(user)
    langs = user['stats']['counts']['owned']['langcount']
    if langs and langs >= 6
      user['achievements']['Hyperpolyglot'] = 'At least 6 different languages across owned repositories.'
    end
  end


  def achievement_influencer(user)
    repos = user['stats']['counts']['owned']['total']
    forks = user['stats']['counts']['owned']['forkcount']
    if repos and forks and forks >= 3 * repos
      user['achievements']['Influencer'] = "At least 3 times as many forks (#{forks}) as repos (#{repos}) across owned repositories."
    end
  end


  def achievement_masterofchaos(user)
    langs = user['stats']['counts']['owned']['total']
    if langs and langs >= 200
      user['achievements']['Master of Chaos'] = 'At least 200 owned repositories.'
    end
  end


  def achievement_pythonista(user)
    return user unless user['stats']['counts']['owned']['languages']
    python = user['stats']['counts']['owned']['languages']['Python']
    if python and python >= 5
      user['achievements']['Pythonista'] = 'At least 5 owned repositories with Python as the main language.'
    end
  end


  def achievement_rubyist(user)
    return user unless user['stats']['counts']['owned']['languages']
    ruby = user['stats']['counts']['owned']['languages']['Ruby']
    if ruby and ruby >= 5
      user['achievements']['Rubyist'] = 'At least 5 owned repositories with Ruby as the main language.'
    end
  end

end
