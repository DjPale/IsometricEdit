#!/bin/sh
haxelib run flow build mac
ver=`grep version project.flow | cut -d"'" -f2`
cd bin
mv mac64 IsometricEdit-${ver}
tar -cvzf IsometricEdit-${ver}-mac.tar.gz IsometricEdit-*
cd ..
rm builds/*-mac.tar.gz
mv bin/IsometricEdit-*.tar.gz builds/
rm -rf bin/IsometricEdit-*
