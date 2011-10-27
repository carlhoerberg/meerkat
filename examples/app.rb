require 'sinatra/base'
require 'haml'

class App < Sinatra::Base
  get '/' do
    haml :index
  end

  post '/' do
    Meerkat.publish params[:topic], params[:message]
    204
  end
end

