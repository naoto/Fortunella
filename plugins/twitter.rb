require 'open-uri'
require 'nokogiri'

class Twitter < Fortunella::Plugin
    
  def start(args)
      
      lasted = Nokogiri::HTML(open("http://twitter.com/naotos")).at(".entry-content")
     
      p lasted
      if lasted.inner_text != @lasted
        p "IN"
        @lasted = lasted.inner_text
        args["channels"].each { |c|
          notice c, "@naotos: #{@lasted}"
        }
      end

      sleep args["crawl"]
  end
end
