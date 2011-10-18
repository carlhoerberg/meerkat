require 'thin/async'

module Meerkat
  class RackAdapter
    attr_accessor :keep_alive
    attr_accessor :retry
    attr_accessor :timeout

    def initialize(app = nil, &blk)
      blk.call(self) if blk
    end

    def call(env)
      response = Thin::AsyncResponse.new(env)
      response.status = 200
      response.headers['Content-Type'] = 'text/event-stream' 
      response << "retry: #{@retry || 3000}\n"

      path_info = Rack::Utils.unescape env["PATH_INFO"]
      Meerkat.subscribe(path_info) do |message|
        puts "responding"
        response << "data: #{message}\n\n"
      end
      EM.add_periodic_timer(@keep_alive || 20) do
        response << ":\n"
      end
      EM.add_timer(@timeout) { response.done } if @timeout
      response.finish
    end
  end
end
