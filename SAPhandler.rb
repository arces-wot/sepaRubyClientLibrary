#!/usr/bin/ruby

class SAPhandler

  def initialize(sapFile)

    # open SAP file
    file = File.read(sapFile)
    @data = JSON.parse(file)
    
  end


  def prefixes

    prefixes = ""
    @data["namespaces"].each do |k,v|
      prefixes += "PREFIX #{k}: <#{v}> "
    end
    return prefixes
    
  end
  
  
  def queries
    @data["subscribes"]    
  end


  def updates
    @data["updates"]    
  end
  
  
  def httpsTokenReqURI

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    httpsPort = @data["parameters"]["updateSecurePort"]
    return URI("https://#{host}:#{httpsPort}/oauth/token")

  end


  def httpsRegistrationURI

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    httpsPort = @data["parameters"]["updateSecurePort"]
    return URI("https://#{host}:#{httpsPort}/oauth/register")

  end


  def httpsURI
    if @data.has_key?("parameters")
      if @data["parameters"].has_key?("host") and @data["parameters"].has_key?("path") and @data["parameters"].has_key?("updateSecurePort")
        host = @data["parameters"]["host"]
        path = @data["parameters"]["path"]
        httpsPort = @data["parameters"]["updateSecurePort"]
        return URI("https://#{host}:#{httpsPort}/#{path}")
      end
    end
    return nil
  end


  def httpURI
    if @data.has_key?("parameters")
      if @data["parameters"].has_key?("host") and @data["parameters"].has_key?("path") and @data["parameters"].has_key?("updatePort")
        host = @data["parameters"]["host"]
        path = @data["parameters"]["path"]
        httpPort = @data["parameters"]["updatePort"]
        return URI("http://#{host}:#{httpPort}/#{path}")
      end
    end
    return nil
  end


  def wsURI    
    if @data.has_key?("parameters")
      if @data["parameters"].has_key?("host") and @data["parameters"].has_key?("path") and @data["parameters"].has_key?("subscribePort")
        host = @data["parameters"]["host"]
        path = @data["parameters"]["path"]
        wsPort = @data["parameters"]["subscribePort"]
        return URI("ws://#{host}:#{wsPort}/#{path}")
      end
    end
    return nil
  end


  def wssURI
    if @data.has_key?("parameters")
      if @data["parameters"].has_key?("host") and @data["parameters"].has_key?("path") and @data["parameters"].has_key?("subscribeSecurePort")
        host = @data["parameters"]["host"]
        path = @data["parameters"]["path"]
        wssPort = @data["parameters"]["subscribeSecurePort"]
        return URI("wss://#{host}:#{wssPort}/#{path}")
      end
    end
    return nil
  end

end
