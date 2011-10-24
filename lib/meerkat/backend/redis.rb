require 'em-hiredis'

module Meerkat
  module Backend
    class Redis
      def initialize(redis_uri = nil)
        @redis_uri = redis_uri
        EM.next_tick {
          @pub = EM::Hiredis.connect redis_uri
        }
      end

      def publish(route, json)
        @pub.publish route, json
      end

      def subscribe(route, &callback)
        sub = EM::Hiredis.connect @redis_uri
        sub.subscribe route 
        sub.on :message do |channel, message|
          callback.call(message) 
        end
        sub
      end

      def unsubscribe(sub)
        sub.close_connection
      end
    end
  end
end
