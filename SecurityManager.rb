#!/usr/bin/ruby

# global requirements
require 'net/http'
require 'logger'
require 'base64'
require 'json'

# the class
class SecurityManager

  def initialize(httpsRegistrationURI, httpsTokenReqURI, kpId)

    # logger instance
    # TODO -- add logger level
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG

    # store auth data
    @httpsRegistrationURI = httpsRegistrationURI
    @httpsTokenReqURI = httpsTokenReqURI
    @kpId = kpId
    
    # initialize data
    @clientSecret = nil
    @clientId = nil
    @token = nil

  end


  # register
  def register

    # debug print
    @logger.debug("Registering the producer")

    # https request
    http = Net::HTTP.new(@httpsRegistrationURI.host, @httpsRegistrationURI.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(@httpsRegistrationURI.path,
                              'Content-Type' => 'application/json',
                              'Accept' => 'application/json')
    req.body = { client_identity: @kpId,
                 grant_types:["client_credentials"] }.to_json
    res = http.request(req)
    result = JSON.parse(res.body)
    @clientId = result["client_id"]
    @clientSecret = result["client_secret"]

    # debug print
    @logger.debug("Received Client ID: #{@clientId}")
    @logger.debug("Received Client Secret: #{@clientSecret}")    

  end


  # get token
  def getToken

    # debug print
    @logger.debug("Getting the token")

    # https request
    secret = "Basic " + Base64.encode64(@clientId + ":" + @clientSecret)
    http = Net::HTTP.new(@httpsTokenReqURI.host, @httpsTokenReqURI.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(@httpsTokenReqURI.path,
                              'Content-Type' => 'application/x-www-form-urlencoded',
                              'Accept' => 'application/json',
                              'Authorization' => secret.delete("\n"))
    res = http.request(req)
    result = JSON.parse(res.body)
    @token = result["access_token"]

    # debug print
    @logger.debug("Received token: #{@token}")
    
  end

  
  def clientSecret
    @clientSecret
  end
  

  def clientId
    @clientId
  end


  def token
    @token
  end


end
