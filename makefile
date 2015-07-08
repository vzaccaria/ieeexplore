.DEFAULT_GOAL := all

.build/0-index.js: ./index.ls
	(echo '#!/usr/local/bin/node --harmony' && lsc -p -c index.ls) > .build/0-index.js

index.js: .build/0-index.js
	@mkdir -p ./.
	cp .build/0-index.js $@

.PHONY : cmd-1
cmd-1: 
	chmod +x ./index.js

.PHONY : cmd-seq-2
cmd-seq-2: 
	make index.js
	make cmd-1

.PHONY : all
all: cmd-seq-2

.PHONY : clean-3
clean-3: 
	rm -rf .build/0-index.js index.js

.PHONY : clean-4
clean-4: 
	rm -rf .build

.PHONY : clean-5
clean-5: 
	mkdir -p .build

.PHONY : cmd-6
cmd-6: 
	rm -rf ./lib

.PHONY : clean
clean: clean-3 clean-4 clean-5 cmd-6

.PHONY : cmd-7
cmd-7: 
	./node_modules/.bin/xyz --increment major

.PHONY : release-major
release-major: cmd-7

.PHONY : cmd-8
cmd-8: 
	./node_modules/.bin/xyz --increment minor

.PHONY : release-minor
release-minor: cmd-8

.PHONY : cmd-9
cmd-9: 
	./node_modules/.bin/xyz --increment patch

.PHONY : release-patch
release-patch: cmd-9
