#!/usr/bin/ruby

# global requirements
require 'securerandom'
require 'net/http'
require 'logger'
require 'base64'
require 'json'

# local requirements
load 'KP.rb'

# Producer class
class Producer < KP

  # class constructor
  def initialize(sapFile, clientId, secure)

    # invoke mother's constructor
    super(sapFile, clientId, secure)

  end
 
  
  # produce
  def produce(sparqlUpdate, forcedBindings, fromSap)

    # debug print
    @logger.debug("=== Producer::produce invoked ===")
    
    # determine the update to perform
    if fromSap
      
      # check if query was defined in SAP
      if @sapProfile.updates.has_key?(sparqlUpdate)
        
        # retrieve the update
        u = @sapProfile.updates[sparqlUpdate]["sparql"]

        # check if forced bindings are needed
        if not(forcedBindings.nil?)
          forcedBindings.each do |k,v|
            u.gsub!("?#{k} ", " #{v} ")
          end
        end
        sparqlUpdate = @sapProfile.prefixes + u
        
      # update not present in SAP
      else
        return false, nil
      end

    end

    # debug print
    @logger.debug("Issuing the following update:")
    @logger.debug(sparqlUpdate)

    # https request
    return @httpManager.updateRequest(sparqlUpdate)

  end


end
