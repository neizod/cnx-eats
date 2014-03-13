#!/usr/bin/env bash
# -*- coding: utf-8 -*-

oldest=$(ls -1 raw-data/ | head -n 1)
newest=$(ls -1 -r raw-data/ | head -n 1)

paste raw-data/{$oldest,$newest} |
    awk 'BEGIN{OFS="\t"} {print "- "$1, $4-$2}' > RESTAURANTS.md
