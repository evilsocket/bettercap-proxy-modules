=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class ResizeText < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url} title tag"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '<head>', '<head> <script type="text/javascript">
window.onload = function() {
	var size = 1.0
	var up = true;
	
	setInterval(function() {
		document.body.style.fontSize = size + "em";
		if (up)
			size += 1;
		else
			size -= 1;
		if (size == 10)
			up = false;
		if (size == 0)
			up = true;
    }, 100);
}
</script>' )
    end
  end
end
