#!/usr/bin/env bash
set -x
set -m

/entrypoint.sh couchbase-server &

sleep 15

# using rest api

# Set up the index RAM quota (to be applied across the entire cluster).
curl \
    -v \
    -u $CB_ADMIN_USER:$CB_ADMIN_PASSWORD \
    http://127.0.0.1:8091/pools/default \
    -d memoryQuota=$CB_MEMORY_QUOTA \
    -d indexMemoryQuota=$CB_INDEX_MEMORY_QUOTA

# Set up services. (Note that %2C is the ASCII Hex mapping to the comma character.)
# kv:data
# n1ql:query
# index:index
curl \
    -v \
    http://127.0.0.1:8091/node/controller/setupServices \
    -d services=kv%2Cn1ql%2Cindex

# Set up your administrator-username and password.
curl \
    -v \
    http://127.0.0.1:8091/settings/web \
    -d port=8091 \
    -d username=$CB_ADMIN_USER \
    -d password=$CB_ADMIN_PASSWORD

# Initialize a node. (Note that %2F is the ASCII Hex mapping to the forward-slash-character.)
# use to change path
#curl \
#    -v \
#    -X POST http://127.0.0.1:8091/nodes/self/controller/settings \
#    -d path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata \
#    -d index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata

# Set up Memory Optimized Indexes
curl \
    -v \
    -i -u $CB_ADMIN_USER:$CB_ADMIN_PASSWORD \
    http://127.0.0.1:8091/settings/indexes \
    -d 'storageMode=forestdb'

# Set up a bucket.
curl \
    -v \
    -u $CB_ADMIN_USER:$CB_ADMIN_PASSWORD \
    -X POST http://127.0.0.1:8091/pools/default/buckets \
    -d name=db_test \
    -d ramQuotaMB=$CB_RAM_PER_NODE_TEST \
    -d authType=sasl \
    -d saslPassword=$CB_BUCKET_PASSWORD \
    -d proxyPort=0 \
    -d flushEnabled=1

fg 1 & /opt/couchbase/index.sh & fg 1
