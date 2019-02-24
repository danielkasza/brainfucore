#!/usr/bin/env python
import sys
import re
########################################################################################################################
## Pass 1 ##############################################################################################################
########################################################################################################################
# Read the source and throw away comments. We'll leave the rest of the source in an array.
#
# Read input file into array:
source = None
with open(sys.argv[1], 'r') as myfile:
    source=myfile.read().replace('\n', '')
# Replace non-command characters with nothing:
source = re.sub("[^+-<>.,\[\]]", "", source)
########################################################################################################################
## Pass 2 ##############################################################################################################
########################################################################################################################
# Convert commands to our internal representation. This includes combining +-<> commands.
#
# This list will hold the instructions:
instructions = []
# Iterate over characters in source, and update the list:
for c in source:
# If the command is +-<>, try to combine it with last instruction:
    if re.match("[+-<>]", c):
        if instructions and (instructions[-1][0] is c) and (instructions[-1][1] < 255):
            instructions[-1] = (c, instructions[-1][1]+1)
        else:
            instructions.append((c, 1))
    else:
# These instructions cannot be combined:
        instructions.append((c, 0))
if len(instructions) > 8192:
    raise Exception("The program is too large!")
########################################################################################################################
## Pass 3 ##############################################################################################################
########################################################################################################################
# At this point, the instruction addresses will not change, but we don't have the right jump addresses yet.
# We need to calculate those now. We'll use a stack of addresses for this. When [ is encountered, we'll push the address
# when ] we'll pop the address and fix up both instructions. If the stack is empty when ] is found, there is no matching
# [ and we'll fail.
#
# This list is the stack:
return_stack = []
for i, c in enumerate(instructions):
    if c[0] is '[':
        return_stack.append(i)
    elif c[0] is ']':
        i_match = return_stack.pop()
        instructions[i] = (']', i_match)
        instructions[i_match] = ('[', i)
########################################################################################################################
## Write bytecode ######################################################################################################
########################################################################################################################
# The bytecode is now final. We just have to write it to stdout.
#
# Iterate over each instruction and write hex equivalent to stdout:
for c in instructions:
    opcode = None
    if c[0] is '+':
        opcode = 0
    elif c[0] is '-':
        opcode = 1
    elif c[0] is '>':
        opcode = 2
    elif c[0] is '<':
        opcode = 3
    elif c[0] is '.':
        opcode = 4
    elif c[0] is ',':
        opcode = 5
    elif c[0] is '[':
        opcode = 6
    elif c[0] is ']':
        opcode = 7
    instruction = (opcode << 13 | c[1]) & 0xFFFF
    print('%04X' % instruction)