Meerkat
=======

Rack middleware for [Server-Sent Events (HTML5 SSE)](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

Requires an [EventMachine](https://github.com/eventmachine/eventmachine#readme) backed server, like [Thin](http://code.macournoyer.com/thin/) or [Rainbows](http://rainbows.rubyforge.org/) (with the EventMachine backend only).

Supported backends: 

 * In memory, using [EventMachine Channels](http://eventmachine.rubyforge.org/EventMachine/Channel.html), good for single server usage.
 * Redis, using [em-hiredis](https://github.com/mloughran/em-hiredis#readme) and the [Pub/Sub API](http://redis.io/topics/pubsub). 
 * Postgres, using the [Notify/Listen API](http://www.postgresql.org/docs/9.1/static/sql-notify.html). 
   * When a message is published the topic and json payload is inserted into the 'meerkat_pubsub' table, and then a NOTIFY is issued.
   * Listening clients recivies the notification and reads the message from the table and writes it to the Event Stream of its clients.
   * On the next publish all messages older than 5 seconds are deleted. 
   * No polling is ever done.
   * This works with PostgreSQL 8 and higher (tested with 8.3 and 9.1). 

Usage
-----

config.ru: 

```ruby
require 'bundler/setup'
require 'meerkat' 
require './app'

#Meerkat.backend = Meerkat::Backend::InMemory.new 
#Meerkat.backend = Meerkat::Backend::Redis.new 'redis://localhost/0'
Meerkat.backend = Meerkat::Backend::PG.new :dbname => 'postgres'
map '/' do
  run App
end
map '/stream' do
  run Meerkat::RackAdapter.new
end
```

On the client:

```javascript
var source = new EventSource('/stream/mychannel');
var streamList = document.getElementById('stream');
source.addEventListener('message', function(e) {
  var li = document.createElement('li');
  li.innerHTML = JSON.parse(e.data);
  streamList.appendChild(li);
}, false);
```

To push things:

```ruby
Meerkat.publish "/mychannel", {:any => hash}
Meerkat.publish "/mychannel/2", 'any string'
Meerkat.publish "/mychannel/3", any_object
```

The published objects will be JSON serialized (with [Yajl](https://github.com/brianmario/yajl-ruby)) before sent to the backend. Deserialize it in the client. 

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
