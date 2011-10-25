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

      def publish(topic, json)
        @pub.publish topic, json
      end

      def subscribe(topic, &callback)
        if @subs[topic]
          @subs[topic] << callback
        else
          @subs[topic] = [ callback ]
          EM.next_tick {
            @sub.psubscribe topic 
            @sub.on :pmessage do |topic, channel, message|
              @subs[topic].each { |c| c.call channel, message }
            end
          }
        end
        [topic, callback]
      end

      def unsubscribe(sub)
        topic, cb = sub
        @subs[topic].delete cb
        if @subs[topic].empty?
          EM.next_tick do
            @subs.delete topic 
            @sub.punsubscribe(topic) 
          end
        end
      end
    end
  end
end
