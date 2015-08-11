=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Spinimages < Proxy::Module
  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      Logger.info "Hacking http://#{request.host}#{request.url}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '</head>', '<<style>
@-moz-keyframes spin {
  0%   { transform: rotate(0deg); }
  100%   { transform: rotate(360deg); }
}
@-webkit-keyframes spin {
  0%   { -webkit-transform: rotate(0deg); }
  100%   { -webkit-transform: rotate(360deg); }
}

/*
  Spin all images
*/ 
img {
  -webkit-animation: spin 1s linear infinite;
  animation: spin 1s linear infinite;*/
}

</style>
</head>' )
    end
  end
end
