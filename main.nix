{ config, pkgs, lib, ... }:

let
  unstable = import <nixos-unstable> {};
  #import <home-manager> {};
in
{
  imports = [
    ./x.nix
    <home-manager/nixos>
  ];
 
  security.allowSimultaneousMultithreading = true;
  security.allowUserNamespaces = true;
  security.lockKernelModules = false;
  
  system.autoUpgrade.enable = false;

  time.timeZone = "Europe/Greenwich";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  #users.defaultUserShell = pkgs.zsh;

  # Enable Oh-my-zsh
  #programs.zsh.ohMyZsh = {
  #  enable = true;
  #  plugins = [ "git" "sudo" ];
  #};

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sound" "video" "input" "tty" ];
    home = "/home/admin";
    createHome = true;
    useDefaultShell = true;
  };
  #nix.allowedUsers = [ "admin" ];

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

  networking.hostName = "default";
  networking.useDHCP = true;
  networking.firewall.enable = true;

  networking.enableIPv6 = false;
  networking.dhcpcd.extraConfig = "\nnoipv6rs \nnoipv6";
  networking.useHostResolvConf = false;

  networking.networkmanager.ethernet.macAddress = "random";
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.wifi.scanRandMacAddress = true;
  networking.tcpcrypt.enable = true;

  # Shell aliases
  environment.interactiveShellInit = ''
    alias c='clear'
    alias h='history'
    alias e='exit'
    alias rf='rm -rf'
    alias ll='ls -l'
    alias la='ls -la'
    alias s='sudo'
    alias qr='qrencode -t UTF8 -o -'
    alias m='micro'
    alias n='nano'
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
    killall
    xclip
    neofetch
    unstable.cpufetch #latest version with some fixes

    # File manager
    lf

    # Cryptography
    gnupg
    cryptsetup   

    # Secure
    firejail 

    # Editors
    unstable.micro
    
    # For USB devices & windows disks
    ntfs3g
    
    # Terminal
    #termite
    #alacritty

    #Shell
    #zsh

    # Desctop
    #rofi

    # Net
    macchanger

    # Web
    #firefox
    ipfs
    
    # Media
    vlc
    
    # Console tools
    qrencode

    # Remote
    #freerdp

    # Dev
    gcc
    gnumake
    gdb
    pkg-config
    unstable.rustup
    openssl
    openssl.dev
    dbus.dev
    python39
    python39Packages.pip
    python39Packages.poetry
    gnuplot
  ];
  
  environment.variables = {
    #OPENSSL_DIR = "${pkgs.openssl.dev}";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };



  programs.nano = {
    nanorc = ''
      set linenumbers
      set historylog
      set tabsize 2
      set autoindent
      set constantshow
      set nohelp
      set indicator
      set nowrap
      set tabstospaces
      set unix
      set wordbounds
    '';
    syntaxHighlight = true;
  };

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.admin = { pkgs, ... }: {
    home.packages = [
      pkgs.firefox
    ];
    home.file.".config/awesome/".source = ./awesome;
    home.file.".config/micro/settings.json".source = ./micro/settings.json;
    home.file.".config/micro/bindings.json".source = ./micro/bindings.json;
    programs.rofi = {
      enable = true;
      width = 50;
      lines = 24;
      font = "mono 12";
      extraConfig = {
        modi = "window,run,ssh,combi";
        columns = 2;
        show-icons = true;
        combi-modi = "run,ssh";
        line-margin = 0;
        line-padding = 1;
        separator-style = "none";
        hide-scrollbar = true;
        color-normal = "#222222, #777777, #333333, #888888, #111111";
        color-window = "#111111, #222222, #555555";
      };
    };
    programs.termite = {
      enable = true;
      allowBold = true;
      audibleBell = true;
      clickableUrl = true;
      dynamicTitle = true;
      font = "Monospace 9";
      scrollbackLines = 10000;
      browser = "firefox";
      cursorBlink = "system";
      filterUnmatchedUrls = false;
      scrollbar = "off";
      foregroundColor = "#888888";
      foregroundBoldColor = "#aaaaaa";
      backgroundColor = "#222222";
      highlightColor = "#111111";
      colorsExtra = ''
        color0 = #111111
        color1 = #705050
        color2 = #60b48a
        color3 = #dfaf8f
        color4 = #506070
        color5 = #dc8cc3
        color6 = #8cd0d3
        color7 = #dcdccc
        color8 = #709080
        color9 = #dca3a3
        color10 = #c3bf9f
        color11 = #f0dfaf
        color12 = #94bff3
        color13 = #ec93d3
        color14 = #93e0e3
        color15 = #ffffff
      '';
    };
  };

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

  systemd.services.gitsetup = {
    script = ''
      git=${pkgs.git} && $git/bin/git config --system user.name "John Doe" && $git/bin/git config --system user.email ""
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {User = "root";};
  };
}
