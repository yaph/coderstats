require 'uri'

module URLFilter
  # add http:// if no protocol at beginning of url
  def url(input)
    if 0 != input.index(/\w+?:\/\//)
      input = 'http://' + input
    end
    input
  end

  # host part of URL
  def host(input)
    input = URI(url(input)).host
  end
end
