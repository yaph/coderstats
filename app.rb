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
    end


    get '/' do
      liquid :index
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
