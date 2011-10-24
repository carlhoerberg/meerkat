require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/redis'

describe 'Redis backend' do
  include EM::MiniTest::Spec

  it 'can publish and subscribe' do
    b = Meerkat::Backend::Redis.new
    b.subscribe '/' do |msg| 
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

