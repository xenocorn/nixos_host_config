{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {};
in
{
  imports = [
    ./x.nix
  ];
 
  security.allowSimultaneousMultithreading = true;
  security.allowUserNamespaces = true;
  security.lockKernelModules = false;
  
  system.autoUpgrade.enable = false;

  time.timeZone = "Europe/Greenwich";

  networking.hostName = "default";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sound" "video" "networkmanager" "input" "tty" ];
    home = "/home/admin";
    createHome = true;
    useDefaultShell = true;
  };

  # Enable nix store optimisation
  nix.autoOptimiseStore = true;

  # Enable zram swap
  zramSwap.enable = true;
  zramSwap.priority = 10;
  zramSwap.algorithm = "zstd";
  zramSwap.numDevices = 1;
  zramSwap.swapDevices = 1;
  zramSwap.memoryPercent = 50;

  # Enable KSM
  hardware.ksm.enable = true;
  
  boot.kernelPackages = pkgs.linuxPackages_latest_hardened;

  boot.cleanTmpDir = true;

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
    alias qr='qrencode -t UTF8 -o -'
  '';

  services.searx.enable = true;
  services.searx.settings = { 
    general.debug = false;
    general.instance_name = "Searx";
    server.port = 8888;
    server.bind_address = "127.0.0.1";
    server.secret_key = "SEARX_SECRET_KEY";
    search.autocomplete = "duckduckgo";
    search.language = "en-US";
  };
  #services.searx.settingsFile = builtins.toFile "settings.yml" (import ./programconfigs/searx.nix).asYaml;

  environment.systemPackages = with pkgs; [
    # Test unstable chanel
    #unstable.hello

    # Basic
    git
    wget
    htop
    openssh
    tree
    links2
    ping
    neofetch

    # File manager
    lf

    # Cryptography
    gnupg
    cryptsetup   

    # Secure
    firejail 

    # Editors
    vim
    
    # For USB devices
    ntfs3g
    
    # Terminal
    termite
    #alacritty

    # Desctop
    rofi

    # Web
    firefox
    ipfs
    
    # Audio
    ncmpcpp
    
    # Console tools
    qrencode
  ];

  #services.ipfs = {
  #  enable = true;
  #};

  services.mpd.enable = true;
  services.mpd.extraConfig = ''
    audio_output {
      type "pulse"
      name "Pulseaudio"
    }
  '';

  programs = {
    ssh.askPassword = "";
  };

  systemd.services.foo = {
    script = ''
      git=${pkgs.git} && $git/bin/git config --system user.name "John Doe" && $git/bin/git config --system user.email "johndoe@example.com"
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {User = "root";};
  };
}
