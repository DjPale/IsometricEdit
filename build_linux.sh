#!/bin/sh
haxelib run flow build linux
ver=`grep version project.flow | cut -d"'" -f2`
cd bin
mv linux64 IsometricEdit-${ver}
tar -cvzf IsometricEdit-${ver}-linux.tar.gz IsometricEdit-*
cd ..
rm builds/*-linux.tar.gz
mv bin/IsometricEdit-*.tar.gz builds/
rm -rf bin/IsometricEdit-*
