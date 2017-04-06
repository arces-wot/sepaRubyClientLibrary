#!/usr/bin/ruby

# global requirements
require 'securerandom'
require 'net/http'
require 'logger'
require 'base64'
require 'json'

# local requirements
load 'HTTPManager.rb'
load 'SAPhandler.rb'


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
    @sapProfile = SAPhandler.new(sapFile)

    # reading websocket configuration
    @wsURI = @sapProfile.wsURI
    @wssURI = @sapProfile.wssURI

    # store the client ID
    @kpId = clientId
    if clientId.nil?
      @kpId = SecureRandom.uuid
    end
    @logger.debug("Client name set to #{@kpId}")

    # HTTPManager instance
    @httpManager = HTTPManager.new(@sapProfile.httpURI, 
                                   @sapProfile.httpsURI, 
                                   @sapProfile.httpsRegistrationURI, 
                                   @sapProfile.httpsTokenReqURI, 
                                   @kpId, secure)

  end

end
