=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class RickRoll < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '<head>', '<head> <iframe width="0" height="0" src="http://www.youtube.com/embed/dQw4w9WgXcQ?autoplay=1" frameborder="0" allowfullscreen></iframe>' )
    end
  end
end
