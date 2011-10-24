require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/redis'

describe 'Redis backend' do
  #include EM::MiniTest::Spec

  it 'can publish and subscribe' do
    EM.synchrony do
      b = Meerkat::Backend::Redis.new 'redis://localhost:6379/0'
      b.subscribe 'route' do |msg| 
        @msg = msg
      end
      b.publish 'route', 'messsage'
      assert_equal 'messsage', @msg
      b.quit
      EM.stop
    end
  end

  it 'can does only subscribe to specific routes' do
    EM.synchrony do
      b = Meerkat::Backend::Redis.new
      b.subscribe 'route' do |msg| 
        @recivied = msg
      end
      b.publish 'route2', 'messsage'
      assert_equal nil, @recivied
      b.quit
      EM.stop
    end
  end
end

