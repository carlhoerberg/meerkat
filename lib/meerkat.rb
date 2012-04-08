require_relative 'meerkat/version'
require_relative 'meerkat/rackadapter'
require 'multi_json'

module Meerkat
  extend self

  def backend=(backend)
    @backend = backend
  end

  def publish(topic, message, is_json = false)
    raise "Topic is required" if topic.nil?
    raise "Message is required" if message.nil?
    json = is_json ? message : MultiJson.encode(message)
    @backend.publish(topic, json) 
  end

  def subscribe(topic, &callback)
    raise "Topic is required" if topic.nil?
    @backend.subscribe(topic, &callback)
  end

  def unsubscribe(sid)
    @backend.unsubscribe(sid)
  end
end

