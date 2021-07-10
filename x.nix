{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;

    layout = "us,ru";
    # xkbVariant = "workman,";
    xkbOptions = "grp:shifts_toggle";

    displayManager = {
      sddm.enable = true;
      autoLogin.enable = true;
      autoLogin.user = "admin";
      defaultSession = "none+awesome";
    };
 
    windowManager.awesome = {
     enable = true;
     luaModules = with pkgs.luaPackages; [
       luarocks # lua package manager
       luadbi-mysql # database
     ];
    };
  };
}
