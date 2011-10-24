module Meerkat
  class RackAdapter
    attr_accessor :keep_alive
    attr_accessor :retry
    attr_accessor :timeout

    def initialize(app = nil, &blk)
      blk.call(self) if blk
    end

    def call(env)
      body = DeferrableBody.new

      EM.next_tick { 
        env['async.callback'].call [200, {'Content-Type' => 'text/event-stream'}, body] 
      }

      EM.next_tick {
        body << "retry: #{@retry || 3000}\n"
      }

      path_info = Rack::Utils.unescape env["PATH_INFO"]
      sub = Meerkat.subscribe(path_info) do |message|
        body << "data: #{message}\n\n"
      end
      body.errback {
        Meerkat.unsubscribe sub
      }

      EM.add_periodic_timer(@keep_alive || 20) do
        body << ":\n"
      end

      EM.add_timer(@timeout) { body.succeed } if @timeout


      [-1, {}, []]
    end

    class DeferrableBody
      include EventMachine::Deferrable

      def call(body)
        body.each do |chunk|
          @body_callback.call(chunk)
        end
      end

      def <<(str)
        call([str])
      end

      def each(&blk)
        @body_callback = blk
      end
    end
  end
end
