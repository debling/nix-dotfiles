{ pkgs, mainUser, ... }:

{
  users.users.${mainUser} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "podman"
      "adbusers"
      "input"
      "uinput"
      "dialout"
      "kvm"
    ];
    hashedPassword = "$y$j9T$O4qn0aOF8U9FQPiMXsv41/$CkOtnJbkV4lcZcCwQnUL0u4xlfoYhvN.9pCUzT2uFI5";
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;
}
