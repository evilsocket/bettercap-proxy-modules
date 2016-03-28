This repository contains some [bettercap](http://www.bettercap.org/) transparent proxy example modules.

### HTTP(S) Proxy Modules

* http/**androidpwn.rb** - Will execute a custom command on each Android device exploiting the "addJavascriptInterface" vulnerability.
* http/**osxsparkle.rb** - Will execute a custom Mach-O OSX executable on each OSX machine exploiting the Sparkle Updater vulnerability https://vulnsec.com/2016/osx-apps-vulnerabilities/ .
* http/**beefbox.rb** - Similar to injectjs but specialized to work with the [BeEF framework](http://beefproject.com).
* http/**debug.rb** - Debug HTTP requests and responses.
* http/**location_hijacking.rb**  - Hijack Location header with custom URL.
* http/**replace_images.rb** - Replace all images with a custom one.
* http/**rickroll.rb** - Inject an iframe with the (in)famous RickRoll video in autoplay mode.
* http/**hack_title.rb** - Add a "HACKED" text to website titles.

### TCP Proxy Modules

* tcp/**debug.rb** - Simply hex-dumps all TCP traffic going through the proxy.
* tcp/**sshdowngrade.rb** - If possible, perform a SSH 2.x -> 1.x downgrade attack.
* tcp/**mssqlauth.rb** - Downgrades MSSQL encryption and capture login credentials.
