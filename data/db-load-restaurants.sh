#!/usr/bin/env bash
# -*- coding: utf-8 -*-

psql -U gman gis << END
    UPDATE restaurants AS res
    SET    chkins = fsq.chkins
    FROM   (
        VALUES
        $(awk '{print "(\x27"$2"\x27,"$3")"}' RESTAURANTS.md | paste -sd ',')
    ) AS   fsq(id, chkins)
    WHERE  res.fsq_id = fsq.id;
END
