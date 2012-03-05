class Achievements

  def set_user_achievements(user)
    user['achievements'] = {}
    if user['stats']
      self.methods.grep(/achievement_/).each {|method| self.send(method, user)}
    end
    self.methods.grep(/others_/).each {|method| self.send(method, user)}
    return user
  end


  def check_lang_min(user, lang, min)
    if user['stats']['counts']['owned']['languages'] and user['stats']['counts']['owned']['languages'][lang]
      return user['stats']['counts']['owned']['languages'][lang] >= min
    end
    return false
  end


  def achievement_broadcaster(user)
    repos = user['stats']['counts']['owned']['total']
    watchers = user['stats']['counts']['owned']['watchercount']
    if repos and watchers and watchers > 50 and watchers >= 6 * repos
      user['achievements']['Broadcaster'] = "At least 50 watchers and 6 times as many watchers (#{watchers}) as repos (#{repos}) across owned repositories."
    end
  end


  def achievement_hyperpolyglot(user)
    langs = user['stats']['counts']['owned']['langcount']
    if langs and langs >= 6
      user['achievements']['Hyperpolyglot'] = "At least 6 different languages (#{langs}) across owned repositories."
    end
  end


  def achievement_influencer(user)
    repos = user['stats']['counts']['owned']['total']
    forks = user['stats']['counts']['owned']['forkcount']
    if repos and forks and forks > 50 and forks >= 3 * repos
      user['achievements']['Influencer'] = "At least 50 forks and 3 times as many forks (#{forks}) as repos (#{repos}) across owned repositories."
    end
  end


  def achievement_masterofchaos(user)
    total = user['stats']['counts']['owned']['total']
    if total and total >= 200
      user['achievements']['Master of Chaos'] = "At least 200 owned repositories (#{total})."
    end
  end


  def achievement_jsninja(user)
    if self.check_lang_min(user, 'JavaScript', 5)
      user['achievements']['JavaScript Ninja'] = 'At least 5 owned repositories with JavaScript as the main language.'
    end
  end


  def achievement_perlmonk(user)
    if self.check_lang_min(user, 'Perl', 5)
      user['achievements']['Perl Monk'] = 'At least 5 owned repositories with Perl as the main language.'
    end
  end


  def achievement_pythonista(user)
    if self.check_lang_min(user, 'Python', 5)
      user['achievements']['Pythonista'] = 'At least 5 owned repositories with Python as the main language.'
    end
  end


  def achievement_rubyist(user)
    if self.check_lang_min(user, 'Ruby', 5)
      user['achievements']['Rubyist'] = 'At least 5 owned repositories with Ruby as the main language.'
    end
  end


  # Achievements that don't depend on stats
  def others_bdfl(user)
    case user['gh_login']
      when 'dhh', 'jeresig', 'rlerdorf', 'TimToady', 'torvalds'
        user['achievements']['BDFL'] = 'Benevolent Dictator for Life'
    end
  end

end
