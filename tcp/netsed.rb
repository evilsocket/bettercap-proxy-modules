=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class NetSed < BetterCap::Proxy::TCP::Module
  meta(
    'Name'        => 'NetSed',
    'Description' => 'NetSed-like TCP proxy module.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  @@search  = nil
  @@replace = nil

  def on_options(opts)
    opts.separator ""
    opts.separator "Replace TCP data using a regular expression:"
    opts.separator ""

    opts.on( '--netsed-search SEARCH', 'Search pattern.' ) do |v|
      @@search = v
    end

    opts.on( '--netsed-replace REPLACE', 'Replace pattern.' ) do |v|
      @@replace = v
    end
  end

  # Received when the victim is sending data to the upstream server.
  def on_data( event )
    check_opts
    event.data.gsub!( @@search, @@replace )
  end

  # Received when the upstream server is sending a response to the victim.
  def on_response( event )
    check_opts
    event.data.gsub!( @@search, @@replace )
  end

  private

  def check_opts()
    raise BetterCap::Error, "No search pattern specified." if @@search.nil?
    raise BetterCap::Error, "No replace pattern specified." if @@replace.nil?
  end
end
