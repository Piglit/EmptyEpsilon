#!/usr/bin/env python3
"""Replaces strings in file with prefixed version.
Usage: replace_plot_functions.py <file> <prefix> <variable_1> ... <variable_n>
"""

import sys
filename = sys.argv[1]
prefix = sys.argv[2]
vars = sys.argv[3:]

with open(filename, "r") as file:
	code = file.read()
	for var in vars:
		print(f"replace {var} with {prefix}.{var}")
		code = code.replace(var, prefix+"."+var)
	
with open(filename, "w") as file:
	file.write(code)
