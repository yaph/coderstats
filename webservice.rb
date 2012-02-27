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
