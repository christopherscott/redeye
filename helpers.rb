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
        opts.on("-w", "--watch PATHS", Array,
          "Comma separated list of files/directories to watch") do |paths|
          record_times :paths => paths, :initial => true
        end
        opts.on("-x", "--executable PROGRAM",
        "Executable to run file (defaults to 'ruby')") do |program|
          @options.executable = program if File.executable? program
        end
        opts.on("-i", "--interval MILLISECONDS", Integer,
        "Time interval (in milliseconds) to check for modifications") do |time|
          @options.interval = time
        end
        opts.on("-r", "--restart", "Auto-restart process on error") do
          @options.restart = true
        end
        opts.on("-v", "--verbose", "Run verbosely" ) do
          @options.verbose = true
        end
      end

      # start parsing options
      begin @option_parser.parse! rescue bugout end

      # validate required <file> argument
      begin
        if ARGV[0].nil?
          bugout "Missing required <file> argument"
        else
          @file = process_main_file(ARGV[0])
          @options.paths[File.expand_path(@file)] = File.mtime(@file)
        end
      rescue IOError
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

    def record_times(options)
      options[:paths].each do |path|
        path = File.expand_path(path)
        unless options[:initial] and !File.exists?(path)
          @options.paths[path] = File.mtime(path)
        else
          vlog %!ignoring "#{path}" -- file or directory does not exist!
        end
      end
    end

    def vlog(msg)
      puts msg if @options.verbose
    end

    def bugout(msg="")
      puts ($! || msg) + "\n #{@option_parser.help}"
      exit
    end

  end

end