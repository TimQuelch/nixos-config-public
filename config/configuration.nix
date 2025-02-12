{ config, lib, pkgs, hostname, user, rebuild, ... }: {
  nix = {
    settings = {
      substituters =
        [ "http://nix.epsilon.tquelch.com" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix.epsilon.tquelch.com-1:YkLqk/hXEnt+WIVVef+qNwXNAoQOMqdNjOS4B2Mm5Tk="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      experimental-features = [ "nix-command" "flakes" ];
      use-xdg-base-directories = true;
      trusted-users = [ "root" user ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Setup secrets
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  # Set up networking
  networking.hostName = hostname;

  sops.secrets.tailscale_auth_key = { };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [ "--accept-dns" "--accept-routes" ];
  };

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  services.resolved.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Misc config
  time.timeZone = "Australia/Melbourne";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  # Configure window and desktop enironments
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;

  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      binPath = "/run/current-system/sw/bin/Hyprland";
      comment = "Hyprland session managed by uwsm";
      prettyName = "Hyprland";
    };
  };

  # Configure audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  sops.secrets.user_password.neededForUsers = true;
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = ([ "wheel" ]
      ++ (lib.optionals config.virtualisation.docker.enable [ "docker" ]));
    hashedPasswordFile = config.sops.secrets.user_password.path;
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # Defer nearly all packages to home manger configs
  environment.systemPackages = with pkgs; [ rebuild vim tmux ];

  documentation.man = {
    man-db.enable = true;
    generateCaches = false; # disabled because it takes a long time on rebuild
  };

  services.locate.enable = true;

  modules.os.zswap.enable = true;
  modules.os.nixos-options.enable = false;

  virtualisation.docker.enable = true;

  # This is an annoying mix between home and non-home
  security.pam.services.hyprlock = { };
  environment.pathsToLink =
    [ "/share/xdg-desktop-portal" "/share/applications" ];

  # use new dbus broker instead of old bus
  services.dbus.implementation = "broker";

  # Should be overwritten in host specific configs
  system.stateVersion = lib.mkDefault "24.05";
}
