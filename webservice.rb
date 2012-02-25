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

  def get_data(url)
    resp = self.request(url)
    data = JSON.parse(resp.body)
    if ('Hash' == data.class.to_s && data.has_key?('message')) || ('Array' == data.class.to_s && data.empty?)
      return nil
    end
    return data
  end


  def get_user(name)
    url = "https://api.github.com/users/#{name}"
    return self.get_data(url)
  end


  def get_user_repos(user)
    page = 1
    repos = []
    repocount = user['gh_public_repos']
    login = user['gh_login']
    while repocount > 0
      url = "https://api.github.com/users/#{login}/repos?per_page=100&page=#{page}"
      data = self.get_data(url)
      if data
        repos |= data
      end
      page += 1
      repocount -= 100
    end
    return repos
  end

end
