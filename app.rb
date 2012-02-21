require 'logger'
require './webservice.rb'
require './db.rb'

module Coderstats
  class App < Sinatra::Base
    enable :sessions

    set :db, Database.new().connect()

    set :ghsettings, settings.db.collection('settings').find_one()

    set :github_options, {
      :secret    => settings.ghsettings['gh_secret'],
      :client_id => settings.ghsettings['gh_client_id']
    }

    register Sinatra::Auth::Github


    helpers do
      def repos
        github_request('user/repos')
      end

      def get_stats(repos)
        # TODO evaluate size, fork, forks, owner, watchers, has_issues, open_issues
        stats = { :languages => {}, :total => 0 }
        repos.each do |repo|
          stats[:total] += 1
          lang = repo['language']
          if stats[:languages].has_key?(lang)
            stats[:languages][lang] += 1
          else
            stats[:languages][lang] = 1
          end
        end
        return stats
      end
    end


    not_found do
      env['sinatra.error'].message
    end


    get '/' do
      liquid :index
    end


    get '/coderstats' do
      stats = nil
      begin
        ghuser = params[:ghuser]
        ghcoll = settings.db.collection('github')
        ghdata = ghcoll.find_one({ :user => ghuser })

        # check whether data exists or is outdated, i.e. older than a week = 604800 seconds
        if ghdata.nil? || Time.now.utc - ghdata['updated'] > 604800
          gh = Github.new()
          ghuser = params[:ghuser]
          ghrepos = gh.get_user_repos(ghuser)

          if ghrepos.empty?
            raise "no data error: %s" % ghuser
          end

          doc = { :user => ghuser, :repos => ghrepos, :updated => Time.now.utc }

          if ghdata && ghdata['_id']
            oid = ghdata['_id']
            ghcoll.update({'_id' => oid}, doc)
          else
            oid = ghcoll.insert(doc)
          end

          ghdata = ghcoll.find_one({ :_id => oid })
        end

        repos = ghdata['repos']
        stats = get_stats(repos)
        liquid :coderstats, :locals => {
          :ghrepos => repos,
          :languages => stats[:languages],
          :total =>  stats[:total]
        }
      rescue => e
        log = Logger.new(STDOUT)
        log.error(e)
        raise Sinatra::NotFound, 'No data for user %s' % ghuser
      end
    end


    get '/login' do
      authenticate!
      "Hello There, #{github_user.name}!#{github_user.token}\n#{repos.inspect}"
    end


    get '/logout' do
      logout!
      redirect 'https://github.com'
    end

  end
end
