require 'em-hiredis'

module Meerkat
  module Backend
    class Redis
      def initialize(redis_uri = nil)
        @redis_uri = redis_uri
        @subs = {}
        EM.next_tick { 
          @sub = EM::Hiredis.connect redis_uri 
          @pub = EM::Hiredis.connect redis_uri 
        }
      end

      def publish(route, json)
        @pub.publish route, json
      end

      def subscribe(route, &callback)
        if @subs[route]
          @subs[route] << callback
        else
          @subs[route] = [ callback ]
          EM.next_tick {
            @sub.subscribe route 
            @sub.on :message do |channel, message|
              @subs[route].each { |c| c.call message }
            end
          }
        end
        [route, callback]
      end

      def unsubscribe(sub)
        @subs[sub[0]].delete sub[1]
        EM.next_tick {
          @sub.unsubscribe(sub[0]) if @subs[sub[0]].empty?
        }
      end
    end
  end
end
