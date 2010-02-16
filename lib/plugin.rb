#!/usr/bin/env ruby

require "rubygems"
require "net/irc"
require "gettext"

module Fortunella
	class Plugin
		include Net::IRC
		include Constants

    include GetText

		def initialize(core, config)
			@core, @config = core, config[self.class.name.sub(/.+::/, "")] || {}
		end

		def on_uped
		end

		def on_downed
		end

		def on_privmsg(prefix, channel, message)
		end

		def on_talk(prefix, target, message)
		end

		def on_notice(prefix, channel, message)
		end

		def on_join(prefix, channel)
		end

		def on_part(prefix, channel, message)
		end

		def on_kick(prefix, channels, nicks, message)
		end

		def on_invite(prefix, nick, channel)
		end

		def on_ctcp(prefix, target, message)
		end

		def on_mode(prefix, target, positive_mode, negative_mode)
		end

		def on_nick(prefix, new_nick)
		end

		def on_message(m)
		end

		def log(*args)
			prefix = self.class.to_s.sub(/^#<Module:0x[0-9a-f]+>::/, "")
			prefix = "[#{prefix}] "
			args.each do |l|
				@core.log "#{prefix} #{l}"
			end
		end

		def post(command, *params)
			m = Message.new(nil, command, params.map {|s|
				s.gsub(/\r|\n/, " ")
			})
			@core.socket << m
		end

		def datafile(name)
			myname = self.class.to_s.sub(/^.+::/, "")
			libdir = Pathname.new(@core.config.general["data_dir"]) + myname
			libdir.mkpath unless libdir.exist?
			libdir + name
		end

		%w[
			privmsg
			notice
			join
			part
			kick
			invite
			mode
		].each do |command|
			eval <<-EOS
				def #{command}(*params)
					post #{command.upcase}, *params
				end
			EOS
		end
	end
end
