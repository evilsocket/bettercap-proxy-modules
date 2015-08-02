=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Blinkred < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url} title tag"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '</head> // Text is blinking red and black

<script type="text/javascript">
window.onload=function() {
  var isRed = false;
  var selectAll = document.body;
  setInterval(function() {
    if (!isRed) {
          selectAll.style.color = "red";
          isRed = true;
      } else {
        selectAll.style.color = "black";
        isRed = false;
      }
    }, 100);
}
</script>' )
    end
  end
end
