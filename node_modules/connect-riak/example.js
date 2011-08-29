var express = require('express'),
  RiakStore = require('./index')(express);
  
var app = express.createServer();

app.use(express.cookieParser());
app.use(express.session({ secret: "s3cr3t", store: new RiakStore({ reapInterval: 2 * 1000 }) }));

// visit /1 to set a value on the session
app.get('/1', function(req, res) {
  req.session.test = { a: 2 };
  res.send('test value set in session');
});

// restart the server and visit /2
app.get('/2', function(req, res) {
  res.send({ sessionTest: req.session.test });
});

app.listen(3000);