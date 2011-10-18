require_relative 'meerkat/rackadapter'
require_relative 'meerkat/backend/inmemory'
require 'yajl'

module Meerkat
  extend self

  def backend=(backend)
    @backend = backend
  end

  def publish(route, message)
    json = Yajl::Encoder.encode message
    @backend.publish(route, json)
  end

  def subscribe(route, &callback)
    @backend.subscribe(route, &callback)
  end
end

