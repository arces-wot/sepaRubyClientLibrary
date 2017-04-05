#!/usr/bin/ruby

class SAPhandler

  def initialize(sapFile)

    # logger instance
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @logger.debug("Creating a producer")   

    # open SAP file
    file = File.read(sapFile)
    @data = JSON.parse(file)
    
    # debug
    @logger.debug("Update URI: #{@httpURI}")
    @logger.debug("Update Secure URI: #{@httpsURI}")
    @logger.debug("Token Request URI: #{@httpsTokenReqURI}")
    @logger.debug("Registration URI: #{@httpsRegistrationURI}")

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


end
