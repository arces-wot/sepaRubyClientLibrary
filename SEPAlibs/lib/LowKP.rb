#!/usr/bin/ruby
# -*- coding: utf-8 -*-

# global requirements
require 'faye/websocket'
require 'securemanager'
require 'eventmachine'
require 'logger'

# local requirements
load 'HTTPManager.rb'


#######################################################à
#
# LowKP class
#
#######################################################à

class LowKP


  #######################################################à
  #
  # constructor
  #
  #######################################################à

  def initialize(host, httpPort, httpsPort, wsPort, wssPort, path, secure, kpId)
    
    # logger configuration
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.debug("=== LowKP::initialize invoked ===")   
    
    # set attributes
    @secure = secure
    @wsURI = "ws://#{host}:#{wsPort}/#{path}"
    @wssURI = "wss://#{host}:#{wssPort}/#{path}"
    @httpURI = "http://#{host}:#{httpPort}/#{path}"
    @httpsURI = "https://#{host}:#{httpsPort}/#{path}"
    @getTokenURI = "https://#{host}:#{httpsPort}/oauth/token"
    @registerURI = "https://#{host}:#{httpsPort}/oauth/register"

    # set kpId
    if kpId.nil?
      @kpId = SecureManager.uuid.to_s
    else
      @kpId = kpId
    end
    
    # subscriptions
    @subs = Hash.new()

    # create an instance of the HTTPManager
    @httpManager = HTTPManager(@httpURI, @httpsURI, @registerURI, @getTokenURI, @kpId, secure)

  end


  #######################################################à
  #
  # update
  #
  #######################################################à

  def update(sparqlUpdate)

    # debug
    @logger.debug("=== LowKP::sparqlUpdate invoked ===")   

    # perform the update request
    return @httpManager.updateRequest(sparqlUpdate)

  end


  #######################################################à
  #
  # query
  #
  #######################################################à

  def query(sparqlQuery)

    # debug
    @logger.debug("=== LowKP::sparqlQuery invoked ===")   

    # perform the query request
    return @httpManager.queryRequest(sparqlQuery)

  end


  #######################################################à
  #
  # subscribe
  #
  #######################################################à

  def subscribe(sparqlQuery, handler)    
    
    # debug
    @logger.debug("=== LowKP::subscribe invoked ===")   

    # initialization
    subid = nil
    
    # starting thread    
    t = Thread.start{
      
      EM.run{
        
        # opening websocket
        ws = Faye::WebSocket::Client.new(@wsURI.to_s)
        @logger.debug("Subscribing to host #{@wsURI.to_s}")
        
        # send subscription 
        ws.on :open do |event|        
          @logger.debug("Sending subscription")
          ws.send("subscribe=" + sparqlQuery)               
        end
        
        # received message
        ws.on :message do |event|
          
          # parse received message
          msg = JSON.parse(event.data)
          
          # if it is the confirm message
          if msg.has_key?("subscribed")
            
            # get the sub id
            subid = msg["subscribed"]
            @logger.debug("Subscription confirmed: #{subid}")

            # store the subscription
            @subs[subid] = ws
            
          end

          # if it contains results
          if msg.has_key?("results")            
            if handler.methods.include? :handle
              handler.handle(msg["results"]["addedresults"], msg["results"]["removedresults"])
            end
          end
          
        end
        
        # close
        ws.on :close do |event|
          @logger.debug("Closing websocket -- #{event.code} -- #{event.reason}")
          ws = nil
        end
      }
    }
    
    # return status, sub_id
    while subid.nil? do
      @logger.debug("Waiting sub_id...")
      sleep 1
    end
    return true, subid  
      
  end


  #######################################################à
  #
  # unsubscribe
  #
  #######################################################à

  def unsubscribe(subid)

    # debug
    @logger.debug("=== LowKP::unsubscribe invoked ===")   

    # check if subscription exists
    if @subs.has_key?(subid)
      @subs[subid].close()
      return true
    else
      return false
    end

  end

end
