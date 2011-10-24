require 'bundler/setup'
require 'meerkat' 
require './app'

#Meerkat.backend = Meerkat::Backend::InMemory.new
#Meerkat.backend = Meerkat::Backend::Redis.new 
Meerkat.backend = Meerkat::Backend::PG.new :dbname => 'postgres'
map '/' do
  run App
end
map '/stream' do
  run Meerkat::RackAdapter.new
end
