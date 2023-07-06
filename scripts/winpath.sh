#!/bin/bash

if command -v cygpath >/dev/null; then
	cygpath -w $1
elif command -v wslpath >/dev/null; then
	wslpath -w $1
else
	echo $1
fi