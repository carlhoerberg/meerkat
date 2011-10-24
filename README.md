Meerkat
=======

Rack middleware for [Server-Sent Events (HTML5 SSE)](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

Requires an evented server, like [Thin](http://code.macournoyer.com/thin/).

Supported backends: 

 * In memory, using [EventMachine Channels](http://eventmachine.rubyforge.org/EventMachine/Channel.html), good for single server usage.
 * Redis, using [em-hiredis](https://github.com/mloughran/em-hiredis#readme). 
 * Postgres, using the [Notify/Listen API](http://www.postgresql.org/docs/9.1/static/sql-notify.html). Note, this is totally async, no polling.

Usage
=====

```config.ru```:

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

On the client:

    var source = new EventSource('/stream/mychannel');
    var streamList = document.getElementById('stream');
    source.addEventListener('message', function(e) {
      var li = document.createElement('li');
      li.innerHTML = JSON.parse(e.data);
      streamList.appendChild(li);
    }, false);

To push things:

    Meerkat.publish "/mychannel", {:any => hash}
    Meerkat.publish "/mychannel/2", 'any string'
    Meerkat.publish "/mychannel/3", any_object

The published object will be JSON serialized (with [Yajl](https://github.com/brianmario/yajl-ruby)) before sent to the backend. Deserialize it in the client. 

Read more about Server-Sent Events and the EventSource API on [HTML5Rocks](http://www.html5rocks.com/en/tutorials/eventsource/basics/).

License
======
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
