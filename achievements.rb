class Achievements

  def initialize
    @achievements = {
      'ownedlangs' => {
        'min' => 6,
        'title' => 'Hyperpolyglot',
        'desc' => 'At least 6 different languages across owned repositories'
      },
      'ownedforks' => {
        'min' => 50,    # FIXME should be bigger than number of owned repos, e.g. twice as much
        'title' => 'Influencer',
        'desc' => 'At least 50 forks across owned repositories'
      },
      'ownedwatchers' => {
        'min' => 50,    # FIXME should be bigger than number of owned repos, e.g. twice as much
        'title' => 'Broadcaster',
        'desc' => 'At least 50 watchers across owned repositories'
      }
      #Rubyist, Pythonista
    }
  end

  def get_user_achievements(user)
    return if !user['value']

    @achievements.each do |achievement, definition|
      next if !user['value'][achievement]

      if (user['value'][achievement] >= definition['min'])
        user['achievements'] = {} if !user['achievements']
        user['achievements'][definition['title']] = definition['desc']
      end
    end

    return user
  end

end
