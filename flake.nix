{
  description = "tests";

  inputs = {
    gepetto.url = "github:nim65s/gepetto-nix/test-shell";
    flake-parts.follows = "gepetto/flake-parts";
    systems.follows = "gepetto/systems";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        systems = import inputs.systems;
        imports = [
          inputs.gepetto.flakeModule
          {
            flakoboros = {
              pyOverrideAttrs.eigenpy =
                { drv-final, drv-prev, ... }:
                {
                  version = "9.9.9";
                  postPatch = ''
                    substituteInPlace package.xml \
                      --replace-fail ${drv-prev.version} ${drv-final.version}
                  '';
                };
            };
          }
        ];
        perSystem =
          { pkgs, system, ... }:
          {
            devShells = {
              inherit (inputs.gepetto.devShells.${system}) up;
              down = pkgs.callPackage "${inputs.gepetto}/shell.nix" { name = "down"; };
            };
          };
      }
    );
}
