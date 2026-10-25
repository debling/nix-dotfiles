let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQKHHm9h+5HuoPCGzcEc11oVl/V1BcITzH/9XeMdAP7 root@x220"
    # ryzen — added for media-share-cred (its CIFS mount credential); try
    # to only ever give hosts what they need
  ];
  ryzenKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
    # from /etc/ssh/ssh_host_ed25519_key.pub, converted with ssh-to-age
    "age1wpq6wh6s9tsw6ye77k7lyqy5kqwgypw5uglr7vmeu4t9p6qty4rqfsg65t"
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
  "jellyfin-sso.age".publicKeys = ryzenKeys;
  # Generated with: age -r <ryzen age host key> (see ryzenKeys above);
  # content is the samba `netshare` machine-account credentials used by
  # ryzen's CIFS mount of /srv/media.
  "media-share-cred.age".publicKeys = ryzenKeys;
  "onlyoffice-jwt.age".publicKeys = keys;
  "onlyoffice-nonce.age".publicKeys = keys;
  "penpot-oidc.age".publicKeys = keys;
  "nextcloud-oidc.age".publicKeys = keys;
  "forgejo-oidc.age".publicKeys = keys;
}
