class Times < Fortunella::Plugin
    
  def run(args,sleep_time)

      args["timer"].each { |t|
        
        p t
        if t["time"] == Time.now.strftime("%H:%M")
          t["channels"].each { |c|
            notice c, t["reply"]
          }
        end
      }
  end
end
