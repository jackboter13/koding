{argv}   = require 'optimist'
{exec}   = require 'child_process'
fs       = require 'fs'
log      = console.log

build = (o)->


  buildClient = ->
    boo = require('./Builder')
    b = new boo
    b.buildSpritesAndClient {}

  buildClient "",()->
    log "client is built."


build()

