{
  inputs = {
    nyarna-zig.url = github:nyarnalang/nyarna-zig;
    utils.url   = github:numtide/flake-utils;
    filter.url  = github:numtide/nix-filter;
  };
  outputs = {self, nyarna-zig, utils, filter}:
      with utils.lib; eachSystem allSystems (system: let
    pkgs = nyarna-zig.inputs.nixpkgs.legacyPackages.${system};
    cli  = nyarna-zig.packages.${system}.cli;
    wasm = nyarna-zig.packages.${system}.wasm;
  in {
    defaultPackage = pkgs.stdenvNoCC.mkDerivation {
      pname   = "nyarna-website";
      version = "0.1.0";
      src = self; # cannot use filter due to strange error
      buildPhase = ''
        mkdir build
        ${cli}/bin/nyarna -o build website.ny
      '';
      installPhase = ''
        mkdir -p $out
        mv build $out/www
        cp -t $out/www --no-preserve='ownership' -r *.css font tour.js
        cp -t $out/www --no-preserve='ownership' ${wasm}/www/*
      '';
    };
  });
}