# Redeye

A command line utility for restarting a shell process if changes are detected in one (or many) directories. Takes one mandatory argument: the file to run in process. Any changes to that file and Redeye will kill and restart it for you automatically. Defaults to running script with "ruby" executable, and watching for changes every five (5) seconds. Will detect changes to any file, as well as any new files/folders that are added

### Note: new file detection
Redeye will only watch for when an actual file is created. It will not restart the process if an empty folder is created, for instance. 

## Usage:
  redeye [options] <file-to-run> 
    -h/--help
    -w/--watch: comma delimited list of files, folders to watch
    -x/--executable: executable that runs the program, defaults to "ruby"
    -i/--interval: time interval to check for file modifications
    -r/--restart on error: auto-restart the program if exits with anything but 0

## Examples:

    $ redeye.rb server-script.rb

Spawn new process "ruby server-script.rb". Watch for changes to "server-script.rb", if any are detected it kills and restarts the subprocess.

    $ redeye.rb -w /usr/lib/data server-script.rb

Watch for changes to to any file in "/usr/lib/data" (and all it's subfolders), as well as "server-script.rb".

    $ redeye.rb -w /usr/lib/data,/usr/bin,/usr/var server-script.rb

Watch for changes in all the following: /usr/lib/data, /usr/bin, /usr/var, server-script.rb

    $ redeye.rb -i 10 server-script.rb

Watch for changes to "server-script" every 10 seconds.

    $ redeye.rb -x /bin/sh shell-script.sh 

Spawn "/bin/sh shell-script.sh" and watch for changes to shell-script.sh