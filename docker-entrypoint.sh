#!/bin/bash

if [[ -z "$NODE_ID" ]]; then
    echo "ERROR: missing mandatory config: NODE_ID"
    exit 1
fi

if [[ -z "$HTTP_SERVER_HTTP_PORT" ]]; then
    export HTTP_SERVER_HTTP_PORT=8080
fi

if [[ -z "$QUERY_MAX_MEMORY" ]]; then
    export QUERY_MAX_MEMORY=5GB
fi

if [[ -z "$QUERY_MAX_MEMORY_PER_NODE" ]]; then
    export QUERY_MAX_MEMORY_PER_NODE=1GB
fi

if [[ -z "$QUERY_MAX_TOTAL_MEMORY_PER_NODE" ]]; then
    export QUERY_MAX_TOTAL_MEMORY_PER_NODE=2GB
fi

if [[ -z "$DISCOVERY_URI" ]]; then
    export DISCOVERY_URI=http://localhost:8080
fi

if [[ -z "$NODE_INTERNAL_ADDRESS" ]]; then
    if [ ! -f /opt/presto/etc/node.properties ]; then
        echo "node.environment=presto
node.id=$NODE_ID
node.data-dir=/var/presto/data
" > /opt/presto/etc/node.properties
    else
        sed -ri 's/^(node.id=).*/\1'"$NODE_ID"'/' "/opt/presto/etc/node.properties"
    fi
else
    if [ ! -f /opt/presto/etc/node.properties ]; then
        echo "node.environment=presto
node.id=$NODE_ID
node.data-dir=/var/presto/data
node.internal-address=$NODE_INTERNAL_ADDRESS
" > /opt/presto/etc/node.properties
    else
        sed -ri 's/^(node.id=).*/\1'"$NODE_ID"'/' "/opt/presto/etc/node.properties"
        sed -ri 's/^(node.internal-address=).*/\1'"$NODE_INTERNAL_ADDRESS"'/' "/opt/presto/etc/node.properties"
    fi
fi

if [ ! -f /opt/presto/etc/jvm.config ]; then
    echo "-server
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
" > /opt/presto/etc/jvm.config
fi

if [ "$1" = "help" ]; then
    echo "Usage: $(basename "$0") (coordinator|worker|local|help)"
elif [ "$1" = "coordinator" ]; then
    if [ ! -f /opt/presto/etc/config.properties ]; then
        echo "coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=$HTTP_SERVER_HTTP_PORT
query.max-memory=$QUERY_MAX_MEMORY
query.max-memory-per-node=$QUERY_MAX_MEMORY_PER_NODE
query.max-total-memory-per-node=$QUERY_MAX_TOTAL_MEMORY_PER_NODE
discovery-server.enabled=true
discovery.uri=$DISCOVERY_URI
" > /opt/presto/etc/config.properties
    else
        sed -ri 's/^(http-server.http.port=).*/\1'"$HTTP_SERVER_HTTP_PORT"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory=).*/\1'"$QUERY_MAX_MEMORY"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory-per-node=).*/\1'"$QUERY_MAX_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-total-memory-per-node=).*/\1'"$QUERY_MAX_TOTAL_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(discovery.uri=).*/\1'"$DISCOVERY_URI"'/' "/opt/presto/etc/config.properties"
    fi

    exec /opt/presto/bin/launcher run
elif [ "$1" = "worker" ]; then
    if [ ! -f /opt/presto/etc/config.properties ]; then
        echo "coordinator=false
http-server.http.port=$HTTP_SERVER_HTTP_PORT
query.max-memory=$QUERY_MAX_MEMORY
query.max-memory-per-node=$QUERY_MAX_MEMORY_PER_NODE
query.max-total-memory-per-node=$QUERY_MAX_TOTAL_MEMORY_PER_NODE
discovery.uri=$DISCOVERY_URI
" > /opt/presto/etc/config.properties
    else
        sed -ri 's/^(http-server.http.port=).*/\1'"$HTTP_SERVER_HTTP_PORT"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory=).*/\1'"$QUERY_MAX_MEMORY"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory-per-node=).*/\1'"$QUERY_MAX_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-total-memory-per-node=).*/\1'"$QUERY_MAX_TOTAL_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(discovery.uri=).*/\1'"$DISCOVERY_URI"'/' "/opt/presto/etc/config.properties"
    fi

    exec /opt/presto/bin/launcher run
elif [ "$1" = "local" ]; then
    if [ ! -f /opt/presto/etc/config.properties ]; then
        echo "coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=$HTTP_SERVER_HTTP_PORT
query.max-memory=$QUERY_MAX_MEMORY
query.max-memory-per-node=$QUERY_MAX_MEMORY_PER_NODE
query.max-total-memory-per-node=$QUERY_MAX_TOTAL_MEMORY_PER_NODE
discovery-server.enabled=true
discovery.uri=$DISCOVERY_URI
" > /opt/presto/etc/config.properties
    else
        sed -ri 's/^(http-server.http.port=).*/\1'"$HTTP_SERVER_HTTP_PORT"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory=).*/\1'"$QUERY_MAX_MEMORY"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-memory-per-node=).*/\1'"$QUERY_MAX_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(query.max-total-memory-per-node=).*/\1'"$QUERY_MAX_TOTAL_MEMORY_PER_NODE"'/' "/opt/presto/etc/config.properties"
        sed -ri 's/^(discovery.uri=).*/\1'"$DISCOVERY_URI"'/' "/opt/presto/etc/config.properties"
    fi

    exec /opt/presto/bin/launcher run
fi
