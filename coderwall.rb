require 'json'
require './webservice.rb'

class Coderwall < WebService

  def get_user(name)
    url = "http://coderwall.com/#{name}.json"
    resp = self.request(url)
    return JSON.parse(resp.body)
  end

end
