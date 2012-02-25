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
        liquid :error, :locals => { :message => env['sinatra.error'].message, :title => 'Error' }
      end


      def get_set_user(ghlogin)

        # 1st try to load user from users collection
        user = User.new(settings.db)
        dbuser = user.get(ghlogin)
        if dbuser
          return dbuser
        end

        # load from web service
        gh = Github.new()
        ghuser = gh.get_user(ghlogin)
        if ghuser.nil?
          raise "no user data: %s" % ghlogin
        end

        # create user in users collection
        return user.create(ghuser)
      end

    end


    not_found do
      set_error
    end


    error do
      set_error
    end


    get '/' do
      ghcoll = settings.db.collection('github')
      ghdata = ghcoll.find({}, :sort => ['updated', -1], :limit => 12)
      liquid :index, :locals => {:latest => ghdata.to_a, :title => 'Coderstats - Get statistics for your Github code'}
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
        ghlogin = params[:ghuser]
        user = get_set_user(ghlogin)

#        ghrepos = gh.get_user_repos(ghuser)
#        if ghrepos.empty?
#          raise "no user repos: %s" % ghlogin
#        end

        liquid :coder, :locals => {
#          :ghrepos => repos,
#          :stats => Stats.new.get(repos),
          :user => user,
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


    # aggregations

    # 10 latest updated requests
    # db.github.find({}, {"login":1, "updated":1}).sort({"updated":-1}).limit(10)
#    get '/latest' do
#      ghcoll = settings.db.collection('github')
#      ghdata = ghcoll.find({}, :sort => ['updated', -1])
#    end

  end
end
