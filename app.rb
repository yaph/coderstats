require 'logger'
require './webservice.rb'
require './db.rb'
require './user.rb'
require './repo.rb'
require './stats.rb'

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

      def set_error
        liquid :error, :locals => {
          :message => env['sinatra.error'].message, :title => 'Error'
        }
      end


      def get_set_user(gh_login)
        # 1st try to load user from users collection
        user = User.new(settings.db)
        dbuser = user.get(gh_login)
        if dbuser
          return dbuser
        end

        # load from web service
        gh = Github.new()
        ghuser = gh.get_user(gh_login)
        if ghuser.nil?
          raise "no user data: %s" % gh_login
        end

        # create user in users collection
        return user.create(ghuser)
      end


      def get_set_repos(user)
        repo = Repo.new(settings.db)
        user_repos = repo.get_user_repos(user)
        if !user_repos.empty?
          return user_repos
        end

        gh = Github.new()
        ghrepos = gh.get_user_repos(user)
        if ghrepos.empty?
          return nil
        end

        # create user repos and return array
        dbrepos = []
        ghrepos.each { |r| dbrepos.push repo.create_user_repo(user, r) }
        return dbrepos
      end

    end


    not_found do
      set_error
    end


    error do
      set_error
    end


    get '/' do
      ghcoll = settings.db.collection('users')
      ghdata = ghcoll.find({}, :sort => ['updated_at', -1], :limit => 12)
      liquid :index, :locals => {
        :latest => ghdata.to_a,
        :title => 'Coderstats - Get statistics for your Github code'
      }
    end


    get '/about' do
      liquid :about, :locals => {:title => 'About Coderstats'}
    end


    get '/coderstats' do
      redirect '/coder/%s' % params[:ghuser]
    end


    get '/coder/:ghuser' do
      stats = nil
      begin
        gh_login = params[:ghuser]
        # set defaulttab here to avaid logic in template
        defaulttab = 'owned'
        # get user and repo data from db or web service
        user = get_set_user(gh_login)
        repos = get_set_repos(user)
        if repos
          stats = Stats.new.get(repos)
          if stats['all']['total'] > 0 and stats['owned']['total'] == 0
            defaulttab = 'forked'
          end
        end
        liquid :coder, :locals => {
          :user => user,
          :stats => stats,
          :defaulttab => defaulttab,
          :title => 'Code statistics for Github user %s' % gh_login
        }
      rescue => e
        log = Logger.new(STDOUT)
        log.error(e.message)
        raise Sinatra::NotFound, 'No data for user %s' % gh_login
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
