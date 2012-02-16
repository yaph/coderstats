get '/' do
  liquid :index
end


get '/coderstats' do
  stats = nil

  begin
    stats = cw_user(params[:cwuser])
    liquid :coderstats, :locals => { :stats => stats }
  rescue => e
    liquid :'404'
  end

end


get '/testdb' do
  require './db.rb'

end


def cw_user(user)
  url = "http://coderwall.com/#{user}.json"
  resp = Net::HTTP.get_response(URI.parse(url))

  # if response body is empty
  if resp.body.strip.length == 0
    raise "web service error"
  end
  
  result = JSON.parse(resp.body)
  return result
end
