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
        pg.exec "LISTEN #{PGconn.quote_ident route}"
        EM.watch(pg.socket, SubscribeClient, pg, callback) { |c| c.notify_readable = true }
      end

      def unsubscribe(pg)
        pg.detach
      end

      module SubscribeClient
        def initialize(pg, cb)
          @pg = pg
          @cb = cb
        end
        def notify_readable
          @pg.consume_input
          msg = @pg.notifies
          @cb.call(msg[:extra]) if msg
        end
        
        def unbind
          @pg.close
        end
      end
    end
  end
end

