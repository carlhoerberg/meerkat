require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/inmemory'

describe 'The in memory backend' do
  include EM::MiniTest::Spec

  it 'can publish and subscribe' do
    im = Meerkat::Backend::InMemory.new
    im.subscribe 'route' do |msg| 
      @recivied = msg
    end
    im.publish 'route', 'messsage'
    assert_equal 'messsage', @recivied 
  end
  it 'can does only subscribe to specific routes' do
    im = Meerkat::Backend::InMemory.new
    im.subscribe 'route' do |msg| 
      @recivied = msg
    end
    im.publish 'route2', 'messsage'
    assert_equal nil, @recivied
  end
  it 'can unbsubscribe' do
    im = Meerkat::Backend::InMemory.new
    sid = im.subscribe 'route' do |msg| 
    end
    im.unsubscribe sid
  end
end
