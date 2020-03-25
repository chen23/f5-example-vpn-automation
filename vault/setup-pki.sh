# adapted from: https://learn.hashicorp.com/vault/secrets-management/sm-pki-engine
TOKEN=root
curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"type":"pki"}' \
       http://127.0.0.1:8200/v1/sys/mounts/pki

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"max_lease_ttl":"87600h"}' \
       http://127.0.0.1:8200/v1/sys/mounts/pki/tune

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data @ca.json \
       http://127.0.0.1:8200/v1/pki/root/generate/internal \
       | jq -r ".data.certificate" > CA_cert.crt

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data @payload-url.json \
       http://127.0.0.1:8200/v1/pki/config/urls

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"type":"pki"}' \
       http://127.0.0.1:8200/v1/sys/mounts/pki_int

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"max_lease_ttl":"43800h"}' \
       http://127.0.0.1:8200/v1/sys/mounts/pki_int/tune

CSR=$(curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data @payload-int.json \
       http://127.0.0.1:8200/v1/pki_int/intermediate/generate/internal | jq .data.csr)

PAYLOAD="{\"csr\":$CSR,\"format\":\"pem_bundle\",\"ttl\":\"43800h\"}"
echo $PAYLOAD > payload-int-cert.json

SIGNED_CERT=$(curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data @payload-int-cert.json \
       http://127.0.0.1:8200/v1/pki/root/sign-intermediate | jq .data.certificate)
PAYLOAD="{\"certificate\":$SIGNED_CERT}"
echo $PAYLOAD > payload-signed.json

curl --header "X-Vault-Token: $TOKEN" \
        --request POST \
        --data @payload-signed.json \
        http://127.0.0.1:8200/v1/pki_int/intermediate/set-signed

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data @payload-role.json \
       http://127.0.0.1:8200/v1/pki_int/roles/example-dot-com

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"common_name": "vpn.example.com", "ttl": "24h"}' \
       http://127.0.0.1:8200/v1/pki_int/issue/example-dot-com | jq

curl --header "X-Vault-Token: $TOKEN" \
       --request POST \
       --data '{"common_name": "client.vpn.example.com", "ttl": "24h"}' \
       http://127.0.0.1:8200/v1/pki_int/issue/example-dot-com | jq

