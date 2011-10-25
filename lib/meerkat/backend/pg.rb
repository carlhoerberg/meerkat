require 'pg'
require 'date'

module Meerkat
  module Backend
    class PG
      TABLENAME = 'meerkat_pubsub'.freeze

      def initialize(pg_uri = nil)
        @subs = {}
        @pg = PGconn.connect pg_uri
        @pg.exec 'SET client_min_messages = warning'
        table = @pg.exec "SELECT true FROM pg_tables WHERE tablename = $1", [TABLENAME]
        @pg.exec "CREATE TABLE #{TABLENAME} (topic varchar(1024), json text, timestamp timestamp default now())" if table.count == 0

        @last_check = @pg.exec('SELECT now() as now').first['now']

        @sub_client = PGconn.connect pg_uri
        @sub_client.exec "LISTEN #{TABLENAME}"
        EM.next_tick {
          EM.watch(@sub_client.socket, SubscribeClient, @sub_client, lambda {on_notify}) { |c| c.notify_readable = true }
        }
      end

      def on_notify
        @pg.async_exec "SELECT topic, json, timestamp FROM #{TABLENAME} WHERE timestamp > $1 ORDER BY timestamp ASC", [@last_check] do |rows|
          rows.each do |row| 
            @last_check = row['timestamp']
            @subs.each do |topic, callbacks|
              if topic == row['topic'] 
                callbacks.each { |cb| cb.call row['json'] }
              end
            end
          end
        end
      end

      def publish(route, json)
        @pg.transaction do |conn|
          conn.exec "DELETE FROM #{TABLENAME} WHERE timestamp < now() - interval '5 seconds'"
          conn.exec "INSERT INTO #{TABLENAME} (topic, json) VALUES ($1, $2)", [route, json]
          conn.exec "NOTIFY #{TABLENAME}"
        end
      end

      def subscribe(route, &callback)
        if @subs[route]
          @subs[route] << callback
        else
          @subs[route] = [callback]
        end
        [route, callback]
      end

      def unsubscribe(sid)
        @subs[sid[0]].delete sid[1]
      end

      module SubscribeClient
        def initialize(pg, cb)
          @pg = pg
          @cb = cb
          @last_check = Time.now
        end

        def notify_readable
          @pg.consume_input
          @cb.call if @pg.notifies
        end

        def unbind
          @pg.close
        end
      end
    end
  end
end

