require 'logger'
require './webservice.rb'
require './db.rb'

get '/' do
  liquid :index
end


get '/coderstats' do
  stats = nil

  begin
    cw = Coderwall.new()
    cwuser = cw.get_user(params[:cwuser])
    gh = Github.new()
    ghrepos = gh.get_user_repos(params[:ghuser])

#    db = Database.new().connect()
#    ghcoll = db.collection('github')
#    ghcoll.insert(ghrepos)

    liquid :coderstats, :locals => { :cwuser => cwuser, :ghrepos => ghrepos }
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
  ghcoll.find('language' => 'Python').each { |row| data += row.inspect }
  return data
end
