require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/pg'

describe 'Postgres backend' do
  include EM::MiniTest::Spec

  before do
    @b = Meerkat::Backend::PG.new :dbname => 'postgres'
  end

  it 'can subscribe to partial wildcard' do
    @b.subscribe '/foo/*' do |topic, msg| 
      assert_equal '/foo/bar', topic
      assert_equal 'messsage', msg
      done!
    end
    @b.publish '/foo/bar', 'messsage'
    wait!
  end

  it 'can subscribe to wildcard' do
    @b.subscribe '*' do |topic, msg| 
      assert_equal 'messsage', msg
      done!
    end
    @b.publish '/', 'messsage'
    wait!
  end

  it 'can publish and subscribe' do
    @b.subscribe '/' do |topic, msg| 
      assert_equal 'messsage', msg
      done!
    end
    @b.publish '/', 'messsage'
    wait!
  end

  it 'can publish and subscribe multiple messages' do
    i = 5
    j = 0
    @b.subscribe '/' do |topic, msg| 
      j += 1
      assert_equal 'messsage', msg
      done! if j == i
    end
    i.times { @b.publish '/', 'messsage' }
    wait!
  end

  it 'can unsubscribe' do
    sid = @b.subscribe 'route' do |topic, msg| end
    @b.unsubscribe sid
  end
end

