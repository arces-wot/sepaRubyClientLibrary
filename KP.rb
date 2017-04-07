#!/usr/bin/ruby

# global requirements
require 'securerandom'
require 'logger'

# local requirements
load 'SAPhandler.rb'
load 'HTTPManager.rb'
load 'SepaKPIError.rb'

# Producer class
class KP

  # class constructor
  def initialize(sapFile, clientId, secure)

    # logger instance
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.debug("Creating a KP")   

    # loading SAP file
    @logger.debug("Reading SAP file #{sapFile}")
    if File.exists?(sapFile)
      @sapProfile = SAPhandler.new(sapFile)
    else
      raise SepaKPIException.new(@@SAPFILE_NOT_FOUND)
    end

    # store the client ID
    @kpId = clientId
    if clientId.nil?
      @kpId = SecureRandom.uuid
    end
    @logger.debug("Client name set to #{@kpId}")

  end

end
