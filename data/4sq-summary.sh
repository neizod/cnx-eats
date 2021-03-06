#!/usr/bin/env bash
# -*- coding: utf-8 -*-

oldest=$(ls -1 raw-checkins/ | head -n 1)
newest=$(ls -1 -r raw-checkins/ | head -n 1)

paste raw-checkins/{$oldest,$newest} |
    awk 'BEGIN{OFS="\t"} {print "- "$1, $4-$2}' > RESTAURANTS.md
