require 'open-uri'
require 'nokogiri'

class Twitter < Fortunella::Plugin
    
  def run(args,sleep_time,data)

      lasted = Nokogiri::HTML(open("http://twitter.com/naotos")).at(".entry-content")
      p lasted
      if lasted.inner_text != data["lasted"]
        data["lasted"] = lasted.inner_text
        args["channels"].each { |c|
          notice c, "@naotos: #{data["lasted"]}"
        }
      end

  end
end
