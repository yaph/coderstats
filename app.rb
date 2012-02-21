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

      def set_error
        liquid :error, :locals => { :message => env['sinatra.error'].message, :title => 'Error' }
      end
    end


    not_found do
      set_error
    end


    error do
      set_error
    end


    get '/' do
      liquid :index, :locals => {
        :title => 'Coderstats - Get statistics for your Github code'
      }
    end


    get '/coderstats' do
      redirect '/coder/%s' % params[:ghuser]
    end


    get '/coder/:ghuser' do
      stats = nil
      begin
        ghlogin = params[:ghuser]
        ghcoll = settings.db.collection('github')
        ghdata = ghcoll.find_one({ :login => ghlogin })
        now = Time.now.utc

        # check whether data exists or is outdated, i.e. older than a week = 604800 seconds
        if ghdata.nil? || now - ghdata['updated'] > 604800
          gh = Github.new()

          ghuser = gh.get_user(ghlogin)
          if ghuser.nil?
            raise "no user data: %s" % ghlogin
          end

          ghrepos = gh.get_user_repos(ghuser)
          if ghrepos.empty?
            raise "no user repos: %s" % ghlogin
          end

          doc = { :login => ghlogin, :user => ghuser, :repos => ghrepos, :updated => now }

          if ghdata && ghdata['_id']
            oid = ghdata['_id']
            doc[:created] = ghdata['created']
            ghcoll.update({'_id' => oid}, doc)
          else
            # no user data exists so far
            doc[:created] = now
            oid = ghcoll.insert(doc)
          end

          ghdata = ghcoll.find_one({ :_id => oid })
        end

        repos = ghdata['repos']
        stats = get_stats(repos)
        liquid :coder, :locals => {
          :ghrepos => repos,
          :languages => stats[:languages],
          :user => ghdata['user'],
          :title => 'Code statistics for Github user %s' % ghlogin
        }
      rescue => e
        log = Logger.new(STDOUT)
        log.error(e.message)
        raise Sinatra::NotFound, 'No data for user %s' % ghlogin
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
