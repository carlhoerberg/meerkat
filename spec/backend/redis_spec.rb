require './lib/meerkat/backend/redis'
require 'eventmachine'

describe Meerkat::Backend::Redis do
  around do |spec|
    EM.run { spec.call }
  end

  it 'can publish and subscribe to wildcards' do
    subject.subscribe '/foo/*' do |topic, msg| 
      topic.should == '/foo/bar'
      msg.should == 'messsage'
      EM.stop
    end
    EM.next_tick {
      subject.publish '/foo/bar', 'messsage'
    }
  end

  it 'can publish and subscribe' do
    subject.subscribe '/' do |topic, msg| 
      msg.should == 'messsage'
      EM.stop
    end
    EM.next_tick {
      subject.publish '/', 'messsage'
    }
  end

  it 'can unsubscribe' do
    sid = subject.subscribe('route')
    subject.unsubscribe sid
    EM.stop
  end
end

