#!/usr/bin/ruby

# global requirements
require 'securerandom'
require 'net/http'
require 'logger'
require 'base64'
require 'json'


# Consumer class
class Consumer < KP

  # class constructor
  def initialize(sapFile, clientId, secure)
    
    # invoke mother's constructor
    super(sapFile, clientId, secure)

  end

  
  # consume
  def consume(sparqlQuery)

    # debug print
    @logger.debug("Issuing a SPARQL Query")
    
    # choose between secure or insecure
    if @secure

      # register, if needed
      if @securityManager.clientId.nil? or @securityManager.clientSecret.nil?
        @securityManager.register()
      end
      
      # get token, if needed
      if @securityManager.token.nil?
        @securityManager.getToken()
      end
      
      # https request
      secret = "Bearer " + @securityManager.token
      http = Net::HTTP.new(@httpsURI.host, @httpsURI.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl?
      req = Net::HTTP::Post.new(@httpsURI.path,
                                'Content-Type' => 'application/sparql-query',
                                'Accept' => 'application/json',
                                'Authorization' => secret.delete("\n"))
      req.body = sparqlQuery
      res = http.request(req)
      result = res.body
      @logger.debug(result)
      
    else

      # http request
      http = Net::HTTP.new(@httpURI.host, @httpURI.port)
      req = Net::HTTP::Post.new(@httpURI.path,
                                'Content-Type' => 'application/sparql-query',
                                'Accept' => 'application/json')
      req.body = sparqlQuery
      res = http.request(req)
      result = res.body
      @logger.debug(result)
      
    end

  end

end
