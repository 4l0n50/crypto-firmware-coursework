{
  description = "A flake to compile, flash and run the ECSW software.";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cmake
            pkgs.python3
            (pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.pyserial
            ]))
            pkgs.gcc-arm-embedded
            pkgs.openocd
            pkgs.picocom
            pkgs.usbutils
            pkgs.stlink
            pkgs.qemu
          ];
        };
      });
}
