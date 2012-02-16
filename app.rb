def cw_user(user)
   url = "http://coderwall.com/#{user}.json"
   resp = Net::HTTP.get_response(URI.parse(url))
   result = JSON.parse(resp.body)

   # if the hash has 'Error' as a key, we raise an error
   if result.has_key? 'Error'
      raise "web service error"
   end
   return resp.body
end

get '/' do
    "the time where this server lives is #{Time.now}
    <br /><br />check out your <a href=\"/agent\">user_agent</a>"
end

get '/test' do
    cw_user('ramiro')
end

get '/agent' do
    "you're using #{request.user_agent}"
end
