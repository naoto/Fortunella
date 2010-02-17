class Sample < Fortunella::Plugin
    
  def run(args,sleep_time,data)
      args["channels"].each { |c|
        notice c, "TEST"
      }
  end
end
