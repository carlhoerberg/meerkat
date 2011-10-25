require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/redis'

describe 'Redis backend' do
  include EM::MiniTest::Spec

  it 'can publish and subscribe to wildcards' do
    b = Meerkat::Backend::Redis.new
    b.subscribe '/foo/*' do |topic, msg| 
      assert_equal '/foo/bar', topic
      assert_equal 'messsage', msg
      done!
    end
    EM.next_tick {
      b.publish '/foo/bar', 'messsage'
    }
    wait!
  end

  it 'can publish and subscribe' do
    b = Meerkat::Backend::Redis.new
    b.subscribe '/' do |topic, msg| 
      assert_equal 'messsage', msg
      done!
    end
    EM.next_tick {
      b.publish '/', 'messsage'
    }
    wait!
  end

  it 'can unsubscribe' do
    b = Meerkat::Backend::Redis.new
    sid = b.subscribe 'route' do |msg| 
      @recivied = msg
    end
    b.unsubscribe sid
  end
end

