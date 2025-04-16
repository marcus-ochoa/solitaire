#!/bin/bash

# Get the full path of the Lua file being run
FILE="$1"

DEBUG="$2"

# Get the directory of the Lua file
DIR=$(dirname "$FILE")

# Traverse up the directory structure to find the directory containing main.lua
while [[ ! -f "$DIR/main.lua" && "$DIR" != "/" ]]; do
  DIR=$(dirname "$DIR")
done

# Check if we found main.lua
if [ -f "$DIR/main.lua" ]; then
  
  if [ "$DEBUG" == "debug" ]; then
    echo "Running Love2D in debug mode from: $DIR"
    love "$DIR" debug

  else
    echo "Running Love2D from: $DIR"
    love "$DIR"
  fi

else
  echo "Error: main.lua not found in $DIR or any parent directory"
  exit 1
fi
