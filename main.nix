{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {};
in
{
  imports = [
    #<nixpkgs/nixos/modules/profiles/hardened.nix>
    ./x.nix
  ];
 
  security.allowSimultaneousMultithreading = true;
  security.allowUserNamespaces = true;
  security.lockKernelModules = false;
  
  system.autoUpgrade.enable = false;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/admin";
    createHome = true;
    useDefaultShell = true;
  };

  # Enable zram swap
  zramSwap.enable = true;
  zramSwap.priority = 10;
  zramSwap.algorithm = "lzo";
  zramSwap.numDevices = 1;
  zramSwap.swapDevices = 1;
  zramSwap.memoryPercent = 40;
  
  boot.kernelPackages = pkgs.linuxPackages_latest_hardened;

  networking.enableIPv6 = false;
  networking.dhcpcd.extraConfig = "\nnoipv6rs \nnoipv6";
  networking.useHostResolvConf = false;

  # Shell aliases
  environment.interactiveShellInit = ''
    alias c='clear'
    alias h='history'
    alias e='exit'
    alias rf='rm -rf'
    alias la='ls -a'
    alias s='sudo'
  '';

  environment.systemPackages = with pkgs; [
    # Test unstable chanel
    #unstable.hello

    # Basic
    git
    wget
    htop
    tmux
    openssh
    tree
    mc
    links2
    ping
    
    # Cryptography
    gnupg
    cryptsetup   

    #Secure
    firejail 

    # Editors
    vim
    
    # For USB devices
    ntfs3g
    
    # Terminal
    termite

    # Desctop
    rofi
  ];

  systemd.services.foo = {
    script = ''
      git=${pkgs.git} && $git/bin/git config --system user.name "John Doe" && $git/bin/git config --system user.email "johndoe@example.com"
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {User = "root";};
  };
}
