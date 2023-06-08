#! /bin/bash

# test fisco node consensus algorithm

# Example: 

. utils.sh

example_query_cmd=./example_query.sh
example_invoke_cmd=./example_invoke.sh
test_node_data_consistency_cmd=./test_node_data_consistency.sh

function test_raft() {
    # set -x

    local test_node=homeubuntumsfisconodes127.0.0.1node0
    $example_query_cmd 1

    stop_docker $test_node
    # stop_docker node0

    $example_query_cmd 2
    $example_invoke_cmd

    start_docker $test_node

    println "sleep 10~"
    sleep 10
    $test_node_data_consistency_cmd

    # set +x
}

if [ ! -d "$NODE_RESULT_ADDRESS" ]; then
    mkdir -p $NODE_RESULT_ADDRESS
fi

test_raft