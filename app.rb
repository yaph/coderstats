require 'logger'
require './db.rb'
require './webservice.rb'
require './user.rb'
require './repo.rb'
require './github.rb'
require './stats.rb'
require './achievements.rb'
require './filters/url.rb'

module Coderstats
  class App < Sinatra::Base
    enable :sessions

    set :db, Database.new().connect()

#    set :ghsettings, settings.db.collection('settings').find_one()
#    use OmniAuth::Strategies::GitHub, settings.ghsettings['gh_client_id'], settings.ghsettings['gh_secret']

    before do
      # set liquid template include files path and extensions
      Liquid::Template.file_system = Liquid::LocalFileSystem.new('views/includes')
      Liquid::Template.register_filter(URLFilter)
    end


    helpers do

      def set_error
        message = 'Not Found'
        if env['sinatra.error']
          message = env['sinatra.error'].message
        end
        liquid :error, :locals => {:message => message, :title => 'Error'}
      end


      def get_top_coders(user, collection, sort_key, order = -1, limit = 5, type = 'User')
        coders = []
        data = collection.find({'gh_type' => type}, :sort => [sort_key, order], :limit => limit)
        data.to_a.each { |r| coders.push(r.merge(user.get_by_id(r['user_id']))) }
        return coders
      end

    end


    not_found do
      set_error
    end


    error do
      set_error
    end


    get '/' do
      user = User.new(settings.db)
      coll = settings.db.collection('stats_users')
      liquid :index, :locals => {
        :users_by_ownedlangs => get_top_coders(user, coll, 'counts.owned.langcount'),
        :users_by_ownedforks => get_top_coders(user, coll, 'counts.owned.forkcount'),
        :users_by_ownedwatchers => get_top_coders(user, coll, 'counts.owned.watchercount'),
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


    get '/ranking/:type' do
      user = User.new(settings.db)
      coll = settings.db.collection('stats_users')
      case params[:type]
        when 'coders-by-language'
          ranking = get_top_coders(user, coll, 'counts.owned.langcount', -1, 30)
          title = 'Top Coders by Number of Languages in Owned Repositories'
          index = 'langcount'
        when 'coders-by-forks'
          ranking = get_top_coders(user, coll, 'counts.owned.forkcount', -1, 30)
          title = 'Top Coders by Number of Forks of Owned Repositories'
          index = 'forkcount'
        when 'coders-by-watchers'
          ranking = get_top_coders(user, coll, 'counts.owned.watchercount', -1, 30)
          title = 'Top Coders by Number of Watchers of Owned Repositories'
          index = 'watchercount'
        when 'organizations-by-language'
          ranking = get_top_coders(user, coll, 'counts.owned.langcount', -1, 30, 'Organization')
          title = 'Top Organizations by Number of Languages in Owned Repositories'
          index = 'langcount'
        when 'organizations-by-forks'
          ranking = get_top_coders(user, coll, 'counts.owned.forkcount', -1, 30, 'Organization')
          title = 'Top Organizations by Number of Forks of Owned Repositories'
          index = 'forkcount'
        when 'organizations-by-watchers'
          ranking = get_top_coders(user, coll, 'counts.owned.watchercount', -1, 30, 'Organization')
          title = 'Top Organizations by Number of Watchers of Owned Repositories'
          index = 'watchercount'
        else
          redirect '/'
      end
      liquid :ranking, :locals => {:ranking => ranking, :title => title, :index => index}
    end


#    get '/badge/:user/:type' do
#      type = params[:type]
#      liquid: type, :layout => false
#    end


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
