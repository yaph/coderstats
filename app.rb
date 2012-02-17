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
    liquid :coderstats, :locals => { :cwuser => cwuser, :ghrepos => ghrepos }
  rescue => e
    log = Logger.new(STDOUT)
    log.error(e)
    liquid :'404'
  end

end


get '/testdb' do
  db = Database.new().connect()
  names = ''
  db.collection_names.each { |name| names += name }
  return names
end
