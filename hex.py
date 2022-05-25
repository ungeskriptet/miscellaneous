#!/usr/bin/env python
import sys

argument = sys.argv[1]

if argument.startswith("0x"):
    print(int(argument, 16))
else:
    print(hex(int(argument)))
