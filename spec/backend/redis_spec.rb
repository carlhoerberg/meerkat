require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/redis'

describe 'Redis backend' do
  include EM::MiniTest::Spec

  it 'can publish and subscribe' do
    b = Meerkat::Backend::Redis.new
    b.subscribe 'route' do |msg| 
      @recivied = msg
    end
    b.publish 'route', 'messsage'
    assert_equal 'messsage', @recivied 
  end
  
  it 'can does only subscribe to specific routes' do
    b = Meerkat::Backend::Redis.new
    b.subscribe 'route' do |msg| 
      @recivied = msg
    end
    b.publish 'route2', 'messsage'
    assert_equal nil, @recivied
  end
end

