This repository contains some [bettercap](https://www.bettercap.org/) transparent proxy example modules.

### HTTP(S) Proxy Modules

* http/**beefbox.rb** - Similar to injectjs but specialized to work with the [BeEF framework](https://beefproject.com).
* http/**debug.rb** - Debug HTTP requests and responses.
* http/**curl_log.rb** - A simple logging module where all requests are logged in a form where they can easily be repeated with the `curl` command.
* http/**simple_post.rb** - Intercept and display only selected POST fields.
* http/**location_hijacking.rb**  - Hijack Location header with custom URL.
* http/**replace_images.rb** - Replace all images with a custom one.
* http/**rickroll.rb** - Inject an iframe with the (in)famous RickRoll video in autoplay mode.
* http/**hack_title.rb** - Add a "HACKED" text to website titles.
* http/**flip_image.rb** - Flips images on web pages.
* http/**replace_file.rb** - Replace downloaded files on the fly with custom ones.
* http/**download_autopwn.rb** - Renames & resizes local payloads and redirects victim's download requests if they match the specified file extensions and User-Agents.
* http/**download_redirect.rb** - Redirect URLs with specific file extensions to another URL to hijack the download process.
* http/**noscroll.rb** - Puts an invisible div over every HTML page.
* http/**keylogger.rb** - Send keystrokes through randomized GET requests.
* http/**ebay_passive_income_generator.rb** - Replace eBay product links with your affiliate link and get a piece of the pie.
* http/**makemoney.rb** - inject coinhive.com "JS" and make some money.

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
* http/**rkhunter_rce.rb** - Rootkit Hunter RCE ( more [here](http://seclists.org/oss-sec/2017/q2/643) )
* http/**jamf_rce.rb** - JAMF RCE ( more [here](https://www.tecklyfe.com/jamf-allow-mitm-attack/) )
