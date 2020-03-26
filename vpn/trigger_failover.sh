#!/bin/bash
PWD=$2
TARGET=$1
curl -k -u ${PWD} -X POST -d '{"command":"run","trafficGroup":"traffic-group-1","standby":true}' ${TARGET}/mgmt/tm/sys/failover -H content-type:application/json
curl -k -u ${PWD} -X POST -d '{"name":"data","partition":"LOCAL_ONLY","gw":"10.1.11.1","network":"10.1.10.0/24"}' ${TARGET}/mgmt/tm/net/route -H content-type:application/json
curl -k -u ${PWD} -X POST -d '{"command":"save"}' ${TARGET}/mgmt/tm/sys/config -H content-type:application/json

