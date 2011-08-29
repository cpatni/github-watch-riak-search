util = require('util')
url = require('url')
exec = require('child_process').exec
http = require 'http'
https = require 'https'
express = require 'express'
RiakStore = require('connect-riak')(express)
riak = require('riak-js').getClient()

app = module.exports = express.createServer()

app.configure () ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.session({ secret: "trustno1", store: new RiakStore({bucket: "_gws_sessions", client: riak})}))
  app.use(express.methodOverride())
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));

app.configure 'development', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', () ->
  app.use(express.errorHandler());

app.get '/refresh/:login', (req, res) ->
  login = req.params.login
  refreshWatchedReposIndex(login)
  res.redirect('back')

app.get '/search/', (req, res) ->
  login = req.params.login || req.query.login
  if login
    riak.get 'watched_repos', login, (err, watch_index, meta) ->
      if watch_index?.statusCode is 404
        refreshWatchedReposIndex(login)
      res.redirect("/search/#{login}")
  else
    res.redirect("/")

app.get '/search/:login', (req, res) ->
  login = req.params.login
  query = req.query.query
  if query
    riak.get 'watched_repos', login, (err, watch_index, meta) ->
      if watch_index?.last_refresh_attempt_at
        riak.search "watched_repos_#{login}", query, {rows: 200}, (err, data, meta) ->
          res.render 'search',
            query: query
            login: login
            title: "Search results for #{query}"
            last_refresh_at: watch_index.last_refresh_attempt_at
            docs: data?.docs || []
      else if watch_index?.statusCode is 404
        res.render 'search',
          query: ''
          login: login
          title: 'Search Watched Repos'
          last_refresh_at: ''
          docs: []
        refreshWatchedReposIndex(login)
  else
    res.render 'search',
      query: ''
      login: login
      title: 'Search Watched Repos'
      last_refresh_at: ''
      docs: []
    ensureIndex(login)

app.get '/', (req, res) ->
  res.render 'index',
    title: 'Search Watched Repos'

app.listen(4000)
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
# console.log("server started at port 4000")

ensureIndex=(login) ->
  riak.get 'watched_repos', login, (err, watch_index, meta) ->
    if watch_index?.statusCode is 200
      console.log("Index for #{login} already exists", watch_index)
    else if watch_index?.statusCode is 404
      console.log("Import index for #{login}")
      refreshWatchedReposIndex(login)

refreshWatchedReposIndex=(login) ->
  search_cmd = "/usr/local/Cellar/riak/HEAD/libexec/bin/search-cmd"
  cmd = "#{search_cmd} set-schema watched_repos_#{login} config/repo_schema.erl && #{search_cmd} install watched_repos_#{login}"
  console.log cmd
  child = exec cmd, (error, stdout, stderr) ->
    console.log('stdout: ' + stdout)
    console.log('stderr: ' + stderr)
    if error isnt null
      console.log('exec error: ' + error)
    else
      riak.save 'watched_repos', login, {login: login, last_refresh_attempt_at: new Date()}
      indexWatchedRepositories(login)

indexWatchedRepositories=(login, page=1, per_page=100) ->
  # url = "https://api.github.com/users/#{login}/watched"
  options =
    host: 'api.github.com'
    port: 443
    path: "/users/#{login}/watched?page=#{page}&per_page=#{per_page}"
  https.get options, (egres) ->
    console.log "/users/#{login}/watched?page=#{page}&per_page=#{per_page}  --> #{egres.statusCode}"
    buffer = ""
    egres.on 'data', (chunk) ->
      buffer += chunk
    egres.on 'end', ->
      indexWatchedRepositoriesJson login, JSON.parse(buffer), () ->
        link_header = egres.headers['link']
        if link_header
          next_page_match = link_header.match(/<([^>]+)>; rel="next"/)
          if next_page_match
            next_page = parseInt(url.parse(next_page_match[1], true).query.page, 10)
            indexWatchedRepositories(login, next_page, per_page)

  .on 'error', (e) ->
    console.log "Could not index watched repositories for #{login}. Message: #{e.message}"

indexWatchedRepositoriesJson=(login, watchedRepos, callback) ->
  bucket = "watches_#{login}"
  for repo in watchedRepos
    do(repo) ->
      riak.save("watched_repos_#{login}", repo.id, repo)
  # console.log(json)
  callback()

