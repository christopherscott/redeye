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

require './interval_timer'
require 'optparse'
require 'ostruct'

module Redeye

  class Watcher

    def initialize(argv)
      # parse command line options
      # stash important info, flags, etc...
      # in instance variables
      @timer = IntervalTimer.new(5000) # check every 5 seconds
      # TODO: convert singular file to array of files/dirs to check

      defaults = {
        interval: 2000,
        executable: "ruby",
        restart: false
      }

      @options = OpenStruct.new(defaults)

      option_parser = OptionParser.new do |opts|

        opts.banner = "Usage: redeye.rb [options...] <file>"
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on("-w", "--watch PATHS", Array, "Comma separated list of files/directories to watch") do |paths|
          @options.paths = paths
        end

        opts.on("-x", "--executable PROGRAM", "Executable to run file (defaults to 'ruby')") do |program|
          @options.executable = program
        end

        opts.on("-r", "--restart", "Auto-restart process on error") do
          @options.restart = true
        end

        opts.on("-i", "--interval MILLISECONDS", "Time interval (in milliseconds) to check for modifications") do |time|
          @options.interval = time
        end

      end

      begin
        option_parser.parse!
      rescue OptionParser::MissingArgument
        puts "#{$!}\n\n#{option_parser.help}"
        exit
      end

      
      exit

    end

    def run

      p @options.paths

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
      puts "starting process: #{@pid}"
      @pid = Process::spawn("ruby", @file)
      @last_modified = File.mtime(@file)
    end

    def kill_process
      puts "killing process #{@pid}"
      Process::kill("SIGTERM", @pid)
    end

    def file_modified?
      File.mtime(@file) != @last_modified
    end

  end

end

Redeye::Watcher.new(ARGV).run
