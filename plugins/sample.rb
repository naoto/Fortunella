class Sample < Fortunella::Plugin
    
  def start(args)
      args["channels"].each { |c|
        notice c, "TEST"
      }
      sleep args["crawl"]
  end
end
