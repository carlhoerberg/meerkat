require 'uri'
require 'hiredis'
require 'redis/connection/synchrony'
require 'redis'

module Meerkat
  module Backend
    class Redis
      def initialize(redis_uri = 'redis://localhost/0')
        u = URI.parse redis_uri
        h = {
          :host => u.host,
          :port => u.port || 6379,
          :user => u.user,
          :password => u.password,
          :db => u.path ? u.path[1..-1].to_i : 0 
        }
        @pub = ::Redis.new h
        @sub = ::Redis.new h
      end

      def publish(route, json)
        @pub.publish route, json
      end

      def subscribe(route, &callback)
        Fiber.new {
          @sub.subscribe route do |on|
            on.message do |channel, message|
              callback.call(message) 
            end
          end
        }.resume
      end

      def quit
        unsubscribe
        @pub.quit
        @sub.quit
      end
      def unsubscribe
        @sub.unsubscribe
      end
    end
  end
end
