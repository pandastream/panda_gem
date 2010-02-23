require 'rubygems'
require 'cgi'
require 'time'
require 'hmac'
require 'hmac-sha2'
require 'base64'

class Panda
  class ApiAuthentication
    def self.generate_signature(verb, request_uri, host, secret_key, params_given={})
      # Ensure all param keys are strings
      params = {}; params_given.each {|k,v| params[k.to_s] = v }
      
      query_string = canonical_querystring(params)
      
      string_to_sign = verb.to_s.upcase + "\n" + 
          host.downcase + "\n" +
          request_uri + "\n" +
          query_string
      
      hmac = HMAC::SHA256.new( secret_key )
      hmac.update( string_to_sign )
      # chomp is important!  the base64 encoded version will have a newline at the end
      Base64.encode64(hmac.digest).chomp
    end

    # param keys should be strings, not symbols please. return a string joined
    # by & in canonical order. 
    def self.canonical_querystring(params)
      # I hope this built-in sort sorts by byte order, that's what's required. 
      params.keys.sort.collect {|key| [url_encode(key), url_encode(params[key])].join("=") }.join("&")
    end

    # Turns a hash into a query string, returns the query string.
    # url-encodes everything to Amazon's specifications. 
    def self.hash_to_query(hash)
      hash.collect{|key, value| url_encode(key) + "=" + url_encode(value) }.join("&")
    end

    # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
    # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
    def self.url_encode(string)
      CGI.escape(string.to_s).gsub("%7E", "~").gsub("+", "%20")
    end
  end
end