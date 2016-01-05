=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class FlipImages < BetterCap::Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.info "Hacking http://#{request.host}#{request.url}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '</head> <style>
-/*
-  Flip all images upside down
-*/
-img {
-  -webkit-transform: rotate(180deg);
-  transform: rotate(180deg);*/
-}
-
-</style>' )
    end
  end
end
