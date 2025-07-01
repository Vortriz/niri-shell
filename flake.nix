{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        # Externally extensible
        systems = {
            url = "path:./flake.systems.nix";
            flake = false;
        };

        ignis = {
            url = "github:Vortriz/ignis";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {
        self,
        nixpkgs,
        systems,
        ignis,
        ...
    }: let
        inherit (nixpkgs) lib legacyPackages;
        forAllSystems = lib.genAttrs (import systems);
        forAllPkgs = f: forAllSystems (system: f legacyPackages.${system});
    in {
        packages = forAllPkgs (pkgs: {default = ignis.packages.${pkgs.system}.ignis;});

        homeModules.default = {
            config,
            pkgs,
            ...
        }: let
            cfg = config.programs.ignis-shell;
        in {
            options.programs = {
                ignis-shell = {
                    enable = lib.mkEnableOption "ignis shell";

                    package = lib.mkPackageOption pkgs "ignis-shell" {
                        default = ignis.packages.${pkgs.system}.default;
                    };

                    extraPackages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        description = "Extra packages to be included in for building Ignis shell.";
                        default = with pkgs.python313Packages; [
                            # Add extra dependencies here
                            psutil
                            jinja2
                            pillow
                            materialyoucolor
                        ];
                    };

                    externalPackages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        description = "External packages to be included for functioning of Ignis shell.";
                        default = with pkgs; [
                            papirus-icon-theme
                        ];
                    };
                };
            };

            config = lib.mkIf cfg.enable {
                home.packages = [cfg.package.override {inherit (cfg) extraPackages;}] ++ cfg.externalPackages;
            };
        };

        formatter = forAllPkgs (pkgs: pkgs.alejandra);

        devShells = forAllPkgs (pkgs: {
            default = pkgs.mkShell {
                packages = with pkgs; [
                    self.packages.${pkgs.system}.default
                    ruff
                ];
            };
        });
    };
}
