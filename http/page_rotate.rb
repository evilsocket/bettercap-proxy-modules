=begin

BETTERCAP

Author : Rick Daalhuizen
Email  : rick.daalhuizen@protonmail.com
Blog   : https://rickdaalhuizen90.github.io

This project is released under the GPL 3 license

=end
class PageRotate < BetterCap::Proxy::HTTP::Module
	meta(
		'Name' 				=> 'PageRotate',
		'Description' => 'Flip the page in 180 degrees',
		'Version' 		=> '1.0.0',
		'Author' 			=> 'Rick Daalhuizen',
		'License' 		=> 'GPL3'
	)

	def on_request( request, response )
		# Check if it's a html page
		if response.content_type =~ /^text\/html.*/
			BetterCap::Logger.info "Flipping ..."
      response.body.sub!( '<head>', '<head> <style>html{transform: rotateX(180deg) !important;}</style>' )
    end
	end
end
