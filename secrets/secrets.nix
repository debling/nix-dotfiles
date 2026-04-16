let
  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJdyN9ifYpEHZI2jXe7YYKVfNQMuAmofsgg7Txf3YSq d.ebling8@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPUuCteGtKvL12/cAu9GwaLVWjWEtGHh6mTr1cfFwWGV root@x220"
  ];
in
{
    "acme_hostinger.age".publicKeys = keys;
}
