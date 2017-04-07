#!/usr/bin/ruby

# global requirements
require 'faye/websocket'
require 'eventmachine'

# local requirement
load 'Consumer.rb'
load 'Producer.rb'
load 'SepaKPIError.rb'


# Consumer class
class Aggregator < Consumer

  # constructor
  def initialize(sapFile, clientId, secure)

    # invoke mother's constructor
    super(sapFile, clientId, secure)    

    # debug print
    @logger.debug("=== Aggregator::initialize invoked ===")
    
    # create an instance of the producer
    @producer = (sapFile, clientId, secure, @httpManager)

  end

end
