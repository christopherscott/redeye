require 'optparse'
require 'ostruct'
require 'pp'

class Array
  def map_to_hash
    map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
  end
end

module Redeye
  
  module Helpers

    def parse_options!(defaults)

      @options = OpenStruct.new(defaults)
      @options.paths = Hash.new
      @option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: redeye.rb [options...] <file>"
        opts.separator ""
        opts.separator "Specific options:"
        opts.on("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        opts.on("-v", "--verbose", "Run verbosely" ) do
          @options.verbose = true
        end
        opts.on("-w", "--watch PATHS", Array,
          "Comma separated list of files/directories to watch") do |paths|
          @options.watchdirs = paths
        end
        opts.on("-x", "--executable PROGRAM",
        "Executable to run file (defaults to 'ruby')") do |program|
          @options.executable = program if File.executable? program
        end
        opts.on("-i", "--interval SECONDS", Integer,
        "Time interval (in seconds) to check for modifications") do |time|
          # store interval, must be 1 second or greater
          default_interval = Redeye::Watcher::DEFAULTS["interval"]
          @options.interval = time > 0 ? time : @options.interval
        end
        opts.on("-r", "--restart", "Auto-restart process on error") do
          @options.restart = true
        end
      end

      begin
        @option_parser.parse!
        if ARGV[0].nil?
          bugout "Missing required <file> argument"
        else
          mainfile = process_main_file(ARGV[0])
          @mainfile = {path: mainfile}
          record_times @options.watchdirs
        end
      rescue
        bugout
      end

    end

    def process_main_file(argument)
      file_to_run = File.expand_path(argument)
      if File.exists? file_to_run 
        file_to_run
      else
        raise IOError, "File does not exist: #{file_to_run}"
      end
    end

    def record_times(paths)
      # record time for main file
      @mainfile[:mtime] = File.mtime(@mainfile[:path])

      # loop through all watch directories, logging mtimes for each
      @options.watchdirs.each do |path|
        files = Dir.glob(File.join(File.expand_path(path),"**/*")).select do |path|
          !File.directory?(path)
        end
        count = files.length
        # map list of filenames into hash, where file location is key
        # and the file mtime is the value
        filelist = files.map_to_hash {|path| { path => File.mtime(path)}}
        @options.paths[path] = {
          :count => count,
          :files => filelist
        }
      end
    end

    def vlog(msg)
      puts msg if @options.verbose
    end

    def bugout(msg="")
      puts "#{($! || msg)}\n #{@option_parser.help}"
      exit
    end

  end

end