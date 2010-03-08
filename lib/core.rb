require 'optparse'

require 'rubygems'
require 'daemons'
require 'ostruct'
require 'yaml'
require 'net/irc'
require 'pathname'
require 'thread'

require 'utils'
require 'plugin'

module Fortunella
class Core < Net::IRC::Client

  attr_reader :socket

  def initialize
    setup_options
    loadfile
    super(@config.general["host"], @config.general["port"], {
      :nick => @config.general["nick"],
      :user => @config.general["user"],
      :real => @config.general["real"],
      :pass => @config.general["pass"],
      :logger => @logger
    })

    @path = Pathname.new(@plugin_dir)
    @classtable = search(@path)
  end

  def loadfile
    @config = OpenStruct.new(File.open(@config_file) {|f| YAML.load(f) })

    %w(host port nick user real).each do |req|
       raise ArgumentError, "config general/#{req} is required." if @config.general[req].nil?
    end

    @plugin_dir = @config.general["plugin_dir"]
    @data_dir = @config.general["data_dir"]
    @logger = Logger.new(@config.general["log"] || $stdout)
    @logger.level = eval("Logger::#{@config.general['log_level'].upcase}") if @config.general['log_level']
    @logger.progname = File.basename($0)
  end

  def setup_options
    @crawl_time = 60
    @config_file = "config.yaml"

    ARGV.options do |o|
      o.on('-c', "--config-file", 'configfileを読み込む') { |v| @config_file = v }
      o.parse!
    end

    raise "No ConfigFile" if @config_file.nil?
  end

  def start

    @server_config = Message::ServerConfig.new
    @socket = TCPSocket.open(@config.general["host"], @config.general["port"])
    on_connected

    post PASS, @opts.pass if @opts.pass
    post NICK, @opts.nick
    post USER, @opts.user, "0", "*", @opts.real

    @socket.gets
    on_plugins

    while l = @socket.gets
      begin
        #@log.debug "RECEIVE: #{l.chomp}"
        m = Message.parse(l)
        next if on_message(m) === true
        name = "on_#{(COMMANDS[m.command.upcase] || m.command).downcase}"
        send(name, m) if respond_to?(name)
      rescue Exception => e
        warn e
        warn e.backtrace.join("\r\t")
        raise
      rescue Message::InvalidMessage
        @log.error "MessageParse: " + l.inspect
      end
    end

  rescue IOError
  ensure
    finish
  end

  def on_plugins

    @instance = {}
    @crawl = {}
    load_data

    @config.plugins.each { |key,_|
      @instance[key] = @classtable[key][:class].new(self,@config.plugins)
      @crawl[key] = _["crawl"] || @crawl_time
      @data_store[key] = {} if @data_store[key].nil?
      Thread.start(key,@instance[key]) do |nm,ins| 
        loop do
          ins.run(_,@crawl[key],@data_store[key])
          store
          sleep @crawl[key]
        end
      end
    }

  rescue Exception => e
    warn e
  ensure
  end

  def load_data
    if(!File.exists?("#{@data_dir}/store.yaml"))
      @data_store = {}
      store
    else
      @data_store = YAML.load_file("#{@data_dir}/store.yaml")
    end
  end

  def store
    f = File.open("#{@data_dir}/store.yaml",'w+')
    f.puts @data_store.to_yaml
    f.close
  end

  def log(l)
    @logger.info(l)
  end

  protected
  def search(path)
    class_table = {}

    Pathname.glob("#{path}/*.rb") do |f|
      class_table.update(load_file(f))
    end

    class_table
  end

  def load_file(f)
    ret = {}
    m = Module.new
    m.module_eval(f.read, f)
    m.constants.each do |name|
      const = m.const_get(name)
      if const.is_a? Class
        ret[name] = {
          :class => const,
          :file  => f,
          :time  => f.mtime,
        }
      end
    end
    ret
  end

end 
end
