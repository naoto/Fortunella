#!/usr/bin/env ruby

require 'optparse'

require 'rubygems'
require 'daemons'
require 'ostruct'
require 'yaml'
require 'net/irc'
require 'pathname'
require 'thread'

require 'lib/utils'
require 'lib/plugin'

module Fortunella
class Core < Net::IRC::Client

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
    @info_count = 0

    @path = Pathname.new(@plugin_dir)
    @classtable = search(@path)
  end

  def loadfile
    @config = OpenStruct.new(File.open(@config_file) {|f| YAML.load(f) })

    %w(host port nick user real).each do |req|
       raise ArgumentError, "config general/#{req} is required." if @config.general[req].nil?
    end

    @plugin_dir = @config.general["plugin_dir"]
    @logger = Logger.new(@config.general["log"] || $stdout)
    @logger.level = eval("Logger::#{@config.general['log_level'].upcase}") if @config.general['log_level']
    @logger.progname = File.basename($0)
  end

  def setup_options
    @port   = 6668
    @crawl_time = 60
    @config_file = "config.yaml"

    ARGV.options do |o|
      o.on('-c', "--config-file", 'configfileを読み込む') { |v| @config_file = v }
      o.on('-D', '--daemonize', 'プロセスをデーモン化する') { |v| Daemons.daemonize }
      o.parse!
    end

    raise "No ConfigFile" if @config_file.nil?
  end

  def start
    @server_config = Message::ServerConfig.new
    @socket = TCPSocket.open(@host, @port)
    on_connected
    post PASS, @opts.pass if @opts.pass
    post NICK, @opts.nick
    post USER, @opts.user, "0", "*", @opts.real
    @socket.gets
    on_plugins
  rescue IOError
  ensure
    finish
  end

  def on_plugins
    @instance = {}
    @config.plugins.each { |key,_|
      @instance[key] = @classtable[key][:class].new(self,@config.plugins)
      Thread.start(key,@instance[key]) do |nm,ins| 
        loop do
          ins.start(_)
        end
      end
    }

    loop do
      break if Thread.list.empty?
    end

  rescue IOError => e
    @log.error 'IOError' + e.to_s
  ensure
    finish
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

module Fortunella
  class << self
    def run
      Core.new.start
    end
  end
end

Fortunella.run
