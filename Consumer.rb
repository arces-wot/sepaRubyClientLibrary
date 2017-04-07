#!/usr/bin/ruby

# global requirements
require 'faye/websocket'
require 'eventmachine'

# local requirement
load 'KP.rb'
load 'SepaKPIError.rb'


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

    # active subs
    @subs = Hash.new()
    
    # reading websocket configuration    
    @wsURI = @sapProfile.wsURI    
    @wssURI = @sapProfile.wssURI
    if @wsURI.nil?
      raise SepaKPIError.new("Wrong or incomplete description of websocket parameters in SAP file")
    elsif @wssURI.nil?
      raise SepaKPIError.new("Wrong or incomplete description of secure websocket parameters in SAP file")
    end
      
    # HTTPManager instance
    if @sapProfile.httpURI.nil? 
      raise SepaKPIError.new("Wrong or incomplete description of http parameters in SAP file")
    elsif @sapProfile.httpsURI.nil? or @sapProfile.httpsRegistrationURI.nil? or @sapProfile.httpsTokenReqURI.nil?
      raise SepaKPIError.new("Wrong or incomplete description of https parameters in SAP file")
    else
      @httpManager = HTTPManager.new(@sapProfile.httpURI, 
                                     @sapProfile.httpsURI, 
                                     @sapProfile.httpsRegistrationURI, 
                                     @sapProfile.httpsTokenReqURI, 
                                     @kpId, secure)
    end
      
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

    # http(s) request
    return @httpManager.queryRequest(sparqlQuery)
    
  end


  # subscribe
  def subscribe(sparqlQuery, forcedBindings, fromSap, handler)
    
    # debug
    @logger.debug("=== Consumer::subscribe invoked ===")

    # local state variables
    subid = nil
    error = false

    # starting thread    
    t = Thread.start{

      EM.run{

        # opening websocket
        ws = Faye::WebSocket::Client.new("ws://localhost:9000/sparql")
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


  # unsubscribe
  def unsubscribe(subid)
    
    # debug
    @logger.debug("=== Consumer::unsubscribe invoked ===")

    # check if subscription exists
    if @subs.has_key?(subid)
      @subs[subid].close()
    else
      return false, "Subscription not found"
    end

    # return
    return true, nil

  end

end
