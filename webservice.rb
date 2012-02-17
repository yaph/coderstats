require 'net/https'
require 'json'

class WebService

  def request(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if 'https' == uri.scheme
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)
    resp = http.request(request)
    # if response body is empty
    if 0 == resp.body.strip.length
      raise "web service error %s" % url
    end
    return resp
  end

end


class Coderwall < WebService

  def get_user(name)
    url = "http://coderwall.com/#{name}.json"
    resp = self.request(url)
    return JSON.parse(resp.body)
  end

end


class Github < WebService

  def get_user_repos(name)
    url = "https://api.github.com/users/#{name}/repos"
    resp = self.request(url)
    return JSON.parse(resp.body)
  end

end
