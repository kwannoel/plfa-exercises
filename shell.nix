# Adapted from @ryanorendorff's gist: https://gist.github.com/ryanorendorff/f5c96d9f363a0e390425c2d9588bbb9d

{ pkgs ? import <nixos> {} }:

let
  # The standard library in nixpkgs does not come with a *.agda-lib file, so we
  # generate it here.
  standard-library-agda-lib = pkgs.writeText "standard-library.agda-lib" ''
    name: standard-library
    include: ${pkgs.AgdaStdlib}/share/agda
  '';

  # Agda uses the AGDA_DIR environmental variable to determine where to load
  # default libraries from. This should have a few files in it, including the
  # "defaults" and "libraries" files generated below.
  #
  # More information (and possibilities!) are detailed here:
  # https://agda.readthedocs.io/en/v2.6.0.1/tools/package-system.html
  agdaDir = pkgs.stdenv.mkDerivation {
    name = "agdaDir";

    phases = [ "installPhase" ];

    # If you want to add more libraries simply list more in the $out/libraries
    # and $out/defaults folder.
    installPhase = ''
      mkdir $out
      echo "${standard-library-agda-lib}" >> $out/libraries
      echo "standard-library" >> $out/defaults
    '';
  };

  agdaGhc = pkgs.haskellPackages.ghcWithPackages (
    haskellPackages: [ pkgs.haskellPackages.ieee ]
  );

in
  pkgs.mkShell {
    name = "agda-with-stdlib";
    buildInputs = [ pkgs.haskellPackages.Agda
                    agdaGhc
                  ];

    AGDA_DIR = agdaDir;
  }
