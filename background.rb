=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class background < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url} title tag"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '<style>
body  {
    background-image: url("http://www.ijstd.org/articles/2013/34/2/images/IndianJSexTransmDis_2013_34_2_138_120563_f1.jpg");
    
}

</style>
</head>' )
    end
  end
end
