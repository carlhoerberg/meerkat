require 'minitest/autorun'
require 'em/minitest/spec'
require './lib/meerkat/backend/pg'

describe 'Postgres backend' do
  include EM::MiniTest::Spec

  it 'can publish and subscribe' do
    b = Meerkat::Backend::PG.new :dbname => 'postgres'
    b.subscribe '/' do |msg| 
      assert_equal 'messsage', msg
      done!
    end
    b.publish '/', 'messsage'
    wait!
  end

  it 'can unsubscribe' do
    b = Meerkat::Backend::PG.new :dbname => 'postgres'
    sid = b.subscribe 'route' do |msg| 
    end
    b.unsubscribe sid
  end
end

