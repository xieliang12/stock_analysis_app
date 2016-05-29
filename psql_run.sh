#!/bin/bash
psql -X -q -a -1 -v v1="'$1'" -v v2="'$2'" -v v3="'$3'" --pset pager=off -f create_insert_database.sql
