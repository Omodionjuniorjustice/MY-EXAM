#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <VMDK_FILE>"
  exit 1
fi

VMDK_FILE="$1"

# Replace /full/path/to/vmdktool-darwin with your actual full path to vmdktool-darwin
/full/path/to/vmdktool-darwin repair "$VMDK_FILE"
