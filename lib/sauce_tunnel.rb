require "open3"
require "shellwords"

module SauceTunnel
  class Error < StandardError; end
  class ConnectionError < Error; end

  def self.start(**options)
    Tunnel.new(**options).tap do |tunnel|
      at_exit do
        tunnel.terminate
      end
      tunnel.connect
      tunnel.await
    end
  end
end

require "sauce_tunnel/simple_queue"
require "sauce_tunnel/tunnel"
