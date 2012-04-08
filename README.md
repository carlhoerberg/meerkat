Meerkat
=======

Rack middleware for [Server-Sent Events (HTML5 SSE)](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

Requires an [EventMachine](https://github.com/eventmachine/eventmachine#readme) backed server, like [Thin](http://code.macournoyer.com/thin/) or [Rainbows](http://rainbows.rubyforge.org/) (with the EventMachine backend only).

Features: 

* Realtime events
* Extremely efficent
* Broad browser support (both desktop and mobile browsers)
* Works with all proxies (unlike WebSockets)
* Subscribe to single events
* Subscribe to multiple events via patterns
* Publish messages from the server
* Publish messages from the client (via POST)

Supported backends: 

* In memory, using [EventMachine Channels](http://eventmachine.rubyforge.org/EventMachine/Channel.html), good for single server usage.
* RabbitMQ (AMQP), using the [AMQP gem](https://github.com/amqp/amqp-ruby) and the Pub/Sub pattern (Topic exchange + anonymous queues with pattern matching). AMQP is the most recommened alternative.
* Redis, using [em-hiredis](https://github.com/mloughran/em-hiredis#readme) and the [Pub/Sub API](http://redis.io/topics/pubsub). 
* Postgres, using the [Notify/Listen API](http://www.postgresql.org/docs/9.1/static/sql-notify.html). 
  * When a message is published the topic and json payload is inserted into the 'meerkat_pubsub' table, and then a NOTIFY is issued.
  * Listening clients recivies the notification and reads the message from the table and writes it to the Event Stream of its clients.
  * On the next publish all messages older than 5 seconds are deleted. 
  * No polling is ever done.
  * This works with PostgreSQL 8 and higher (tested with 8.3 and 9.1). 

Usage
-----

Put meerkat and pg or em-hiredis in your Gemfile, depending on which backend you plan to use. 
Gemfile:

```ruby
gem 'meerkat'
gem 'amqp'
# or
gem 'pg'
# or
gem 'em-hiredis'
```
Require meerkat and the backend you would like to use. 

config.ru: 

```ruby
require 'bundler/setup'
require 'meerkat' 
require 'meerkat/backend/amqp' 
#require 'meerkat/backend/pg' 
#require 'meerkat/backend/redis' 
#require 'meerkat/backend/inmemory' 
require './app'

#Meerkat.backend = Meerkat::Backend::InMemory.new 
Meerkat.backend = Meerkat::Backend::AMQP.new 'amqp://guest:guest@localhost'
#Meerkat.backend = Meerkat::Backend::Redis.new 'redis://localhost/0'
#Meerkat.backend = Meerkat::Backend::PG.new :dbname => 'postgres'
map '/' do
  run App
end
map '/stream' do
  run Meerkat::RackAdapter.new
end
```

On the client:

```javascript
var source = new EventSource('/stream/foo');
var streamList = document.getElementById('stream');
// Use #onmessage if you only listen to one topic
source.onmessage = function(e) {
  var li = document.createElement('li');
  li.innerHTML = JSON.parse(e.data);
  streamList.appendChild(li);
}

var multiSource = new EventSource('/stream/foo.*');
// You have to add custom event listerns when you 
// listen on multiple topics
multiSource.addEventListener('foo.bar', function(e) {
  // Do something
}, false);
multiSource.addEventListener('foo.foo', function(e) {
  // Do something
}, false);
```

To push things from the server:

```ruby
Meerkat.publish "foo.bar", { :any => 'hash' } # the hash will automatically be json encoded
Meerkat.publish "foo.bar", 'any string'
Meerkat.publish "foo.foo", myobj.to_json, true # the third parameter indicates that the message already is json encoded
```

The published objects will be JSON serialized before sent to the backend. You'll have to deserialize it in the client. 

From the client:

```javascript
$.post('/stream', { topic: 'foo.bar', data: JSON.stringify(my_object) })
$.post('/stream/foo.bar', { data: JSON.stringify(my_object) })
```

A simple POST request, with a parameter called 'data' (or 'json' or 'msg') containing a JSON string.

The topic can be specified other as a post parameter or in the path.

Read more about Server-Sent Events and the EventSource API on [HTML5Rocks](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

Examples
--------

A simple demo can be seen here: 
http://meerkat-demo.herokuapp.com/

It's deployed on [Heroku's Cedar stack](http://devcenter.heroku.com/articles/cedar). It's using the Redis backend, thanks to [Redis To Go](https://redistogo.com/)'s free Nano offering.

License
-------
(MIT license)

Copyright (C) 2011 by Carl Hörberg

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
