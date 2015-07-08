#!/usr/bin/env lsc 

_ = require('lodash')
{ parse, add-plugin } = require('newmake')

parse ->

    @add-plugin "lsc", (g) ->
        cmd1 = -> "lsc -p -c #{it.orig-complete}"
        echo = -> "echo '#!/usr/local/bin/node --harmony'"

        app = (f1, f2) ->
            -> "(#{f1(it)} && #{f2(it)})"

        final = _.reduce([cmd1], app, echo)

        f = -> "#{final(it)} > #{it.build-target}"

        @compile-files( f, ".js", g)

    @collect "all", -> 
        @command-seq -> [
            @toDir ".", -> 
                    @lsc ("./index.ls")
            @cmd "chmod +x ./index.js"
            ]

    @collect "clean", -> [
        @remove-all-targets()
        @cmd "rm -rf ./lib"
    ]

    for l in ["major", "minor", "patch"]

        @collect "release-#l", -> [
            @cmd "./node_modules/.bin/xyz --increment #l"
        ]

