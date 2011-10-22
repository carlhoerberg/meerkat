require 'eventmachine'

module Meerkat
  module Backend
    class InMemory
      def initialize
        @channel = EventMachine::Channel.new
      end

      def publish(route, json)
        @channel.push({:route => route, :json => json})
      end

      def subscribe(route, &callback)
        @channel.subscribe do |msg|
          callback.call(msg[:json]) if msg[:route] == route
        end
      end
    end
  end
end

