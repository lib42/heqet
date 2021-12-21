# Vault

This are some quick notes I took on how to setup a simple Vault for usage with heqet. For a more detailed documentation on how to configure Vault, check out the [Official Vault Docs](https://www.vaultproject.io/docs).

Note: Most of this commands can be executed either using the `vault` command on your local device or the inside the vault pod itself.

## Init Vault using GPG

### Copy GPG Public Key
``` shellsession
cat > nold.pub << EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQENBGBXTjkBCAC7qZU1cz7RWYbAb838ypRLJZKLWfVBvry4XYwWPN0Rcj55dPN+
...
5of4H66FzNwJxYrunmM5KTeUxZiLPC1JoKMF5uvKoo59TD0IuAPq735QDjWbS4vb
dMtSqTCinZSd
=wuZw
-----END PGP PUBLIC KEY BLOCK-----
EOF
```

### Init Vault
``` shellsession
vault operator init -key-shares=1 -key-threshold=1 -pgp-keys="nold.pub"
```


### Save Unseal Key somewhere sage e.g. Keepass

### Decode Unseal Key
``` shellsession
$ echo $unseal-key | base64 -d | gpg -dq
```

### Unseal Vault
``` shellsession
vault operator unseal
```


## Enable Kubernetes Auth

```shellsession
vault auth enable kubernetes

vault write auth/kubernetes/config \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    disable_iss_validation=true
```

 

## Create Secret Store

```
vault secrets enable -path=heqet kv-v2
```

## Add Secrets-Operator Role & Policy

### Create Policy
```shellsession
vault policy write heqet-app << EOF
path "heqet/+/*" {
  capabilities = ["read"]
}
EOF
```


### Add Auth Role

```shellsession
vault write auth/kubernetes/role/heqet-app \
  bound_service_account_names=vault-secrets-operator \
  bound_service_account_namespaces=vault-secrets-operator \
  policies=heqet-app \
  ttl=6h
```

## Add Secrets

Remember, Secret path: `heqet/<APP-NAME>/<SECRET-NAME>`

```shellsession	
vault kv put heqet/argocd/argocd-secret admin.password='$2y$12$FP8OlsVj5pOOqRAhI4XPoev1STaW01uUEZGcNPQtVZmpacebNhj9i' server.secretkey="pDYAWK2mHa68GwwVPAsQOsG/SUT8iIo3S3FXYUWf2qM="
vault kv put heqet/loki-stack/loki-stack-grafana admin-user=admin admin-password='grafana'
vault kv put heqet/pihole/pihole-admin password=pihole
vault kv put heqet/minio/minio-secret secret-key=secret access-key=access
```

## Vault-Issuer Cert-Manager via Kubernetes Service Account

We expect you already have setup a PKI & Intermediate PKI. You will need a policy to allow your approle to create new certs:


And a role: [dc = my local domain]
``` shellsession
vault write pki_int/roles/dc \
    allowed_domains=.dc \
    allow_subdomains=true \
    max_ttl=72h
```

Policy:
```shellsession
vault policy write pki_int - <<EOF
path "pki_int*" { capabilities = ["read", "list"] }
path "pki_int/roles/dc"   { capabilities = ["create", "update"] }
path "pki_int/sign/dc"    { capabilities = ["create", "update"] }
path "pki_int/issue/dc"   { capabilities = ["create"] }
EOF
```

Authorize Service Account
``` shellsession
vault write auth/kubernetes/role/vault-issuer \
  bound_service_account_names=vault-issuer \
  bound_service_account_namespaces=cert-manager \
  policies=pki_int \
  ttl=6h
```
