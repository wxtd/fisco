#! /bin/bash

# Detect encryption method

. utils.sh


NODE_KEY_ADDRESS=/home/ubuntu/ms/fisco/nodes/127.0.0.1

function test_node_crypt() {
    local item=(node0 node1 node2 node3) 
    for i in ${item[*]}
    do
        getdir $NODE_KEY_ADDRESS/$i
    done
}

function getdir(){
    for element in `ls $1`
    do  
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ]; then 
            getdir $dir_or_file
        else
            if [[ "$dir_or_file" =~ ".crt" || "$dir_or_file" =~ ".pem" ]]; then
                # println $dir_or_file
                result=`openssl x509 -text -in $dir_or_file | grep Signature\ Algorithm: | awk '{print $3}' | uniq`
                println $result
            fi
        fi  
    done
}

test_node_crypt