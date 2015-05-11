@echo off
haxelib run flow build windows
for /f "tokens=2 delims='" %%a in ('findstr version project.flow') do set ver=%%a
cd bin/
ren windows IsometricEdit-%ver%
"c:\Program Files\7-Zip\7z.exe" a IsometricEdit-%ver%-win.zip IsometricEdit*\
cd ..
del builds\*-win.zip
move bin\IsometricEdit-%ver%-win.zip builds\
rmdir /S /Q bin\IsometricEdit-%ver%