module SauceTunnel
  class Tunnel
    class Error < StandardError; end

    attr_reader :sc_path, :sc_args

    def initialize(sc_path: "sc", sc_args: [], quiet: false, timeout: 120, shutdown_timeout: 20)
      @sc_path = sc_path
      @sc_args = sc_args
      @quiet = quiet
      @timeout = timeout
      @shutdown_timeout = shutdown_timeout

      @queue = SauceTunnel::SimpleQueue.new
      @up = false
    end

    def connect
      return if @wait_thread # don't start twice

      @stdin, @stdout, @stderr, @wait_thread = Open3.popen3(Shellwords.join([sc_path] + [sc_args].flatten))

      @read_thread = Thread.new do
        while line = @stdout.gets
          puts line unless quiet?
          @queue.push(true) if line =~ /sauce connect is up/i
        end
      end

      at_exit do
        terminate
      end
    end

    def await
      @up ||= @queue.pop(@timeout)
      self
    rescue ThreadError
      raise ConnectionError, "timed out trying to establish connection to SauceLabs"
    end

    def terminate
      if @wait_thread
        Process.kill("TERM", @wait_thread.pid)
        @wait_thread.join(@shutdown_timeout)
      end
    rescue Errno::ESRCH
      # do nothing, tunnel already shut down
    end

    def quiet?
      @quiet
    end
  end
end
