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

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    httpsPort = @data["parameters"]["updateSecurePort"]
    return URI("https://#{host}:#{httpsPort}/#{path}")

  end


  def httpURI

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    httpPort = @data["parameters"]["updatePort"]
    return URI("http://#{host}:#{httpPort}/#{path}")

  end


  def wsURI

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    wsPort = @data["parameters"]["subscribePort"]
    return URI("ws://#{host}:#{wsPort}/#{path}")

  end


  def wssURI

    host = @data["parameters"]["host"]
    path = @data["parameters"]["path"]
    wssPort = @data["parameters"]["subscribeSecurePort"]
    return URI("wss://#{host}:#{wssPort}/#{path}")

  end

end
