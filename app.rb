require 'logger'
#require 'yaml'
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

    # TODO read titles and descriptions from yaml file
#    set :config, YAML.load_file('./config.yml')

#    set :ghsettings, settings.db.collection('settings').find_one()
#    use OmniAuth::Strategies::GitHub, settings.ghsettings['gh_client_id'], settings.ghsettings['gh_secret']

    before do
      # set liquid template include files path and extensions
      Liquid::Template.file_system = Liquid::LocalFileSystem.new('views/includes')
      Liquid::Template.register_filter(URLFilter)
    end


    helpers do

      def set_error(message = 'Not Found')
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


      def validate(params)
        # string of word characters and hyphens that has to start with a word character
        regex_string = /^\w[\w-]*$/
        msg_error = 'Input is not valid'
        ['gh_login', 'path', 'width', 'height', 'badge_title', 'badge_type'].each do |key|
          if params.has_key?(key)
            val = params[key].strip
            params[key] = val
            if 'badge_type' == key
              raise Sinatra::NotFound, msg_error unless 'achievements' == val
            else
              raise Sinatra::NotFound, msg_error unless val =~ regex_string
            end
          end
        end
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
      # validation done in redirect handler
      redirect '/coder/%s' % params[:gh_login]
    end


    get '/coder/:gh_login' do
      stats = nil
      # validate before begin so in case of validation errors appropriate message is shown
      validate(params)
      begin
        gh_login = params[:gh_login]

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


    get '/ranking/:path' do
      validate(params)
      user = User.new(settings.db)
      coll = settings.db.collection('stats_users')
      case params[:path]
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


    get '/graph/hyperpolyglot-coder-languages' do
      liquid :languagegraph, :locals => {:languagegraph => true}
    end


    get '/badge/:gh_login/achievements' do
      validate(params)
      url = request.scheme + '://' + request.host
      url += ':' + request.port.to_s if 80 != request.port
      url += '/iframe/' + params[:gh_login] + '/achievements'
      url += '?badge_title=' + params[:badge_title] if params[:badge_title]
      liquid :achievements_js, :layout => false, :locals => {
        :url => url,
        :width => params[:width] || '300px',
        :height => params[:height] || '250px'
      }
    end


    get '/iframe/:gh_login/achievements' do
      validate(params)
      user = settings.db.collection('achievements').find_one({ 'gh_login' => params[:gh_login] })
      liquid :achievements_iframe, :layout => false, :locals => {
        :user => user,
        :badge_title => params[:badge_title] || 'show'
      }
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
#      gh_login = gh_user_info['gh_login']
#      see http://www.sinatrarb.com/contrib/cookies.html
#      liquid :index, :locals => {:title => "Hello #{gh_login}"}
#    end

  end
end
