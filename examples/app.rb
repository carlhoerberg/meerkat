require 'sinatra/base'
require './lib/meerkat' # require 'meerkat' when using the gem

class App < Sinatra::Base
  get '*' do
    haml :pubsub
  end
  post '*' do
    Meerkat.publish params[:splat], params[:message]
  end
end

