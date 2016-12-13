This repository contains some [bettercap](http://www.bettercap.org/) transparent proxy example modules.

### HTTP(S) Proxy Modules

* http/**beefbox.rb** - Similar to injectjs but specialized to work with the [BeEF framework](http://beefproject.com).
* http/**debug.rb** - Debug HTTP requests and responses.
* http/**simple_post.rb** - Intercept and display only selected POST fields.
* http/**location_hijacking.rb**  - Hijack Location header with custom URL.
* http/**replace_images.rb** - Replace all images with a custom one.
* http/**rickroll.rb** - Inject an iframe with the (in)famous RickRoll video in autoplay mode.
* http/**hack_title.rb** - Add a "HACKED" text to website titles.
* http/**replace_file.rb** - Replace downloaded files on the fly with custom ones.

### TCP Proxy Modules

* tcp/**debug.rb** - Simply hex-dumps all TCP traffic going through the proxy.
* tcp/**sshdowngrade.rb** - If possible, perform a SSH 2.x -> 1.x downgrade attack.
* tcp/**mssqlauth.rb** - Downgrades MSSQL encryption and capture login credentials.
* tcp/**netsed.rb** - NetSed like tcp proxy module.

### Vulnerability Specific

* http/**androidpwn.rb** - Will execute a custom command on each Android device exploiting the "addJavascriptInterface" vulnerability.
* http/**osxsparkle.rb** - Will execute a custom Mach-O OSX executable on each OSX machine exploiting the Sparkle Updater vulnerability https://vulnsec.com/2016/osx-apps-vulnerabilities/ .
* http/**airdroid_info.rb** - Show leaked credentials from AirDroid traffic ( more [here](https://blog.zimperium.com/analysis-of-multiple-vulnerabilities-in-airdroid/) ).
* http/**airdroid_rce.rb** - Serve a spoofed update package to AirDroid in order to get RCE ( more [here](https://blog.zimperium.com/analysis-of-multiple-vulnerabilities-in-airdroid/) ).
