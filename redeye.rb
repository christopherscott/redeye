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
# => test against windows version
# => test against linux version
# => test against jruby
# => add license
# => add documentation
# => refactor into gem (per specification)

require './helpers'

module Redeye

  class Watcher
    
    DEFAULTS = {
      executable: "ruby",
      interval: 5,
      restart: false,
      verbose: false
    }
    
    include Redeye::Helpers

    def initialize(argv)
      parse_options!(DEFAULTS)
    end

    def run
      vlog "[Redeye starting....]"
      vlog "[watching: *#{@mainfile[:path]} #{@options.watchdirs.join(', ')}]"
      vlog "[interval: #{@options.interval} seconds]"
      vlog "[press CONTROL-C to stop Redeye]"
      vlog ""

      start_process

      loop do
        trap("INT") { puts " [SIGINT: cleaning up]"; kill_process; exit }
        vlog "[checking for modifications... ]"
        if anything_was_modified?
          record_times
          restart_process
        end
        sleep @options.interval
      end
      
    end

    def restart_process
      kill_process
      vlog "[restarting process #{@pid}]"
      start_process
    end

    def start_process
      @pid = Process::spawn(@options.executable, @mainfile[:path])
      Process::detach(@pid)
      vlog "[starting process: #{@pid}]"
    end

    def kill_process
      Process::kill("SIGTERM", @pid)
      vlog "[killing process #{@pid}]"
    end

    def anything_was_modified?
      modified = false
      if @mainfile[:mtime] != File.mtime(@mainfile[:path])
        return true
      end
      @options.paths.each do |path, meta|
        if count_different?(path, meta[:count]) or mtimes_different?(meta[:files])
          modified = true
          break
        end
      end
      modified
    end

    def count_different?(path, count)
      filelist = Dir.glob(File.join(File.expand_path(path),"**/*")).select do |path|
        !File.directory?(path)
      end
      filelist.length != count
    end

    def mtimes_different?(filelist)
      modified = false
      filelist.each do |file, mtime|
        if File.mtime(file) != mtime
          modified = true
          break
        end
      end
      modified
    end

  end

end

if __FILE__ == $0
  Redeye::Watcher.new(ARGV).run
end

