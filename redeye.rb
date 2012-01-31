#!/usr/bin/env ruby

# redeye.rb, Jan 2012, Christopher Scott Hernandez
# runs a (infitely looping) script, while watching for 
# changes on that script, or the folders near it
# reloading the script if necessary
# similar to node.js' supervisor

# redeye tcpbot.rb 
#   -w/--watch: comma delimited list of files,folders to watch
#   -x/--executable: executable that runs the program, defaults to "ruby"
#   -r/--restart on error: auto-restart the program if exits with anything but 0
#   -h/--help: help stuff
#   -t/--intercal: time to check

module Redeye

  class Watcher

    def initialize(argv)
      # parse command line options
      # stash important info, flags, etc...
      # in instance variables
      @timer = IntervalTimer.new(5000) # check every 5 seconds
      @file = "/Users/chris/dev/ruby-stuff/tcpbot.rb"
    end

    def run
      start_process
      @timer.start_interval do
        puts "checking for modification..."
        if file_modified?
          restart_process
        end
      end
      # watch for changes
    end

    def restart_process
      kill_process
      puts "restarting process #{@pid}"
      start_process
    end

    def start_process
      puts "starting process: something..."
      @pid = Process::spawn("ruby", "/Users/chris/dev/ruby-stuff/tcpbot.rb")
    end

    def kill_process
      puts "killing process #{@pid}"
      Process::kill("SIGTERM", @pid)
    end

  end

  class IntervalTimer

    def initialize(interval_in_ms=2000)
      # default to one thousand milliseconds between intervals
      @interval = interval_in_ms / 1000
    end

    def start_interval
      @start_time = Time.now
      loop do
        if at_interval? and block_given?
          yield
          @start_time = Time.now
        end
      end
    end

    def at_interval?
      Time.now - @start_time > @interval
    end

  end

end

Redeye::Watcher.new(ARGV).run
# my_timer = Redeye::IntervalTimer.new
# my_timer.start_interval {puts "tick"}
# puts my_timer.ruthere
# my_timer.end_interval
# my_timer.instance_eval("puts @looping")
