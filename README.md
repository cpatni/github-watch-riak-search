# Github watch search using riak search

[github-watch-riak-search](http://github.com/rubyorchard/github-watch-riak-search) is an express app written in coffeescript using riak search to search your watched repositories on github.

#### Features:

 * Multi User support

#### Dependencies
 * Riak
 * Express, coffeescript

#### Installation
 * Install Erlang, Riak

```bash
brew install erlang riak
```

 * Enable riak search

```erlang
%% Riak Search Config
{riak_search, [
               %% To enable Search functionality set this 'true'.
               {enabled, true}
              ]},
```


```bash
#start riak
riak start
#Make sure that the `search-cmd` executable path used by app.coffee matches with your installation
#start app
./node_modules/coffee-script/bin/coffee app.coffee
```

### Other Stuff
--------

 * Author::  Chandra Patni
 * License:: Original code Copyright 2011 by Chandra Patni.

             Released under an MIT-style license.  See the LICENSE  file
             included in the distribution.

#### Warranty
--------

This software is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantibility and fitness for a particular
purpose.
