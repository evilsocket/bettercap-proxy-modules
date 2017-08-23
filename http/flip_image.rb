=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/
This project is released under the GPL 3 license.

PLUGIN flip_image.rb
Author : Kingbobi
Email  : hewiloo@web.de
Blog   : https://github.com/kingbobi

=end

require 'rmagick'
require 'base64'
include Magick

class FlipImg < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'FlipImg',
    'Description' => 'Flips images on web pages.',
    'Version'     => '1.0.0',
    'Author'      => "Kingbobi - hewiloo@web.de",
    'License'     => 'GPL3'
  )

  def on_request( request, response )
	if response.content_type =~ /^image\/.*/
#	  BetterCap::Logger.info "Flipping Image: http://#{request.host}#{request.path}"
	  img=Image.read_inline(Base64.encode64(response.body))[0]
	  flip=img.flip
	  response.body=flip.to_blob
	end
  end
end
