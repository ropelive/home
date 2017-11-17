path = require 'path'
{ Router } = require 'express'
passport = require 'passport'

User = require './models/user'
Token = require './models/token'

{ WEB_URL } = process.env

router = Router()

# TODO: add tests
router.get '/ping', (req, res) -> res.status(200).send('pong')

##
# AUTH ROUTES
##

router.get(
  '/auth/github'
  passport.authenticate('github', { scope: ['user:email'] })
)

router.get(
  '/auth/github/callback'
  passport.authenticate('github', { failureRedirect: '/auth/github/callback/error' })
  (req, res) -> res.redirect WEB_URL
)

# TODO: add tests
router.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/'

# TODO: add tests
router.get '/whoami', (req, res) ->
  if req.user
  then res.status(200).json req.user
  else res.status(401).json { error: yes, message: 'Unauthorized' }


##
# TOKEN ROUTES
##

# TODO: add tests
router.get '/tokens', (req, res) ->
  unless req.user
    return res.status(401).json { error: yes, message: 'Unauthorized' }

  Token.find { user: req.user._id }, (err, tokens) ->
    return res.status(500).json err  if err

    res.status(200).json tokens

# TODO: add tests
# router.post '/tokens', (req, res) ->
router.post '/tokens', (req, res) ->
  unless req.user
    return res.status(401).json { error: yes, message: 'Unauthorized' }

  { label } = req.body

  token = new Token { user: req.user._id, label }
  token.save (err, token) ->
    return res.status(500).json err  if err

    res.status(201).json token

# TODO: add tests
router.delete '/tokens/:value', (req, res) ->
  unless req.user
    return res.status(401).json { error: yes, message: 'Unauthorized' }

  Token.findOne { value: req.params.value }, (err, token) ->
    if err
      return res.status(500).json err

    if not token
      return res.status(400).json
        error: yes
        message: 'Requested resource not found'

    if not token.user.equals req.user._id
      return res.status(401).json { error: yes, message: 'Unauthorized' }

    token.remove (err) ->
      return res.status(500).json err  if err

      return res.send(200)

module.exports = router
