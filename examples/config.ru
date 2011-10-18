require 'meerkat' 
require './app'

Meerkat.backend = Meerkat::Backend::InMemory.new
map '/' do
  run App
end
map '/stream' do
  run Meerkat::RackAdapter.new
end
