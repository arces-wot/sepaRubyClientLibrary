#!/usr/bin/ruby

# global requirements
require 'faye/websocket'
require 'eventmachine'


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

    # http(s) request
    return @httpManager.queryRequest(sparqlQuery)
    
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
