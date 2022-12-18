#!/bin/bash
grep -n "$1" "$2" -m "$3" |sort 
