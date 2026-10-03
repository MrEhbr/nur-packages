{ pkgs ? import <nixpkgs> { } }:

{
  nixosModules = import ./nixos-modules;

  adguard-exporter = pkgs.callPackage ./pkgs/adguard-home-exporter { };
  macism = pkgs.callPackage ./pkgs/macism { };
  speedtest-exporter = pkgs.callPackage ./pkgs/speedtest-exporter { };
  sqlit-tui = pkgs.callPackage ./pkgs/sqlit-tui { };
  yokoku = pkgs.callPackage ./pkgs/yokoku { };
}
