{
  description = "giveaway";
  nixConfig.bash-prompt = "[nix(giveaway)] ";

  inputs = {
    butler.url =
      "github:ButlerOS/haskell-butler/e559d3fc8eadaef3a37f4882498053864bf22fb7";
  };

  outputs = { self, butler }:
    let
      pkgs = butler.pkgs;

      packageName = "giveaway";

      haskellExtend = hpFinal: hpPrev: {
        ${packageName} = hpPrev.callCabal2nix packageName self { };
      };

      hsPkgs = (pkgs.hspkgs.extend butler.haskellExtend).extend haskellExtend;
      appExe = pkgs.haskell.lib.justStaticExecutables hsPkgs.${packageName};

      ciTools = with pkgs; [ cabal-install doctest nixfmt cabal-gild ];

    in {
      packages."x86_64-linux".default = appExe;
      devShell."x86_64-linux" = hsPkgs.shellFor {
        packages = p: [ p.${packageName} ];
        buildInputs = with pkgs; ciTools ++ [ ghcid ];
      };
    };
}
