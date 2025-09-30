{
  description = "AWS-Credentials";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "aarch64-darwin" ];

      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ ];
        };

        devenv.shells.default = {
          name = "aws-credentials";

          # https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
          imports = [
            # ./nix/example.nix
          ];

          # https://search.nixos.org/packages
          packages = with pkgs; [
            beamMinimal27Packages.rebar3
          ];


          # https://devenv.sh/reference/options/
          languages.erlang = {
            enable = true;
            package = pkgs.beamMinimal27Packages.erlang;
          };

        };

        formatter = pkgs.nixpkgs-fmt;
      };

      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
      flake = { };
    };
}
