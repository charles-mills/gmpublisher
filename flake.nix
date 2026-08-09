{
  description = "Workshop Publishing Utility for Garry's Mod, written in Rust & Svelte and powered by Tauri";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      eachSystem = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      overlays.default = final: _: {
        gmpublisher = final.callPackage ./nix/package.nix { };
      };

      packages = eachSystem (pkgs: {
        gmpublisher = pkgs.callPackage ./nix/package.nix { };
        default = self.packages.${pkgs.stdenv.hostPlatform.system}.gmpublisher;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.callPackage ./nix/shell.nix {
          gmpublisher = self.packages.${pkgs.stdenv.hostPlatform.system}.gmpublisher;
        };
      });

      checks = eachSystem (pkgs: {
        inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) gmpublisher;
        devshell = self.devShells.${pkgs.stdenv.hostPlatform.system}.default;
      });

      formatter = eachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
