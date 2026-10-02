{ pkgs ? import <nixpkgs> { } }:

{
  nixosModules = import ./nixos-modules;

  yokoku = pkgs.callPackage ./pkgs/yokoku { };
}
