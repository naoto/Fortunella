require 'open-uri'
require 'rss'
require 'uri'

class Feed < Fortunella::Plugin
    
  def run(args,sleep_time,data)

    args["uri"].each { |uri|
      data[uri] = {} if data[uri].nil?
      rss = open(URI.escape(uri)){ |file| RSS::Parser.parse(file.read)}
      rss.items.each do |item|
        if !data[uri].key?(item.link)
          args["channels"].each { |c|
            notice c, "#{item.title} #{URI.short(item.link)}"
          }
          data[uri][item.link] = item.title
        end
      end
    }
  end
end
