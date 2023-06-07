#! /bin/bash

# pushd ../nodes/127.0.0.1/console

# script -a test_result.txt

# ../nodes/127.0.0.1/console/start.sh > result/test_result.txt 2>&1 << EOF
# call HelloWorld 0x4194afb162a323351435fb107dae6a234c0b37a9 get
# q
# EOF

../nodes/127.0.0.1/console/start.sh > result/test_result.txt 2>&1 << EOF
call TableTest 0x841ca048dcaff1569346b60ad30e9f08ee0f32e0 select fruit
q
EOF

# exit

# popd