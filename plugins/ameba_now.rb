require 'uri'
require 'open-uri'
require 'rubygems'
require 'nokogiri'

class AmebaNow < Fortunella::Plugin
    
  def run(args,sleep_time,data)
    
    base = "http://now.ameba.jp/"
    args["user"].each { |u|
      data[u] = {} if data[u].nil?
      uri = "#{base}#{u}"
      h = Nokogiri::HTML(open(URI.escape(uri)))
      h.search("li.clearFix").each{ |l|
        if data[u][l["id"]].nil?
          args["channels"].each { |c|
            privmsg c, l.inner_text
          }
          data[u][l["id"]] = l.inner_text
        end
      }
    }
  end
end
