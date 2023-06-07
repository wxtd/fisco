#!/bin/bash

# Test node's High Availablity

. utils.sh

# docker stop node0

cmd=./test_query_or_invoke.sh

test_query_op() {
    
    # process_test_org

    $cmd $MODE 1 $@

    stop_docker homeubuntumsfisconodes127.0.0.1node${ORG_NUM}
    
    $cmd $MODE 2 $@
    # $cmd $MODE 2 $ORG2 $@

    start_docker homeubuntumsfisconodes127.0.0.1node${ORG_NUM}
}

test_invoke_op() {
    # set -x
    # process_test_org

    stop_docker homeubuntumsfisconodes127.0.0.1node${ORG_NUM}
    
    $cmd $MODE $@
    # $cmd $MODE $ORG2 $@

    stop_docker homeubuntumsfisconodes127.0.0.1node${ORG_NUM}
    # set +x
}

# get the orgs need to test
process_test_org() {
    if [ $ORG_NUM -eq 1 ]; then
        ORG1=2
        ORG2=3
    elif [ $ORG_NUM -eq 2 ]; then
        ORG1=1
        ORG2=3
    elif [ $ORG_NUM -eq 3 ]; then
        ORG1=1
        ORG2=2
    else 
        errorln "ORG Unknown"
    fi
}

printHelp() {
    println "HELP"
    println "   Please input params like this :"
    println "       ./test_node_high_available.sh query 0 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit"
    println "   or ./test_node_high_available.sh invoke 0 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 insert fruit 1 apple"
}



if [[ $# -lt 4 ]] ; then
    errorln "Params insufficient!"
    printHelp
    exit 0
else
    MODE=$1
    shift
fi

ORG_NUM=$1
shift

if [ "$MODE" == "query" ]; then
    test_query_op $@
elif [ "$MODE" == "invoke" ]; then
    test_invoke_op $@
else
    errorln "Mode illegal!"
    printHelp
    exit 0
fi