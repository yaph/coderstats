class Stats

  def initialize
    @counts = {
      'owned' => {'languages' => {}, 'total' => 0, 'langcount' => 0, 'forkcount' => 0, 'watchercount' => 0},
      'forked' => {'languages' => {}, 'total' => 0, 'langcount' => 0, 'forkcount' => 0, 'watchercount' => 0},
      'all' => {'languages' => {}, 'total' => 0, 'langcount' => 0, 'forkcount' => 0, 'watchercount' => 0}
    }
    @repos = {
      'owned' => {'languages' => {}},
      'forked' => {'languages' => {}},
      'all' => {'languages' => {}}
    }
  end


  def get(repos)
    return nil if repos.nil?

    repos.each do |repo|
      # ignore repos with no code or language set
      next if repo['pushed_at'].nil? || repo['language'].nil?

      self.set_repo_stat('all', repo)
      if repo['fork']
        self.set_repo_stat('forked', repo)
      else
        self.set_repo_stat('owned', repo)
      end
    end

    # sort repo languages by number of repos
    @repos.each do |idx, lang|
      @repos[idx]['languages'] = @repos[idx]['languages'].sort_by { |k, v| v.size }.reverse
    end

    return {'counts' => @counts, 'repos' => @repos}
  end


  def set_repo_stat(index, repo)
    @counts[index]['total'] += 1
    if repo['forks']
      @counts[index]['forkcount'] += repo['forks']
    end
    if repo['watchers']
      @counts[index]['watchercount'] += repo['watchers']
    end
    lang = repo['language']
    if @counts[index]['languages'].has_key?(lang)
      @counts[index]['languages'][lang] += 1
      @repos[index]['languages'][lang].push(repo)
    else
      @counts[index]['langcount'] += 1
      @counts[index]['languages'][lang] = 1
      @repos[index]['languages'][lang] = [repo]
    end
  end

end
