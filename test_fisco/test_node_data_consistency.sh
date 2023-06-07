#! /bin/bash

# test fabric node data consistency

. utils.sh

NODE_RESULT_ADDRESS=$RESULT_ADDRESS/node
NODE_ADDRESS=/home/ubuntu/ms/fisco/nodes/127.0.0.1
node_list=(node0 node1 node2 node3)
# log_list=(log1 log2 log3 log4)
# log_list=(log1)

function test_node_data_consistency() {
    get_log

    local j=0
    # Commit block: 13 to backend storage finished, current cached block: 13

    for i in ${node_list[*]}
    do 
        cat $NODE_RESULT_ADDRESS/node_test_$i.txt | grep block \
            | sed -n '/Commit\sblock:\s[0-9]\+/ p' \
            > $NODE_RESULT_ADDRESS/temp${j}.txt
            # | awk '{for(i=9; i<=14; i++) {print $i}}' ORS="\n"
        # cat $NODE_RESULT_ADDRESS/temp${j}.txt
        let j++
    done
    # cat $NODE_RESULT_ADDRESS/node_test_node1.example.com.txt | grep block \
    #     | sed -n '/Writing\sblock\s\[[0-9]\+\]\s(Raft\sindex:\s[0-9]\+)/ p' \
    #     | awk '{print $9,$10,$11,$12,$13,$14}' ORS="\n" > b_tmp.txt
    local cnt=${#node_list[@]}
    comm -12 $NODE_RESULT_ADDRESS/temp0.txt $NODE_RESULT_ADDRESS/temp1.txt > $NODE_RESULT_ADDRESS/common.txt

    # cat $NODE_RESULT_ADDRESS/temp0.txt
    # cat $NODE_RESULT_ADDRESS/common.txt
    local idx=2
    while [[ idx -lt $cnt ]]
    do
        # echo $idx
        comm -12 $NODE_RESULT_ADDRESS/common.txt $NODE_RESULT_ADDRESS/temp$idx.txt > $NODE_RESULT_ADDRESS/temp.txt
        cat $NODE_RESULT_ADDRESS/temp.txt > $NODE_RESULT_ADDRESS/common.txt
        # cp $NODE_RESULT_ADDRESS/temp.txt $NODE_RESULT_ADDRESS/common.txt
        # sleep 3
        # rm $NODE_RESULT_ADDRESS/common.txt
        # mv $NODE_RESULT_ADDRESS/temp.txt $NODE_RESULT_ADDRESS/common.txt
        # cat $NODE_RESULT_ADDRESS/temp.txt
        let idx++
    done
    # cat $NODE_RESULT_ADDRESS/temp.txt
    if [[ -s $NODE_RESULT_ADDRESS/common.txt ]]; then
        cat $NODE_RESULT_ADDRESS/common.txt
    else 
        println "No!"
    fi
    rm $NODE_RESULT_ADDRESS/common.txt
    rm $NODE_RESULT_ADDRESS/temp*.txt
}

# for range get log
function get_log() {
    for i in ${node_list[*]}
    do
        # docker logs -f $i --tail 10 > result/node_test_$i.txt 2>&1 &
        # sleep 1 && kill -SIGINT $?
        sleep 1
        get_last_log_from_node $i
    done
    # kill processes about docker logs
    # echo ${#node_list[@]}
    # sleep 3 && kill -9 `ps -ef | grep docker\ logs | awk '{print $2}' | head -${#node_list[@]}`
}

# get log from node
function get_last_log_from_node() {
    local node_name=$1
    > $NODE_RESULT_ADDRESS/node_test_$node_name.txt
    # get ${node_name}'s last ${row} log 
    local row=1000
    local nowtime=$(TZ=UTC-8 date +%Y\ %m\ %d\ %H\ %M\ %S)
    # 2023 06 07 08 02 39
    # echo $nowtime
    local t=`echo $nowtime | awk '{print $1$2$3$4}'`
    # echo $t
    local i=0
    while [ $i -lt 60 ]
    do
        # echo "$NODE_ADDRESS/$node_name/log/log_$t.0$i.log"
        if [[ $i -lt 10 && -f $NODE_ADDRESS/$node_name/log/log_$t.0$i.log ]]; then
            tail -n $row $NODE_ADDRESS/$node_name/log/log_$t.0$i.log >> $NODE_RESULT_ADDRESS/node_test_$node_name.txt 2>&1
        elif [[ $i -ge 10 && -f $NODE_ADDRESS/$node_name/log/log_$t.$i.log ]]; then
            tail -n $row $NODE_ADDRESS/$node_name/log/log_$t.$i.log >> $NODE_RESULT_ADDRESS/node_test_$node_name.txt 2>&1
        fi
        let i+=1
    done
    # tail -n $row $LOG_ADDRESS/$node_name/log/log_2023060716.00.log > $NODE_RESULT_ADDRESS/node_test_$node_name.txt 2>&1
    # docker logs -f $node_name --tail 10 > $NODE_RESULT_ADDRESS/node_test_$node_name.txt 2>&1 &
}

if [ ! -d "$NODE_RESULT_ADDRESS" ]; then
    mkdir -p $NODE_RESULT_ADDRESS
fi

test_node_data_consistency