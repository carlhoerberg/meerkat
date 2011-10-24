require 'pg'

module Meerkat
  module Backend
    class PG
      def initialize(pg_uri = nil)
        @pg_uri = pg_uri
        @pg = PGconn.connect pg_uri
      end

      def publish(route, json)
        @pg.exec "SELECT pg_notify($1, $2)", [route, json]
      end

      def subscribe(route, &callback)
        pg = PGconn.connect @pg_uri
        pg.exec "LISTEN #{route}"
        defer_notify(pg, &callback)
        pg
      end

      def defer_notify(pg, &callback)
        EM.defer(lambda {
          msg = nil
          pg.wait_for_notify do |route, pid, payload| 
            msg = payload
          end
          msg
        }, lambda { |msg| 
          callback.call msg
          defer_notify(pg, &callback)
        })
      end

      def unsubscribe(pg)
        pg.finish
      end
    end
  end
end

