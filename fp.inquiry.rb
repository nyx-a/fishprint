
require 'uri'
require 'curb'

class Inquiry
  def initialize host:, port:
    @host = host
    @port = port
  end

  def location
    "http://#{@host}:#{@port}"
  end

  def is_unknown_uri? o
    not uri? o
  end

  def uri? o
    o = URI.encode_www_form_component o
    r = Curl::Easy.http_post(
      "#{location}/q/uri",
      Curl::PostField.content('uri', o)
    )
    r.body=='true' ? true : false
  end

  def is_unknown_digest? o
    not digest? o
  end

  def digest? o
    o = URI.encode_www_form_component o
    r = Curl::Easy.http_post(
      "#{location}/q/digest",
      Curl::PostField.content('digest', o)
    )
    r.body
  end
end

