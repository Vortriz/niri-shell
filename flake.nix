{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    outputs = {
        self,
        nixpkgs,
        ...
    }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
    in {
        formatter.${system} = pkgs.alejandra;

        devShells.${system}.default = pkgs.mkShell {
            packages = with pkgs; [
                ruff
            ];
        };
    };
}
