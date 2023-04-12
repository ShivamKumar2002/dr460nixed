{ config, lib, pkgs, sources, ... }:
with lib;
let
  cfg = config.dr460nixed.nix-tweaks;
in
{
  options.dr460nixed.nix-tweaks = {
    enable = mkEnableOption "All the things needed to play games";
  };

  config = mkIf cfg.enable {
    # General nix settings
    nix = {
      # Do garbage collections whenever there is less than 1GB free space left
      extraOptions = ''
        min-free = ${toString (1024 * 1024 * 1024)}
      '';
      # Do daily garbage collections
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      settings = {
        # Only allow the wheel group to handle Nix
        allowed-users = [ "@wheel" ];
        # Allow using flakes
        auto-optimise-store = true;
        # A few extra binary caches
        extra-substituters = [
          "https://colmena.cachix.org"
          "https://dr460nf1r3.cachix.org"
          "https://garuda-linux.cachix.org"
          "https://nix-community.cachix.org"
          "https://nyx.chaotic.cx"
        ];
        extra-trusted-public-keys = [
          "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
          "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
          "dr460nf1r3.cachix.org-1:ujkI5l3i3m6Jh3J8phRXtnUbKdrn7JIxb/dPAO3ePbI="
          "garuda-linux.cachix.org-1:tWw7YBE6qZae0L6BbyNrHo8G8L4sHu5QoDp0OXv70bg="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        ];
        # This is a flake after all
        experimental-features = [ "nix-command" "flakes" ];
        max-jobs = "auto";
        system-features = [ "kvm" "big-parallel" ];
        trusted-users = [ "root" "nico" "deploy" ];
      };
      nixPath = [ "nixpkgs=${sources.nixpkgs}" ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # Clean results periodically
    systemd.services.nix-clean-result = {
      serviceConfig.Type = "oneshot";
      description = "Auto clean all result symlinks created by nixos-rebuild test";
      script = ''
        "${config.nix.package.out}/bin/nix-store" --gc --print-roots | "${pkgs.gawk}/bin/awk" 'match($0, /^(.*\/result) -> \/nix\/store\/[^-]+-nixos-system/, a) { print a[1] }' | xargs -r -d\\n rm
      '';
      before = [ "nix-gc.service" ];
      wantedBy = [ "nix-gc.service" ];
    };

    nixpkgs.config.permittedInsecurePackages = [
      "openssh-with-hpn-9.2p1"
    ];

    # Print a diff when running system updates
    system.activationScripts.diff = ''
      if [[ -e /run/current-system ]]; then
        (
          for i in {1..3}; do
            result=$(${config.nix.package}/bin/nix store diff-closures /run/current-system "$systemConfig" 2>&1)
            if [ $? -eq 0 ]; then
              printf '%s' "$result"
              break
            fi
          done
        )
      fi
    '';
  };
}