#!/usr/bin/env lsc
# options are accessed as argv.option

_      = require('underscore')
_.str  = require('underscore.string');
moment = require 'moment'
fs     = require 'fs'
color  = require('ansi-color').set
os      = require('os')
shelljs = require('shelljs')
table = require('ansi-color-table')
chalk = require('chalk')

$b = require('bluebird')

_.mixin(_.str.exports());
_.str.include('Underscore.string', 'string');

url-encode = require('urlencode');
parser = require('xml2json');
ieee = require('./lib/ieee')


name        = "ie"
description = "Search for ieee explore"
author      = "Vittorio Zaccaria"
year        = "2014"

info = (s) ->
  console.log color('inf', 'bold')+": #s"

err = (s) ->
  console.log color('err', 'red')+": #s"

warn = (s) ->
  console.log color('wrn', 'yellow')+": #s"

src = __dirname
otm = if (os.tmpdir?) then os.tmpdir() else "/var/tmp"
cwd = process.cwd()

setup-temporary-directory = ->
    name = "tmp_#{moment().format('HHmmss')}_tmp"
    dire = "#{otm}/#{name}" 
    shelljs.mkdir '-p', dire
    return dire

remove-temporary-directory = (dir) ->
    shelljs.rm '-rf', dir 
    
usage-string = """

#{color(name, \bold)}. #{description}
(c) #author, #year

Usage: #{name} [--option=V | -o V] 
"""

require! 'optimist'

argv     = optimist.usage(usage-string,
              from:
                alias: 'f', description: 'starting year', default: 2010

              keywords:
                alias: 'k', description: 'comma separated keyword list', default: "gpu" 

              focus:
                alias: 'u', description: 'focus on a specific journal'

              title: 
                alias: 't', description: 'search only in title', boolean:true, default: false 

              number:
                alias: 'n', description: 'how many', default: 10 

              abstract:
                alias: 'a', description: 'show abstract', default: false, boolean:true

              help:
                alias: 'h', description: 'this help', default: false, boolean:true

              transaction:
                alias: 'r', description: 'search only in transactions', default: false, boolean:true

              brief:
                alias: 'i', description: 'search in brief transactions', default: false, boolean:true

              signal:
                alias: 's', description: 'look in signal processing journals', default: false, boolean:true

              computer:
                alias: 'c', description: 'look in transactions on computers', default: false, boolean:true

              batch: 
                alias: 'b', description: 'get nth batch of results', default: 0

              markdown:
                alias: 'm', description: 'produce markdown output', default: false, boolean:true

                         ).boolean(\h).argv




if(argv.help)
  optimist.showHelp()
  process.exit(0) 


argv.title ?= false


ieee.addKeywords(_.words(argv.keywords, ','), argv.title) 
ieee.searchPubs("transaction") if argv.transaction
ieee.searchPubs("brief") if argv.brief
ieee.searchPubs("signal processing") if argv.signal
ieee.searchPubs("transaction computers") if argv.computer
ieee.searchPubs(argv.focus) if argv.focus?

display = ->
  if not argv.markdown
    console.log "#{@py} #{chalk.green(@pubtitle)}"
    console.log "     " + chalk.grey(@authors)
    console.log "     " + chalk.blue(@title)
    console.log wrap(_(@abstract).truncate(300), {width: 60}) if argv.abstract
    console.log @pdf
    console.log "" 
  else 
    console.log ""
    console.log "\# #{@title}"
    console.log "*#{@py} — #{@pubtitle}*"
    console.log ""
    console.log @authors
    console.log ""
    console.log "#{@abstract}"
    console.log "([pdf](#{@pdf}))"

ieee.sendRequest(argv.number, argv.batch).then ->
  for d in it
      display.apply(d)


