let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
  ];
in
{
  "sonarr-api-key.age".publicKeys = keys;
  "radarr-api-key.age".publicKeys = keys;
  "lidarr-api-key.age".publicKeys = keys;
  "prowlarr-api-key.age".publicKeys = keys;
  "bazarr-api-key.age".publicKeys = keys;
  "readarr-api-key.age".publicKeys = keys;
}
