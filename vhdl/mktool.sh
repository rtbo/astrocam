#!/bin/sh

LDC=$(which ldc32 2> /dev/null)
DMD=$(which dmd 2> /dev/null)

if [ -x "$LDC" ]; then
    echo Compiling tool with LDC
    $LDC tool.d -O --release
elif [ -x "$DMD" ]; then
    echo Compiling tool with DMD
    $DMD tool.d -O -release
else
    echo No D compiler detected. You need to install either LDC or DMD to build the tool.
    exit 1
fi

echo done
rm tool.o
