require 'em-hiredis'

module Meerkat
  module Backend
    class Redis
      def initialize(redis_uri = nil)
        @redis = EM::Hiredis.connect(redis_uri)
      end

      def publish(route, json)
        puts 'sending'
        @redis.publish route, json
      end

      def subscribe(route, &callback)
        @redis.subscribe route
        @redis.on :message do |channel, message|
          callback.call(message) 
        end
      end
    end
  end
end
