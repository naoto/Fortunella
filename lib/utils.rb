require 'rubygems'
require 'open-uri'
require 'json'

module URI
  def short(uri)
    begin
      login   = 'tomohiro'
      api_key = 'R_9ed4fae410ab7b729a15dc91c8f7687c'

      query  = "http://api.j.mp/shorten?version=2.0.1&longUrl=#{uri}&login=#{login}&apiKey=#{api_key}"
      result = JSON.parse(open(query).read)

      result.first[1].first[1]['shortUrl']
    rescue
      URI.encode(uri)
    end
  end

  module_function :short
end
