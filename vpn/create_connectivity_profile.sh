#!/bin/bash
TARGET="$1"
CREDS="$2"
curl -k -u ${CREDS} -X POST \
  https://${TARGET}/mgmt/tm/apm/profile/connectivity \
  -H 'Content-Type: application/json' \
  -d '{
	"name":"erchenConnect",
	"partition":"Common",
	"compressGzipLevel": 0
}'
