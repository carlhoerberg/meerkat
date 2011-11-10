require_relative 'meerkat/version'
require_relative 'meerkat/rackadapter'
require_relative 'meerkat/backend/inmemory'
require_relative 'meerkat/backend/redis'
require_relative 'meerkat/backend/pg'
require 'yajl'

module Meerkat
  extend self

  def backend=(backend)
    @backend = backend
  end

  def publish(route, message, is_json = false)
    json = is_json ? message : Yajl::Encoder.encode(message)
    @backend.publish(route, json) 
  end

  def subscribe(route, &callback)
    @backend.subscribe(route, &callback)
  end

  def unsubscribe(sid)
    @backend.unsubscribe(sid)
  end
end

