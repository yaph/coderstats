require 'logger'
require './db.rb'
require './github.rb'
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
        gh = Github.new(settings.db)
        user = gh.get_set_user(gh_login)
        repos = gh.get_set_repos(user)
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
