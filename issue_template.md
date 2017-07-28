Thanks for using Soft U2F. I'm sorry that you've encountered a bug.

## System information

To aide in debugging, please provide the output from running the following commands:

#### `sw_vers`

This tells us the version of macOS you are running. Soft U2F only works on macOS Sierra (10.12) and newer.

#### `file /Library/Extensions/softu2f.kext /Applications/SoftU2F.app ~/Library/LaunchAgents/com.github.SoftU2F.plist`

This confirms that the various components of Soft U2F were successfully installed.

#### `kextstat -b com.github.SoftU2FDriver`

This confirms that the Soft U2F driver is loaded.

#### `ps aux | grep SoftU2F.app`

This confirms that the Soft U2F app is running.

#### `grep SoftU2F -a20 -b20 /var/log/install.log | sort -g | uniq | tail -n200`

This grabs logs from your installation of Soft U2F. Other system details are included in this log file and the command attempts to filter the file down to details that might be relevant to Soft U2F. Still, you might want to verify that no information is included in these results that you aren't comfortable sharing.
