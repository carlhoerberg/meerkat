require './lib/meerkat/backend/amqp'
require 'eventmachine'

describe Meerkat::Backend::AMQP do
  around do |spec|
    EM.run { spec.call }
  end

  it 'can publish and subscribe' do
    subject.subscribe 'route' do |topic, msg| 
      topic.should == 'route'
      msg.should == 'foo'
      EM.stop
    end
    EM.add_timer(0.1) { subject.publish 'route', 'foo' }
  end

  it 'can subscribe to wildcards' do
    subject.subscribe 'foo.*' do |topic, msg| 
      topic.should == 'foo.bar'
      msg.should == 'barfoo'
      EM.stop
    end
    EM.add_timer(0.1) { subject.publish 'foo.bar', 'barfoo' }
  end

  it 'can unsubscribe' do
    sid = subject.subscribe('route') { |topic, msg| }
    EM.add_timer(0.1) do
      subject.unsubscribe sid      
      EM.stop 
    end
  end
end
