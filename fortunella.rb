#!/usr/bin/env ruby

$LOAD_PATH << 'lib'
$LOAD_PATH << '../lib'

require 'core.rb'

module Fortunella
  class << self
    def run
      Core.new.start
    end
  end
end

Fortunella.run
