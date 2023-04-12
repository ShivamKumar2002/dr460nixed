{ config
, pkgs
, ...
}:
let
  # For managing my battery levels
  ipman-source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/Lenovsky/ipman/master/ipman";
    sha256 = "14l9g7nwnl7x1wlacaswz854k7qw72jyb86fzqs1jayyza36hwqy";
  };
  ipman = pkgs.writeScriptBin "ipman" "${ipman-source}";
in
{
  # Individual settings
  imports = [
    ../../configurations/common.nix
    ../../configurations/desktops/impermanence.nix
    ../../configurations/services/chaotic.nix
    ./hardware-configuration.nix
  ];

  # Use Lanzaboote for secure boot
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      enableUnstable = true;
      requestEncryptionCredentials = false;
    };
    # Needed to get the touchpad to work
    blacklistedKernelModules = [ "elan_i2c" ];
    # The new AMD Pstate driver & needed modules
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call zenpower ];
    kernelModules = [ "acpi_call" "amdgpu" "amd-pstate=passive" ];
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
    lanzaboote = {
      configurationLimit = 20;
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
    loader.efi.canTouchEfiVariables = true;
  };

  # Network configuration & id for ZFS
  networking.hostName = "slim-lair";
  networking.hostId = "9c8011ee";

  # SSD
  services.fstrim.enable = true;

  # ZFS scrubbing
  services.zfs.autoScrub.enable = true;

  # AMD device
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.hardware.bolt.enable = false;

  # Enable OpenCL using rocm
  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
    rocm-opencl-runtime
  ];

  # Bleeding edge Mesa - once tag 22.3 is no longer needed
  # chaotic.mesa-git.enable = true;

  # Enable a few selected custom settings
  dr460nixed.desktops.enable = true;
  dr460nixed.development.enable = true;
  dr460nixed.gaming.enable = true;
  dr460nixed.performance-tweaks.enable = true;
  dr460nixed.yubikey = true;
  dr460nixed.chromium = true;
  dr460nixed.school = true;

  # Workaround to enable HIP
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  ];

  # RADV video decode
  environment.variables.RADV_VIDEO_DECODE = "1";

  # Virtualisation / Containerization
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "zfs";
      graphroot = "/var/lib/containers/storage";
      runroot = "/run/containers/storage";
      options.zfs = {
        fsname = "zroot/containers";
        mountopt = "nodev";
      };
    };
  };

  # Enable the touchpad & secure boot, as well as add the ipman script
  environment.systemPackages = with pkgs; [ libinput sbctl zenmonitor ] ++ [ ipman ];

  # Neeeded for lzbt
  boot.bootspec.enable = true;

  # Home-manager desktop configuration
  home-manager.users."nico" = import ../../configurations/home/desktops.nix;

  # A few secrets
  sops.secrets."machine-id/slim-lair" = {
    path = "/etc/machine-id";
    mode = "0600";
  };
  sops.secrets."ssh_keys/id_rsa" = {
    mode = "0600";
    owner = config.users.users.nico.name;
    path = "/home/nico/.ssh/id_rsa";
  };

  # NixOS stuff
  system.stateVersion = "22.11";
}
