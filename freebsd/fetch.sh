#!/bin/sh
find . -type f | grep -v $0 | sed 's/^\.\///' | xargs -I {} rsync -aPve ssh root@zero:/{} {}
