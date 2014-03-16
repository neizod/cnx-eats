#!/usr/bin/env bash
# -*- coding: utf-8 -*-

pg_dump -U gman gis \
        -t obstacles \
        -t restaurants \
        -t universities \
        -t rest_density \
        -t univ_density \
        -t land_rates \
    > gis-data-dump.sql
