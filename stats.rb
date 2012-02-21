class Stats

  def initialize
    @stats = {
      'owned' => {'languages' => {}, 'total' => 0},
      'forked' => {'languages' => {}, 'total' => 0},
      'all' => {'languages' => {}, 'total' => 0}
    }
  end


  def get(repos)
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

    # sort languages by number of repos
    @stats.each do |idx, lang|
      @stats[idx]['languages'] = @stats[idx]['languages'].sort_by { |k, v| v.size }.reverse
    end

    return @stats
  end


  def set_repo_stat(index, repo)
    @stats[index]['total'] += 1
    lang = repo['language']
    if @stats[index]['languages'].has_key?(lang)
      @stats[index]['languages'][lang].push(repo)
    else
      @stats[index]['languages'][lang] = [repo]
    end
  end

end
