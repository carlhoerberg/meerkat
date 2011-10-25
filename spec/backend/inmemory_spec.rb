require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/inmemory'

describe 'The in memory backend' do
  include EM::MiniTest::Spec

  before do
    @im = Meerkat::Backend::InMemory.new
  end

  it 'can publish and subscribe' do
    @im.subscribe 'route' do |topic, msg| 
      assert_equal 'route', topic
      assert_equal 'foo', msg
      done!
    end
    @im.publish 'route', 'foo'
    wait!
  end
  it 'can subscribe to wildcards' do
    @im.subscribe '/foo/*' do |topic, msg| 
      assert_equal '/foo/bar', topic
      assert_equal 'barfoo', msg
      done!
    end
    @im.publish '/foo/bar', 'barfoo'
    wait!
  end
  it 'can unbsubscribe' do
    sid = @im.subscribe 'route' do |topic, msg| end
    @im.unsubscribe sid
  end
end
