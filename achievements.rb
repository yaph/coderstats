class Achievements

  def set_user_achievements(user)
    user['achievements'] = {}
    if user['stats']
      self.methods.grep(/achievement_/).each {|method| self.send(method, user)}
    end
    self.methods.grep(/others_/).each {|method| self.send(method, user)}
    return user
  end


  def achievement_languages(user)
    # only consider owned repos for langauge achievements
    return unless user['stats']['counts']['owned']['languages']

    langs = user['stats']['counts']['owned']['languages']

    langnicks = {
      'JavaScript' => 'JavaScript Ninja',
      'Perl' => 'Perl Monk',
      'Python' => 'Pythonista',
      'Ruby' => 'Rubyist'
    }

    mincount = 5
    maxcount = 0
    mainlang = ''
    gh_login = user['gh_login']

    langs.each do |lang, count|
      if count >= mincount
        user['achievements'][lang] = '%s owns at least %d repositories (%d) with %s as the main langauge.' %
          [gh_login, mincount, count, lang]
      end

      if count > maxcount
        mainlang = lang
        maxcount = count
      end
    end

    if mainlang.length > 0 and langnicks.has_key?(mainlang) and maxcount > mincount
      nick = langnicks[mainlang]
      user['stats']['counts']['owned']['mainlang'] = mainlang
      user['achievements'][nick] = '%s is the main langauge in %d of %d repositories owned by %s.' %
        [mainlang, maxcount, user['stats']['counts']['owned']['total'], gh_login]
    end
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


  # Achievements that don't depend on stats
  def others_bdfl(user)
    case user['gh_login']
      when 'dhh', 'jeresig', 'rlerdorf', 'TimToady', 'torvalds'
        user['achievements']['BDFL'] = 'Benevolent Dictator for Life'
    end
  end

end
