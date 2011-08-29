# connect-riak

Connect Riak Session Store backed by [riak-js](https://github.com/frank06/riak-js).

### Installation

    npm install connect-riak

### Usage

``` js
var express = require('express'),
  RiakStore = require('connect-riak')(express); // both express and connect will work

var app = express.createServer();

app.use(express.cookieParser());
app.use(express.session({ secret: "s3cr3t", store: new RiakStore(options) }));

```

### Options

All `options` will be passed into a new Riak client – unless the `client` is explicitly defined:

``` js
var db = require('riak-js').getClient(),
  store = new RiakStore({ options.client: db });
```

Other options include:

 - `bucket`: The bucket where to store the sessions, defaults to `_sessions`.
 - `reapInterval`: How often old sessions should be wiped out. Must be a number > 0.

### MIT License

Copyright (c) 2011 Francisco Treacy, <francisco.treacy@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.