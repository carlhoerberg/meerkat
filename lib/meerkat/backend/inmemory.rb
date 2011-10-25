require 'eventmachine'

module Meerkat
  module Backend
    class InMemory
      def initialize
        @channel = EventMachine::Channel.new
      end

      def publish(topic, json)
        @channel.push({:topic => topic, :json => json})
      end

      def subscribe(topic, &callback)
        @channel.subscribe do |msg|
          if File.fnmatch? topic, msg[:topic]
            callback.call msg[:topic], msg[:json]
          end
        end
      end

      def unsubscribe(sid)
        @channel.unsubscribe(sid)
      end
    end
  end
end

