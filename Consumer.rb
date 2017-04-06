#!/usr/bin/ruby

# global requirements
require 'faye/websocket'
require 'eventmachine'
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

    # debug print
    @logger.debug("=== Consumer::initialize invoked ===")
    
    # read queries
    @queries = @sapProfile.queries
    
    # handle open subscriptions
    subs = Hash.new()

  end
  
  
  # consume
  def consume(sparqlQuery, forcedBindings, fromSap)

    # debug print
    @logger.debug("=== Consumer::consume invoked ===")

    # determine the query to be performed
    if fromSap

      # check if query was defined in SAP
      if @queries.has_key?(sparqlQuery)

        # retrieve the query
        q = @queries[sparqlQuery]["sparql"]

        # check if forced bindings are needed
        if not(forcedBindings.nil?)
          forcedBindings.each do |k,v|
            q.gsub!("?#{k} ", " #{v} ")
          end
        end
        sparqlQuery = @sapProfile.prefixes + q

      # the query is not in the SAP content
      else
        return false, nil
      end
      
    end

    # debug print
    @logger.debug("Issuing the following query:")
    @logger.debug(sparqlQuery)
    
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

    # return 
    if res.code == 200
      return true, result
    else
      return false, result
    end
    
  end


  # subscribe
  def subscribe(sparqlQuery)
    
    t = Thread.start{
      EM.run{

        ws = Faye::WebSocket::Client.new(@wsURI.to_s)
        @logger.debug("Subscribing to host #{@wsURI}")
        
        ws.on :open do |event|
          puts "OPEN"
          p [:open]
          ws.send("subscribe=" + sparqlQuery)
          t.join()
        end
        
        ws.on :message do |event|
          puts "MESSAGE"
          p [:message, event.data]
        end
        
        ws.on :close do |event|
          puts "CLOSING"
          p [:close, event.code, event.reason]
          ws = nil
        end
      }         
    }
    puts "RETURNING"
    
  end


  # unsubscribe
  def unsubscribe
  end

end
