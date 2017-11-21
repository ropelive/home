# Allow using .env files for injecting environment variables.
require('dotenv').config()

path = require 'path'
chalk = require 'chalk'
express = require 'express'
session = require 'express-session'
MongoDBStore = require('connect-mongodb-session')(session)
logger = require 'morgan'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
passport = require 'passport'
mongoose = require 'mongoose'
{ Strategy: GithubStrategy } = require 'passport-github2'

{
  PORT_SERVER, GITHUB_CLIENT_ID
  GITHUB_CLIENT_SECRET, MONGO_ADDR
  SESSION_SECRET
} = process.env

routes = require './routes'

User = require './models/user'

########################
# app code starts here #
########################

mongoose.Promise = Promise
mongoose.connect MONGO_ADDR, { useMongoClient: yes }

# passport.js configuration

# TODO: integrate this with a db.
passport.serializeUser (user, done) -> done null, user.id
passport.deserializeUser (id, done) -> User.findOne { _id: id }, done

# register Github as a login strategy for passport.js
passport.use new GithubStrategy {
  clientID: GITHUB_CLIENT_ID
  clientSecret: GITHUB_CLIENT_SECRET
}, (accessToken, refreshToken, profile, done) ->

  payload =
    provider: 'github'
    providerId: parseInt(profile.id)
    displayName: profile.displayName
    username: profile.username
    photo: profile.photos?[0]?.value or ''

  User.findOrCreate payload, (err, user) ->
    return done err  if err
    return done new Error 'Unauthorized'  unless user

    return done null, user

# express app configuration
app = express()

app.set 'port', PORT_SERVER

# setup views

app.set 'views', path.resolve __dirname, './views'
app.set 'view engine', 'ejs'

# mongodb session configuration
sessionStore = new MongoDBStore
  uri: MONGO_ADDR
  collection: 'sessions'

sessionStore.on 'error', (error) ->
  console.log 'error on mongo session store', error

app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded { extended: no }
app.use cookieParser()
app.use session
  secret: SESSION_SECRET
  cookie:
    maxAge: 1000 * 60 * 60 * 24 * 7 # 1 week
  store: sessionStore
  resave: yes
  saveUninitialized: no

# register rope auth for server side authentication
app.use (req, res, next) ->
  req.rope_auth = false # TODO Add secret support for ROPE servers ~ GG
  do next

# register passport.js middlewares to express app.
app.use(passport.initialize())
app.use(passport.session())

# register routes
app.use '/', routes

app.use express.static path.resolve __dirname, '../dist'

app.use (req, res) ->
  res.render 'index',
    user: req.user

# error handling

# handle not found and forward to error handler
app.use (req, res, next) ->
  err = new Error 'Not found'
  err.status = 404
  next err

# error handler
app.use (err, req, res, next) ->
  res.status err.status || 500
  res.json
    message: err.message
    error: err

app.listen app.get('port'), ->
  console.log(
    '%s App is running at http://localhost:%d in %s mode'
    chalk.green('✓')
    app.get('port')
    app.get('env')
  )
