let
  mpennington = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYV32D/BCBriokwRoRWDY4atdvgI3qXqfbfMqEg2MYp mpennington@poseidon";

  # You will need to add the host public keys for poseidon and artemis here
  # so that those machines can decrypt the secret at boot time.
  # Run `cat /etc/ssh/ssh_host_ed25519_key.pub` on those machines to get the keys.
  poseidon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDcjEi2ix0Nl5KjNa3wXIv4r3tD8VPLVc2RnSO+r03lQ root@poseidon";
  artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzQIbjH6ESGRJC0ozUqwpAduVMDs1jOVIjNJkZNXfdS root@artemis";
  hermes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+gTSWEwblbym8D+MQjMgMHgy5UJmNqgK1lcAzG7Ynv root@hermes";

  # Combine keys
  systems = [poseidon artemis hermes];
  users = [mpennington];
in {
  "hermes-ssh.age".publicKeys = users ++ systems;
  "wg-private-hermes.age".publicKeys = users ++ [poseidon artemis hermes];
  "wg-private-artemis.age".publicKeys = users ++ [artemis];
  "wg-private-poseidon.age".publicKeys = users ++ [poseidon];
  "hermes-ip.age".publicKeys = users ++ [poseidon artemis];
}
