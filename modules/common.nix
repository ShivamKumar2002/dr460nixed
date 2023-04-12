{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.dr460nixed.common;
in
{
  options.dr460nixed.common = {
    enable = mkEnableOption "All the things needed to play games";
  };

  config = mkIf cfg.enable
    {
      ## Enable BBR & cake
      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "kernel.printks" = "3 3 3 3";
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        "kernel.sysrq" = 1;
        "kernel.unprivileged_userns_clone" = 1;
        "net.core.default_qdisc" = "cake";
        "net.core.rmem_max" = 2500000;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.ipv4.tcp_fin_timeout" = 5;
        "vm.swappiness" = 60;
      };

      # We want to be insulted on wrong passwords
      security.sudo = {
        execWheelOnly = true;
        extraConfig = ''
          Defaults pwfeedback
          deploy ALL=(ALL) NOPASSWD:ALL
        '';
        package = pkgs.sudo.override { withInsults = true; };
      };

      # Programs I always need
      programs = {
        git = {
          enable = true;
          lfs.enable = true;
        };
        gnupg.agent.enable = true;
        # Better for mobile device SSH
        mosh.enable = true;
        # Use the performant openssh
        ssh.package = pkgs.openssh_hpn;
      };

      # Always needed services
      services = {
        locate = {
          enable = true;
          localuser = null;
          locate = pkgs.plocate;
        };
        openssh = {
          enable = true;
          startWhenNeeded = true;
        };
        vnstat.enable = true;
      };

      # Environment
      environment.variables = { MOSH_SERVER_NETWORK_TMOUT = "604800"; };

      # Enable all the firmwares
      hardware.enableRedistributableFirmware = true;

      # Who needs documentation when there is the internet? #bl04t3d
      documentation = {
        doc.enable = false;
        enable = false;
        info.enable = false;
        man.enable = false;
        nixos.enable = false;
      };

      # This is the default sops file that will be used for all secrets
      sops.defaultSopsFile = ../secrets/global.yaml;

      # Zerotier network to connect the devices
      networking.firewall.trustedInterfaces = [ "tailscale0" ];
      services.tailscale = {
        enable = true;
        permitCertUid = "nico";
      };
    };
}
