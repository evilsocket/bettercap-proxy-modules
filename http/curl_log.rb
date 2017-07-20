
class CurlLog < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'Log requests in CURL cli format',
    'Description' => 'A simple logging module where all requests are logged in a form where they can easily be repeated with the curl command',
    'Version'     => '1.0.0',
    'Author'      => 'timwr',
    'License'     => 'GPL3'
  )
  
  # called before the request is performed
  def on_pre_request( request )
  end

  def on_request( request, response )
    # filter hosts
    #if not request.host =~ /yourhost/
      #return
    #end
    logger_output = "curl '#{request.base_url}#{request.path}' -X #{request.method}"
    request.headers.each do |name,value|
      logger_output += " \\ \n --header '#{name}:#{value}'"
    end
    if request.post?
      logger_output += " \\ \n -d '#{request.body}'"
    end
    # display the content
    #if response.content_type == 'application/json' || response.content_type == 'text/html'
      #logger_output += "\n#" + response.body
    #end
    logger_output += "\n"
    BetterCap::Logger.info logger_output
  end
end

