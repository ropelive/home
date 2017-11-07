module.exports = [
  path: '/'
  onEnter: (context) -> context.app.root.showPage 'home', context
,
  path: '/profile/tokens'
  onEnter: (context) -> context.app.root.showPage 'tokens', context
,
  path: '/profile'
  onEnter: (context) -> context.app.router.redirect '/profile/tokens'
]
