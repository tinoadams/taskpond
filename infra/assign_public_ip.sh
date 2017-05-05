#!/bin/bash -ex

# SCALEWAY_ORGANIZATION="14b45181-66c1-4064-934c-bcb5fd2a2156"
# SCALEWAY_TOKEN="50bcb3dc-cf23-4338-9fda-049962820a20"
IP=$1
SERVER_ID=$2

curl -H "X-Auth-Token: ${SCALEWAY_TOKEN}" -H 'Content-Type: application/json' \
    https://cp-par1.scaleway.com/ips | jq -r ".ips[]|select(.address == \"${IP}\")|.id" > /tmp/ip_id

DATA="{\"id\":\"`cat /tmp/ip_id`\",\"address\":\"${IP}\",\"organization\":\"${SCALEWAY_ORGANIZATION}\",\"reverse\":null,\"server\":\"${SERVER_ID}\"}"
curl -H "X-Auth-Token: ${SCALEWAY_TOKEN}" -H 'Content-Type: application/json' \
    -X PUT https://cp-par1.scaleway.com/ips/`cat /tmp/ip_id` -d "${DATA}"