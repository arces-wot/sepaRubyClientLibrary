#!/usr/bin/ruby

# global requirements
require 'net/http'
require 'logger'
require 'base64'
require 'json'

# the class
class HTTPManager

  def initialize(httpURI, httpsURI, httpsRegistrationURI, httpsTokenReqURI, kpId, secure)

    # logger instance
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.debug("=== HTTPManager::initialize invoked ===")

    # store http and https update/query URIs
    @httpsURI = httpsURI
    @httpURI = httpURI

    # store auth data
    @secure = secure
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
    @logger.debug("=== HTTPManager::register invoked ===")

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
    @logger.debug("=== HTTPManager::getToken invoked ===")

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


  # sparql query
  def queryRequest(sparqlQuery)

    # choose between secure or insecure
    if @secure

      # initialization
      retryNeeded = false

      # register, if needed
      if @clientId.nil? or @clientSecret.nil?
        register()
      end
      
      # loop is necessary to retry if token is expired
      loop do
      
        # get token, if needed
        if @token.nil? or retryNeeded
          getToken()
        end
      
        # https request
        secret = "Bearer " + @token
        http = Net::HTTP.new(@httpsURI.host, @httpsURI.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
        req = Net::HTTP::Post.new(@httpsURI.path,
                                  'Content-Type' => 'application/sparql-query',
                                  'Accept' => 'application/json',
                                  'Authorization' => secret.delete("\n"))
        req.body = sparqlQuery
        res = http.request(req)
        
        # result
        result = res.body
        status = res.code
        if status == "401"
          puts res.body
          retryNeeded = true
          @logger.debug("WE SHOULD REQUEST A NEW TOKEN")
        end      

        break if retryNeeded == false

      end

    # not secure
    else

      # http request
      http = Net::HTTP.new(@httpURI.host, @httpURI.port)
      req = Net::HTTP::Post.new(@httpURI.path,
                                'Content-Type' => 'application/sparql-query',
                                'Accept' => 'application/json')
      req.body = sparqlQuery
      res = http.request(req)
      
      # result
      status = res.code
      result = res.body
      
    end

    # return
    return status, result

  end


  # update
  def updateRequest(sparqlUpdate)

    if @secure

      # register, if needed
      if @clientId.nil? or @clientSecret.nil?
        register()
      end
      
      # get token, if needed
      if @token.nil?
        getToken()
      end    
      
      # https request
      secret = "Bearer " + @token
      http = Net::HTTP.new(@httpsURI.host, @httpsURI.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      req = Net::HTTP::Post.new(@httpsURI.path,
                                'Content-Type' => 'application/sparql-update',
                                'Accept' => 'application/json',
                                'Authorization' => secret.delete("\n"))
      req.body = sparqlUpdate
      res = http.request(req)
          
      # result
      status = res.code
      result = res.body

    # not secure
    else
      
      # http request
      http = Net::HTTP.new(@httpURI.host, @httpURI.port)
      req = Net::HTTP::Post.new(@httpURI.path,
                                'Content-Type' => 'application/sparql-update',
                                'Accept' => 'application/json')
      req.body = sparqlUpdate
      res = http.request(req)

      # result
      status = res.code
      result = res.body

    end

    # return
    return status, result

  end


end
