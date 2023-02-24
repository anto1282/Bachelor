#General argparse form:

#!/usr/bin/env python3

from argparse import ArgumentParser
from ast import Store
import sys

# Help message
parser = ArgumentParser(description="This script does stuff")

# String arg (example: file paths)
parser.add_argument("-i", action="store", dest="input_file", type = str, help="Input file")
# Float with default value
parser.add_argument("-p", action="store", dest="param", type=float, default=50.0, help="Some numerical parameter (default: 50.0)")
# Conditional argument (can be used in IF statement when triggered)
parser.add_argument("-s", action="store_true", dest="switch", help="Run code function conditionally")

# Parse arguments
args = parser.parse_args()

# Display help() if no arguments provided
if len(sys.argv) < 2:
    parser.print_help()
    sys.exit(1)
    
### OPTIONS
# Give args.dest item alias (still accessible with args.<dest_name>)
# String arg 
input_file = args.input_file
# Float default value
param = args.param
# Conditional arg
switch = args.switch

# IF STATEMENT IMPLEMENTATION
if args.switch:
    <body to execute, given -s switch>