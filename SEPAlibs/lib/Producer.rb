#!/usr/bin/ruby

# local requirements
load 'KP.rb'
load 'Errors.rb'

# Producer class
class Producer < KP

  # class constructor
  def initialize(sapFile, clientId, secure, httpManager)

    # invoke mother's constructor
    super(sapFile, clientId, secure)

    # debug print
    @logger.debug("=== Producer::initialize invoked ===")    

    # HTTPManager instance
    # check if an existing HTTPManager is given
    if httpManager.nil?
      if @sapProfile.httpURI.nil? 
        raise SepaKPIError.new(@@INCOMPLETE_HTTP_SECTION)
      elsif @sapProfile.httpsURI.nil? or @sapProfile.httpsRegistrationURI.nil? or @sapProfile.httpsTokenReqURI.nil?
        raise SepaKPIError.new(@@INCOMPLETE_HTTPS_SECTION)
      else
        @httpManager = HTTPManager.new(@sapProfile.httpURI, 
                                       @sapProfile.httpsURI, 
                                       @sapProfile.httpsRegistrationURI, 
                                       @sapProfile.httpsTokenReqURI, 
                                       @kpId, secure)
      end
      
    # HTTPManager given
    else
      @httpManager = httpManager
    end
      
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
