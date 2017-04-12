module SauceTunnel
  # A really basic message queue, which unlike the queue in stdlib makes it
  # possible to specify a timeout for `pop`.
  class SimpleQueue
    def initialize
      @mutex = Mutex.new
      @queue = []
      @received = ConditionVariable.new
    end

    def push(value)
      @mutex.synchronize do
        @queue << value
        @received.signal
      end
    end

    def pop(timeout = nil)
      @mutex.synchronize do
        start_time = Time.now
        loop do
          if @queue.empty?
            elapsed_time = Time.now - start_time

            raise ThreadError, "queue empty" if elapsed_time >= timeout

            @received.wait(@mutex, timeout - elapsed_time)
          else
            break
          end
        end
        @queue.shift
      end
    end
  end
end
