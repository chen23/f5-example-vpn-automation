#!/bin/bash
PWD=$2
TARGET=$1
curl -k -u ${PWD} -X POST -d '{"command":"run","trafficGroup":"traffic-group-1","standby":true}' ${TARGET}/mgmt/tm/sys/failover -H content-type:application/json
