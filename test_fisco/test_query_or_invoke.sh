#!/bin/bash

# Test Fisco-bcos Query & Invoke Command

. utils.sh

# Firstly query and then save this result as log1.txt
saveQueryResult() {
    infoln "Querying~"
    # println $#
    
    # processParam $@

    # println $ARGS

    # local org_address=${TESTDATA_ADDRESS}/sdk_config${ORG_NUM}.yml

    # set -x

${CONSOLE} > $QUERY_OR_INVOKE_RESULT_ADDRESS/query_result1.txt 2>&1 << EOF
call $CHAINCODE_NAME $CHAINCODE_ADDRESS $FUNCTION_NAME $@
q
EOF

    # set +x
}


# compare query result with the query result firstly
CompareQueryResult() {
    # println "CompareQueryResult"
    infoln "Querying~"
    # processParam $@

${CONSOLE} > $QUERY_OR_INVOKE_RESULT_ADDRESS/query_result2.txt 2>&1 << EOF
call $CHAINCODE_NAME $CHAINCODE_ADDRESS $FUNCTION_NAME $@
q
EOF

    local result1=`cat $QUERY_OR_INVOKE_RESULT_ADDRESS/query_result1.txt | sed -n "/Return values:/ p"`
    # echo $result1
    local result2=`cat $QUERY_OR_INVOKE_RESULT_ADDRESS/query_result2.txt | sed -n "/Return values:/ p"`
    # echo $result2
    if [ "$result1" == "$result2" ]; then
        println "Query result is the same!"
    else
        println "Query result is different"
    fi
}

# Invoke cmd result
# Chaincode invoke successful. result: status:200
ivokeChaincode() {
    infoln "Invoking~"
    # processParam $@

    # ADDRESS=$(dirname "$PWD")
    local invoke_result=$QUERY_OR_INVOKE_RESULT_ADDRESS/invoke_result.txt
    
    # set -x
${CONSOLE} > $invoke_result 2>&1 << EOF
call $CHAINCODE_NAME $CHAINCODE_ADDRESS $FUNCTION_NAME $@
q
EOF
    # set +x

    # success="Return message: Success"
    local t1=`cat $invoke_result | sed -n "/Return message: Success/ p"`
    local t2=`cat $invoke_result | sed -n "/transaction status: 0x0/ p"`
    # echo $t1 $t2
    if [[ "$t1" || "$t2" ]];then
        println "Invoke Success!"
    else
        println "Invoke Failed"
    fi
}

# Process Parameters
# processParam() {
#     if [ $# -eq 0 ]; then
#         ARGS=$ARGS"\"\""
#     else
#         ARGS=$ARGS"\"$1\""
#         shift
#         ARGS=$ARGS":""\"$1\""
#         shift
#     fi
#     while [[ $# -gt 0 ]]
#     do
#         # println $#
#         ARGS=$ARGS",""\"$1\""
#         shift
#         ARGS=$ARGS":""\"$1\""
#         shift
#     done
# }

# Print Help
printHelp() {
    println "Help:"
    println "   ./test_query_or_invoke.sh [TEST_MOD] [OPTION:TURN] [ORG_NUM] [CHAINCODE_NAME] [FUNCTION_NAME] [ARGS]"
    println "   Params:"
    println "       TEST_MOD: query / invoke"
    println "       TURN: 1 / 2"
    println "       ORG_NUM: 1 / 2 / 3 / 4"
    println "   Please input params like this :"
    println "       ./test_query_or_invoke.sh query 1 TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit"
    println "    or ./test_query_or_invoke.sh invoke TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 insert fruit 1 apple"
}

#call TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select "fruit"

if [ ! -d "$QUERY_OR_INVOKE_RESULT_ADDRESS" ]; then
    mkdir -p $QUERY_OR_INVOKE_RESULT_ADDRESS
fi

# if [ ! -f "$QUERY_OR_INVOKE_RESULT_ADDRESS/success_invoke.txt" ]; then
#     println "file not exists!"
#     echo "Chaincode invoke successful. result: status:200" > result/success_invoke.txt
# fi

## Parse mode
if [[ $# -lt 4 ]] ; then
    errorln "Params insufficient!"
    printHelp
    exit 0
else
    MODE=$1
    shift
fi

if [ "$MODE" == "query" ]; then
    TURN=$1
    shift
    CHAINCODE_NAME=$1
    CHAINCODE_ADDRESS=$2
    FUNCTION_NAME=$3
    shift 3
    # setGlobals $ORG_NUM
    if [ $TURN -eq 1 ]; then
        saveQueryResult $@
    else 
        CompareQueryResult $@
    fi
elif [ "$MODE" == "invoke" ]; then
    CHAINCODE_NAME=$1
    CHAINCODE_ADDRESS=$2
    FUNCTION_NAME=$3
    shift 3
    # setGlobals $ORG_NUM
    ivokeChaincode $@
else
    errorln "Mode illegal!"
    printHelp
    exit 0
fi
