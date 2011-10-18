#encoding: utf-8
require 'thin/async'
require 'yajl'

module Meerkat
  def self.backend=(backend)
    @@backend = backend
  end
  def self.backend
    @@backend
  end

  def self.publish(route, message)
    json = Yajl::Encoder.encode message
    @@backend.publish(route, json)
  end

  module Backend
    class InMemory
      def initialize()
        @channel = EventMachine::Channel.new
      end
      def publish(route, json)
        @channel.push({:route => route, :json => json})
      end
      def subscribe(route, &callback)
        @channel.subscribe do |msg|
          callback.call(msg[:json]) if msg[:route] == route
        end
      end
    end
  end

  class RackAdapter
    def initialize(app = nil, &blk)
      blk.call(self) if blk
    end
    attr_accessor :keep_alive
    attr_accessor :retry

    def call(env)
      response = Thin::AsyncResponse.new(env)
      response.status = 200
      response.headers['Content-Type'] = 'text/event-stream' 
      response << "retry: #{@retry || 3000}\n"

      path_info = Rack::Utils.unescape(env["PATH_INFO"])
      Meerkat.backend.subscribe(path_info) do |message|
        response << "data: #{message}\n\n"
      end
      EM.add_timer(keep_alive) do
        response << ":\n"
        response.done
      end
      response.finish
    end
  end
end
