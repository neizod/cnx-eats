#!/usr/bin/env bash
# -*- coding: utf-8 -*-

api=https://api.foursquare.com/v2/venues/
tok=NORLR1UFDE2D4VRKTVCGLP3R2BVWDICJC4FXYMZTZB42OMKB
ver=20140312

while read line
do
    id=$(echo $line | awk '{print $2}')
    echo -n "$id	"
    curl -Ss -G $api$id --data "oauth_token=$tok&v=$ver" |
        python -m json.tool |
        grep checkinsCount |
        grep -o '[0-9]\+'
done < RESTAURANTS.md | tee "raw-checkins/$(date +chkins-%Y-%m-%d.log)" | nl
