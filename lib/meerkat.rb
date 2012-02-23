require_relative 'meerkat/version'
require_relative 'meerkat/rackadapter'
require 'multi_json'

module Meerkat
  extend self

  def backend=(backend)
    @backend = backend
  end

  def publish(route, message, is_json = false)
    json = is_json ? message : MultiJson.encode(message)
    @backend.publish(route, json) 
  end

  def subscribe(route, &callback)
    @backend.subscribe(route, &callback)
  end

  def unsubscribe(sid)
    @backend.unsubscribe(sid)
  end
end

