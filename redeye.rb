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
      default_options = {
        # defaults options
        :interval => 2000,
        :executable => "ruby",
        :restart => false,
        :paths => {}
      }
      # parse command line options
      parse_options!(default_options)
      # assuming all went well, initialize timer
      @timer = IntervalTimer.new(@options.interval)
      # for debugging, ok to remove
      pp @options
    end

    def run
      # for debugging, ok to remove
      p @options.paths
      # kick off the script
      start_process
      # start the timer
      @timer.start_interval do
        # for debugging ok to remove
        puts "checking for modifications..."
        # check for any changes
        if anything_was_modified?
          # record new times for all paths
          record_times :paths => @options.paths.keys
          # restart the process
          restart_process
        end
      end
    end

    def restart_process
      kill_process
      # verbose
      puts "restarting process #{@pid}"
      start_process
    end

    def start_process
      # verbose
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
