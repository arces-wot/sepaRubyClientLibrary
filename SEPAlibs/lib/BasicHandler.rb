#!/usr/bin/ruby

# global requirements
require 'logger'

class BasicHandler

  # constructor
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.debug("Creating a KP")       
  end

  # handler
  def handle(added, removed)
    @logger.debug("Added results:")
    @logger.debug(added)
    @logger.debug("Removed results:")
    @logger.debug(removed)
  end

end
