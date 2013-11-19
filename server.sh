#!/bin/sh

# compile celestrium's coffeescript
./node_modules/.bin/coffee --compile --watch -o www/js/ celestrium/core-coffee/ &

# compile this repo's coffeescript
./node_modules/.bin/coffee --compile --watch -o www/js/ coffee-script/ &

# run server
python server/server.py www/ $PORT
