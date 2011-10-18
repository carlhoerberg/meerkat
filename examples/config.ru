require 'meerkat' 
require './app'

map '/' do
  run App
end
map '/events' do
  run Meerkat::RackAdapter.new
end
