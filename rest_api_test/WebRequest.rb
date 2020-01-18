#
# @author Fernando García
#
# == WebRequest
#
# This module is responsible for handling the protocols to the rest-api.
#
# == Summary
#
# Generic module of web requests and exception handling.
#
#
module WebRequest
  require 'rest-client'
  def WebRequest::fetch(url, headers = {accept: "*/*"}, user = "", pass="")
    response = RestClient::Request.execute({method: :get,
                                            url: url.to_s,
                                            user: user,
                                            password: pass,
                                            headers: headers})
    return response
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.response
    response = false
    return response
  rescue RestClient::Exception => e
    $stderr.puts e.response
    response = false
    return response
  rescue Exception => e
    $stderr.puts e
    response = false
    return response
  end
end
