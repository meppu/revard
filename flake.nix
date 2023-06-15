{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { nixpkgs, systems, ... }@inputs:
    let 
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      devShells = forEachSystem (system:
        let 
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          inherit inputs pkgs;

          default = pkgs.mkShell {
            packages = with pkgs; [ elixir ];
          };
        });
    };
}
