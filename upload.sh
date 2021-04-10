#!/bin/bash

set -e

if [ -d Export/html5/dist ]; then
    pushd Export/html5/dist/
    rm -rf *
    popd
fi

openfl build html5
openfl deploy html5

cd Export/html5/dist

unzip *.zip

scp -r * isograph:/var/www/dogsplusplus/nfal

echo "done :)"
