require 'sinatra/base'

class App < Sinatra::Base
  get '*' do
    @route = params[:splat].join
    haml :index
  end
  post '*' do
    Meerkat.publish params[:splat].join, params[:message]
    204
  end
end

