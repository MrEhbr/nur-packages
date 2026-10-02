{ pkgs ? import <nixpkgs> { } }:

{
  nixosModules = import ./nixos-modules;
}
