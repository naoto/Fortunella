require 'net/https'
require 'rubygems'
require 'nokogiri'

class Gmail < Fortunella::Plugin
    
  def initialize(core,config)
    super
    proxy = ENV['https_proxy'] || ENV['http_proxy']
  end
  
  def run(args,sleep_time,data)

    https = Net::HTTP.new('mail.google.com', 443)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new('/mail/feed/atom')
    request.basic_auth(args["account"], args["password"])
    response = https.request(request).body

    xml = Nokogiri::XML(response)
    xml.search("entry").each { |entry|
      id = entry.at("id").content
      if (!data.key?(id))
        title = entry.at("title").content
        name = entry.at("name").content
        link = entry.at("link")["href"]

        args["channels"].each{ |c|
          notice c, "Mail: (#{name}) #{title} #{URI.short(link)}"
        }
        data[id] = title
      end
    }
  rescue Exception => e
    warn e
  end
end
