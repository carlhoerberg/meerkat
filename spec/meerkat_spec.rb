require 'bundler/setup'
require 'minitest/autorun'
require 'rack/test'
require 'thin/async/test'
require './lib/meerkat'

describe 'Meerkat' do
  include Rack::Test::Methods

  before do
    Meerkat.backend = Meerkat::Backend::InMemory.new
  end

  def app
    Rack::Builder.new {
      meerkat = Meerkat::RackAdapter.new do |m|
        m.keep_alive = 0.1
        m.timeout = 0.2
      end
      run Thin::Async::Test.new(meerkat)
    }.to_app
  end

  it 'should return status 200 and content-type text/event-stream' do
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/event-stream', last_response.headers['Content-Type']
  end

  it 'first return a retry value' do
    get '/'
    assert_equal "retry: 3000\n", last_response.body.lines.first
  end

  it 'should periodically emit a comment to keep alive the connection' do
    get '/'
    assert_equal ":", last_response.body.split("\n")[1]
  end
  
  it 'should publish POST data and treat it like JSON' do
    mock = MiniTest::Mock.new
    mock.expect(:publish, nil, ['/foo', '"bar"'])
    Meerkat.backend = mock
    post '/foo', :json => '"bar"'

    assert_equal 204, last_response.status
    assert mock.verify
  end

  it 'should return error 400 when there is no "json" POST parameters' do
    post '/', :foo => 'bar'
    assert_equal 400, last_response.status
  end

  it 'should return error 400 when there is no POST data' do
    post '/foo'
    assert_equal 400, last_response.status
  end

  it 'should return 404 for anything but GET and POST requests' do
    delete '/foo'
    assert_equal 404, last_response.status
    options '/foo'
    assert_equal 404, last_response.status
    head '/foo'
    assert_equal 404, last_response.status
    put '/foo'
    assert_equal 404, last_response.status
  end
end
