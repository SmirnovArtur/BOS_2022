#!/bin/bash
find -type f | xargs -d\\n md5sum | sort | uniq -w 2 -c -d | sed 's/   //g' | sed 's/ .*. //g' | sed 's/\.\// /'
