#!/bin/bash
FNAME=$1

./$FNAME "1" "2" "3"
./$FNAME "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM" "$RANDOM"
./$FNAME "foo" "bar" "foobar" "foo bar"
./$FNAME "foo" "--foo" "--help" "-l"
