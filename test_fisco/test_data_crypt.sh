#! /bin/bash

# test if data of block is encrypted

. utils.sh

BLOCK_ADDRESS=$RESULT_ADDRESS/block

function test_data_crypt() {
    
${CONSOLE} > $BLOCK_ADDRESS/block_$1.txt 2>&1 << EOF
getBlockByNumber $1 true
q
EOF

    # mv mychannel_$1.block 
    # configtxlator proto_decode --input $BLOCK_ADDRESS/mychannel_$1.block --type common.Block --output $BLOCK_ADDRESS/trace.json
    # local value=`cat $BLOCK_ADDRESS/block_$1.txt`
    local value=`cat $BLOCK_ADDRESS/block_$1.txt | sed -n "/input=/ p" | awk '{print $NF}'`
    echo $value
    # echo ${#value}
}

if [ ! -d "$BLOCK_ADDRESS" ]; then
    mkdir -p $BLOCK_ADDRESS
fi

test_data_crypt 7