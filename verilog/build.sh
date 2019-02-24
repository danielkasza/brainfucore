#!/bin/bash

set -e
#set -x

# Build program.
iverilog -D__SIMULATION__ -g2012 brainfucore.v -o brainfucore.bin

# Make "CTRL-C" exit the program.
sed -i "s:#! /usr/bin/vvp:#! /usr/bin/vvp -n:" brainfucore.bin

echo "-- DONE --"