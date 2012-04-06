require 'rack/test'
require 'thin/async/test'
require './lib/meerkat'
require './lib/meerkat/backend/inmemory'

describe Meerkat do
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
    last_response.status.should == 200
    last_response.headers['Content-Type'].should == 'text/event-stream'
  end

  it 'first return a retry value' do
    get '/'
    last_response.body.lines.first.should == "retry: 3000\n"
  end

  it 'should periodically emit a comment to keep alive the connection' do
    get '/'
    last_response.body.split("\n")[1].should == ":"
  end
  
  it 'should publish POST data and treat it like JSON' do
    backend = stub
    backend.should_receive(:publish).with('/foo', '"bar"')
    Meerkat.backend = backend
    post '/foo', :json => '"bar"'
    last_response.status.should == 204
  end

  it 'should return error 400 when there is no "json" POST parameters' do
    post '/', :foo => 'bar'
    last_response.status.should == 400
  end

  it 'should return error 400 when there is no POST data' do
    post '/foo'
    last_response.status.should == 400
  end

  it 'should return 404 for anything but GET and POST requests' do
    delete '/foo'
    last_response.status.should == 404
    options '/foo'
    last_response.status.should == 404
    head '/foo'
    last_response.status.should == 404
    put '/foo'
    last_response.status.should == 404
  end
end
