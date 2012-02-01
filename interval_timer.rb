module Redeye

  class IntervalTimer

    def initialize(interval_in_ms=500)
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