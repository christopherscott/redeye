#!/usr/bin/env ruby

# redeye.rb, Jan 2012, Christopher Scott Hernandez
# runs a (infitely looping) script, while watching for 
# changes on that script, or the folders near it
# reloading the script if necessary
# similar to node.js' supervisor

# redeye tcpbot.rb 
#   -h/--help
#   -w/--watch: comma delimited list of files,folders to watch
#   -x/--executable: executable that runs the program, defaults to "ruby"
#   -i/--interval: time interval to check for file modifications
#   -r/--restart on error: auto-restart the program if exits with anything but 0

# TODO: 
# => add 'verbose' command line option
# => test against multiple files/dirs
# => test against windows version
# => test against linux version
# => test against jruby
# => add license
# => add meaningful comments
# => add docco documentation
# => refactor into gem (per specification)
# => capture SIGINT, other sigs, clean up nicely

require './interval_timer'
require './helpers'
require 'pp'

module Redeye

  class Watcher
    
    include Redeye::Helpers

    def initialize(argv)

      parse_options!({

        # defaults:

        interval: 2000,
        executable: "ruby",
        restart: false,
        paths: {}

      })
      
      @timer = IntervalTimer.new(@options.interval)

      pp @options

    end

    

    def run
      p @options.paths
      start_process
      @timer.start_interval do
        puts "checking for modifications..."
        if anything_was_modified?
          record_times :for => @options.paths.keys
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
      puts "starting process: #{@pid}"
      @pid = Process::spawn("ruby", @file)
    end

    def kill_process
      puts "killing process #{@pid}"
      Process::kill("SIGTERM", @pid)
    end

    def anything_was_modified?
      @options.paths.each do |path, mtime|
        puts "path: #{path}, recorded-mtime: #{mtime}, current-mtime: #{File.mtime(path)}"
        if File.mtime(path) != mtime
          return true
        end
      end
      false
    end

  end

end

Redeye::Watcher.new(ARGV).run
