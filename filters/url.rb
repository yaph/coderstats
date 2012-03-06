require 'uri'

module URLFilter
  # add http:// if no protocol at beginning of url
  def url(input)
    input = input.strip
    if !input.strip.empty? and 0 != input.index(/\w+?:\/\//)
      input = 'http://' + input
    end
    input
  end

  # host part of URL
  def host(input)
    if !input.strip.empty?
      input = URI(url(input)).host
    end
  end
end
