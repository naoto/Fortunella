require 'open-uri'
require 'nokogiri'

class Twitter < Fortunella::Plugin
    
  def run(args,sleep_time,data)
      lasted = Nokogiri::HTML(open("http://twitter.com/naotos")).at(".entry-content")
      if lasted.inner_text != data["lasted"]
        data["lasted"] = lasted.inner_text.trim
        args["channels"].each { |c|
          notice c, "@e: #{data["lasted"]}"
        }
      end

  end
end
