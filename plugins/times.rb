class Times < Fortunella::Plugin
    
  def start(args)
      args["timer"].each { |t|
        if t["time"] == Time.now.strftime("%H:%M")
          t["channels"].each { |c|
            notice c, t["reply"]
          }
        end
      }
      sleep args["crawl"]
  end
end
