#!/bin/bash
rm -f luacov.stats.out
lua -e "TEST=true" -lluacov $1
luacov $1
