require 'logger'
require './webservice.rb'
require './db.rb'

get '/' do
  liquid :index
end


get '/coderstats' do
  stats = nil

  begin
    gh = Github.new()
    ghuser = params[:ghuser]
    ghrepos = gh.get_user_repos(ghuser)

    db = Database.new().connect()
    ghcoll = db.collection('github')
    ghcoll.insert({ :user => ghuser, :repos => ghrepos, :updated => Time.now.utc })

    liquid :coderstats, :locals => { :ghrepos => ghrepos }
  rescue => e
    log = Logger.new(STDOUT)
    log.error(e)
    liquid :'404'
  end

end


get '/testdb' do
  db = Database.new().connect()
  ghcoll = db.collection('github')
  data = ''
  ghcoll.find_one({ :user => 'yaph' }).each { |row| data += row.inspect }
  return data
end


def get_user_from_db(name)

end
