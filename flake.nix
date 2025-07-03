{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        # Externally extensible
        systems = {
            url = "path:./flake.systems.nix";
            flake = false;
        };

        ignis = {
            url = "github:ignis-sh/ignis";
            inputs.nixpkgs.follows = "nixpkgs";
            inputs.systems.follows = "systems";
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
        packages = forAllPkgs (pkgs: {
            default = ignis.packages.${pkgs.system}.ignis.override {
                extraPackages = with pkgs.python313Packages; [
                    psutil
                    jinja2
                    pillow
                    materialyoucolor
                ];
            };
        });

        overlays.default = final: prev: {ignis = self.packages.${prev.system}.default;};

        homeModules.default = {
            config,
            pkgs,
            ...
        }: let
            cfg = config.programs.niri-shell;
        in {
            options.programs = {
                niri-shell = {
                    enable = lib.mkEnableOption "ignis shell";

                    package = lib.mkPackageOption self.packages.${pkgs.system} "default" {};

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
                home.packages = [cfg.package] ++ cfg.externalPackages;
            };
        };

        formatter = forAllPkgs (pkgs: pkgs.alejandra);

        devShells = forAllPkgs (pkgs: {
            default = pkgs.mkShell {
                packages = with pkgs; [
                    self.packages.${pkgs.system}.default
                    ruff
                ];

                LD_LIBRARY_PATH = lib.makeLibraryPath [pkgs.gtk4-layer-shell];
            };
        });
    };
}
