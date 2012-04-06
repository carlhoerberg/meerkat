require 'eventmachine'
require './lib/meerkat/backend/pg'

describe 'Postgres backend' do
  around do |spec|
    EM.run { spec.call }
  end

  def done!
    EM.stop
  end

  subject { Meerkat::Backend::PG.new :dbname => 'postgres' }

  it 'create required table only once' do
    subject.send :create_table
    subject.send :create_table
    done!
  end

  it 'can subscribe to partial wildcard' do
    subject.subscribe '/foo/*' do |topic, msg| 
      topic.should == '/foo/bar'
      msg.should == 'messsage'
      done!
    end
    subject.publish '/foo/bar', 'messsage'
  end

  it 'can subscribe to wildcard' do
    subject.subscribe '*' do |topic, msg| 
      msg.should == 'messsage'
      done!
    end
    subject.publish '/', 'messsage'
  end

  it 'can publish and subscribe' do
    subject.subscribe '/' do |topic, msg| 
      msg.should == 'messsage'
      done!
    end
    subject.publish '/', 'messsage'
  end

  it 'can publish and subscribe multiple messages' do
    i = 5
    j = 0
    subject.subscribe '/' do |topic, msg| 
      j += 1
      msg.should == 'messsage'
      done! if j == i
    end
    i.times { subject.publish '/', 'messsage' }
  end

  it 'can unsubscribe' do
    sid = subject.subscribe 'route' do |topic, msg| end
    subject.unsubscribe sid
    done!
  end
end

