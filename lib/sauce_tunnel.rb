require "open3"
require "shellwords"

module SauceTunnel
  class Error < StandardError; end
  class ConnectionError < Error; end

  @config = {}
  @mutex = Mutex.new
  @tunnel = nil

  class << self
    def config(**config)
      @config = config;
    end

    def start
      # Wrap establishing Tunnel in Mutex since the Tunnel class is not thread safe.
      @mutex.synchronize do
        @tunnel ||= begin
          Tunnel.new(**@config).tap do |tunnel|
            at_exit do
              tunnel.terminate
            end
            tunnel.connect
            tunnel.await
          end
        end
      end
    end
  end
end

require "sauce_tunnel/simple_queue"
require "sauce_tunnel/tunnel"
