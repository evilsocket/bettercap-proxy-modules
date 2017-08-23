=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Debug < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'Debug',
    'Description' => 'Simple HTTP debug module.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  def on_request( request, response )
    puts "\n--- REQUEST ---\n\n"
    puts request.to_s.strip.split("\n").map { |x| "  #{x}"}.join("\n").green
    puts "\n\n--- RESPONSE ---\n\n"
    puts response.to_s.strip.split("\n").map { |x| "  #{x}"}.join("\n").yellow
  end
end
