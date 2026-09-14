let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQKHHm9h+5HuoPCGzcEc11oVl/V1BcITzH/9XeMdAP7 root@x220"
  ];
in
{
  "acme_hostinger.age".publicKeys = keys;
  "penpot-secret-key.age".publicKeys = keys;
  "authelia-jwt.age".publicKeys = keys;
  "authelia-storage-key.age".publicKeys = keys;
  "authelia-session-secret.age".publicKeys = keys;
  "authelia-oidc-hmac.age".publicKeys = keys;
  "authelia-oidc-jwks.age".publicKeys = keys;
  "paperless-oidc.age".publicKeys = keys;
  "grafana-oidc.age".publicKeys = keys;
  "jellyfin-sso.age".publicKeys = keys;
  "onlyoffice-jwt.age".publicKeys = keys;
  "onlyoffice-nonce.age".publicKeys = keys;
  "penpot-oidc.age".publicKeys = keys;
  "nextcloud-oidc.age".publicKeys = keys;
  "forgejo-oidc.age".publicKeys = keys;
}
