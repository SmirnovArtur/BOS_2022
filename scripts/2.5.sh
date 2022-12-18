#!/bin/bash
find ~ -maxdepth 1 -name "*.txt" -type f
echo "Byte sum:"
find ~ -maxdepth 1 -name "*.txt" -type f | du -csh
echo "Line sum"
find ~ -maxdepth 1 -name "*.txt" -type f -exec cat {} \; > /tmp/linelen
wc -l /tmp/linelen
rm /tmp/linelen
