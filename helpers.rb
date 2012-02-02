require 'optparse'
require 'ostruct'

module Redeye
  
  module Helpers

    def parse_options!(defaults)

      @options = OpenStruct.new(defaults)

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
          record_times :for => paths
        end

        opts.on("-x", "--executable PROGRAM",
        "Executable to run file (defaults to 'ruby')") do |program|
          @options.executable = program if File.executable? program
        end

        opts.on("-r", "--restart", "Auto-restart process on error") do
          @options.restart = true
        end

        opts.on("-i", "--interval MILLISECONDS", Integer,
        "Time interval (in milliseconds) to check for modifications") do |time|
          @options.interval = time
        end

      end

      begin
        @option_parser.parse!
      rescue
        bugout
      end

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

    def bugout(msg="")
      puts $! || msg
      puts ""
      puts @option_parser.help
      exit
    end

    def record_times(paths)
      paths[:for].each do |path|
        if File.exists?(path)
          @options.paths[File.expand_path(path)] = File.mtime(path)
        else
          puts %!ignoring "#{path}" -- file or directory does not exist!
        end
      end        
    end

  end

end