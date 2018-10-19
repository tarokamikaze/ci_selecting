#!/usr/bin/env bash
sleep 15

# Set up Index
file="/opt/couchbase/create_test_index.sql"
while IFS= read -r line
do
    curl -v http://localhost:8093/query/service -u $CB_ADMIN_USER:$CB_ADMIN_PASSWORD -d "statement=$line"
done <"$file"
