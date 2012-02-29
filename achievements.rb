class Achievements

  def initialize
    @achievements = {
      'langcount' => {
        'min' => 6,
        'title' => 'Hyperpolyglot',
        'desc' => 'At least 6 different languages across owned repositories'
      },
      'forkcount' => {
        'min' => 50,    # FIXME should be bigger than number of owned repos, e.g. twice as much
        'title' => 'Influencer',
        'desc' => 'At least 50 forks across owned repositories'
      },
      'watchercount' => {
        'min' => 50,    # FIXME should be bigger than number of owned repos, e.g. twice as much
        'title' => 'Broadcaster',
        'desc' => 'At least 50 watchers across owned repositories'
      }
      #Rubyist, Pythonista
    }
  end

  def set_user_achievements(user)
    return if !user['stats']

    @achievements.each do |achievement, definition|
      next if !user['stats']['counts']['owned'][achievement]

      if (user['stats']['counts']['owned'][achievement] >= definition['min'])
        user['achievements'] = {} if !user['achievements']
        user['achievements'][definition['title']] = definition['desc']
      end
    end

    return user
  end

end
