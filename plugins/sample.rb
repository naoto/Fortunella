class Sample < Fortunella::Plugin
    
  def start(args)
      p args["crawl"]
      notice "#naobot@freenode", "TEST"
      sleep args["crawl"]
  end
end
