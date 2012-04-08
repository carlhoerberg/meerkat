require 'amqp'

module Meerkat
  module Backend
    class AMQP
      def initialize(amqp_url = 'amqp://guest:guest@localhost')
        @conn = ::AMQP.connect amqp_url
      end

      def publish(topic, json)
        ::AMQP::Channel.new @conn do |ch|
          ch.topic("meerkat").publish(json, :routing_key => topic)
        end
      end

      def subscribe(topic, &callback)
        ::AMQP::Channel.new @conn do |ch|
          ch.queue('', :auto_delete => true) do |queue|
            queue.bind(ch.topic("meerkat"), :routing_key => topic)
            queue.subscribe do |headers, payload|
              callback.call headers.routing_key, payload
            end
          end
        end
      end

      def unsubscribe(channel)
        channel.close
      end
    end
  end
end
