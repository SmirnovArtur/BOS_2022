#!/bin/bash
cat ~/bash.txt | grep -w "000000" > /tmp/zeros
cat ~/bash.txt | grep -v "000000" > /tmp/nozeros

cat /tmp/zeros | head -n 10
cat /tmp/zeros | tail -n 10

cat /tmp/nozeros | head -n 10
cat /tmp/nozeros | tail -n 10
