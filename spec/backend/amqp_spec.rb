require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/amqp'

describe Meerkat::Backend::AMQP do
  include EM::MiniTest::Spec
  subject { Meerkat::Backend::AMQP.new }

  it 'can publish and subscribe' do
    subject.subscribe 'route' do |topic, msg| 
      assert_equal 'route', topic
      assert_equal 'foo', msg
      done!
    end
    EM.next_tick { subject.publish 'route', 'foo' }
    wait!
  end

  it 'can subscribe to wildcards' do
    subject.subscribe 'foo.*' do |topic, msg| 
      assert_equal 'foo.bar', topic
      assert_equal 'barfoo', msg
      done!
    end
    EM.next_tick { subject.publish 'foo.bar', 'barfoo' }
    wait!
  end

  it 'can unsubscribe' do
    sid = subject.subscribe('route') { |topic, msg| }
    subject.unsubscribe sid
  end
end
