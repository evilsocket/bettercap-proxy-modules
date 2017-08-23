
=begin
BETTERCAP
Author : Simone 'evilsocket' Margaritelli & David Kotriksnov (SH4V)
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/
This project is released under the GPL 3 license.
=end

# This module requires the --httpd argument being passed
# to bettercap and the --httpd-path pointing to a folder
# which contains one or more images.
class ReplaceImages < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'ReplaceImages',
    'Description' => 'Replace all images on web pages by the picture(s) placed in the specified directory.',
    'Version'     => '1.1.0',
    'Author'      => "Simone 'evilsocket' Margaritelli & David Kotriksnov (SH4V)",
    'License'     => 'GPL3'
  )
	def initialize
		opts = BetterCap::Context.get.options.servers
		@imgArray = Dir.entries("#{opts.httpd_path}")
		@imgArray.shift
		@imgArray.shift
		# make sure the server is running
		raise BetterCap::Error, "The ReplaceImages proxy module needs the HTTPD ( --httpd argument ) running."	unless opts.httpd
		# make sure the file we need actually exists  
		raise BetterCap::Error, "No files found in the HTTPD path ( --httpd-path argument ) '#{opts.httpd_path}'" \
		unless @imgArray.length > 0
			@images_path = "http://#{BetterCap::Context.get.iface.ip}:#{opts.httpd_port}/"
	end

	def on_request(request, response)
		@image_file=@imgArray[rand(@imgArray.length)]
		@image_url="\""+@images_path+@image_file+"\""
		# is it a html page?
		if response.content_type =~ /^text\/html.*/
			BetterCap::Logger.info "Replacing http://#{request.host}#{request.path} images with #{@image_file}..."
			response.body.gsub! %r/["'][https:\/\/]*[^\s]+\.(png|jpg|jpeg|bmp|gif)["']/i, @image_url
			@image_url=nil
		end
	end
end



