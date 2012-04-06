require './lib/meerkat/backend/inmemory'
require 'eventmachine'

describe Meerkat::Backend::InMemory do
  around do |spec|
    EM.run { spec.call }
  end

  it 'can publish and subscribe' do
    subject.subscribe 'route' do |topic, msg| 
      topic.should == 'route'
      msg.should == 'foo'
      EM.stop
    end
    EM.next_tick do 
      subject.publish 'route', 'foo'
    end
  end

  it 'can subscribe to wildcards' do
    subject.subscribe '/foo/*' do |topic, msg| 
      topic.should == '/foo/bar'
      msg.should == 'barfoo'
      EM.stop
    end
    EM.next_tick do 
      subject.publish '/foo/bar', 'barfoo'
    end
  end

  it 'can unbsubscribe' do
    sid = subject.subscribe 'route' do |topic, msg| end
    subject.unsubscribe sid
    EM.stop
  end
end
