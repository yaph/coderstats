require 'logger'
require './db.rb'
require './webservice.rb'
require './user.rb'
require './repo.rb'
require './github.rb'
require './stats.rb'
require './achievements.rb'

module Coderstats
  class App < Sinatra::Base
    enable :sessions

    set :db, Database.new().connect()

#    set :ghsettings, settings.db.collection('settings').find_one()
#    use OmniAuth::Strategies::GitHub, settings.ghsettings['gh_client_id'], settings.ghsettings['gh_secret']


    helpers do

      def set_error
        liquid :error, :locals => {
          :message => env['sinatra.error'].message, :title => 'Error'
        }
      end

    end


    not_found do
      set_error
    end


    error do
      set_error
    end


    get '/' do
      limit = 5
      user = User.new(settings.db)
      ghcoll = settings.db.collection('counts_user_repos')

      users_by_ownedlangs = []
      ghdata = ghcoll.find({}, :sort => ['value.ownedlangs', -1], :limit => limit)
      ghdata.to_a.each { |r| users_by_ownedlangs.push(r.merge(user.get_by_id(r['_id']))) }

      users_by_ownedforks = []
      ghdata = ghcoll.find({}, :sort => ['value.ownedforks', -1], :limit => limit)
      ghdata.to_a.each { |r| users_by_ownedforks.push(r.merge(user.get_by_id(r['_id']))) }

      users_by_ownedwatchers = []
      ghdata = ghcoll.find({}, :sort => ['value.ownedwatchers', -1], :limit => limit)
      ghdata.to_a.each { |r| users_by_ownedwatchers.push(r.merge(user.get_by_id(r['_id']))) }

      liquid :index, :locals => {
        :users_by_ownedlangs => users_by_ownedlangs,
        :users_by_ownedforks => users_by_ownedforks,
        :users_by_ownedwatchers => users_by_ownedwatchers,
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
        gh = Github.new(settings.db)
        user = gh.get_set_user(gh_login)
        repos = gh.get_set_repos(user)

        # set user stats
        stats = Stats.new.get(repos)
        if stats and stats['counts']['all']['total'] > 0 and stats['counts']['owned']['total'] == 0
          defaulttab = 'forked'
        end
        user['stats'] = stats

        # set achievements before updating stats so achievement_count is set
        user = Achievements.new.set_user_achievements(user)

        # TODO after first update cycle after this change, only update stats when a new user was created
        gh.update_stats(user)

        liquid :coder, :locals => {
          :user => user,
          :defaulttab => defaulttab,
          :title => 'Code statistics for Github user %s' % gh_login
        }
      rescue => e
        log = Logger.new(STDOUT)
        log.error(e.message)
        raise Sinatra::NotFound, 'No data for user %s' % gh_login
      end
    end


#    get '/session' do
#      session.inspect
#    end


#    get '/login' do
#      redirect to('/auth/github')
#    end


#    get '/auth/github/callback' do
#      access_token = request.env['omniauth.auth']['credentials']['token']
#      uid = request.env['omniauth.auth']['uid'] # do I need this?
#      gh_user_info = request.env['omniauth.auth']['extra']['raw_info']
#      gh_login = gh_user_info['login']
#      see http://www.sinatrarb.com/contrib/cookies.html
#      liquid :index, :locals => {:title => "Hello #{gh_login}"}
#    end

  end
end
