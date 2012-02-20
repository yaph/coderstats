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
        stats = Hash.new(0)
        stats[:languages] = Hash.new(0)
        repos.each do |repo|
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


    get '/' do
      liquid :index
    end


    get '/coderstats' do
      stats = nil
      begin
        ghuser = params[:ghuser]
        ghcoll = settings.db.collection('github')
        ghdata = ghcoll.find_one({ :user => ghuser })
        repos = ghdata['repos']
        stats = get_stats(repos)
#        out = ""
#        stats[:languages].each { |l, c| out += l.to_s }
#        return out
        liquid :coderstats, :locals => { :ghrepos => repos, :languages => stats[:languages] }
      rescue => e
        log = Logger.new(STDOUT)
        log.error(e)
        liquid :'404'
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
