{
  description = "Dev-Umgebungen: Rust, TypeScript, Python";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          system: f nixpkgs.legacyPackages.${system}
        );
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          banner = import ./lib/banner.nix { inherit (pkgs) lib; };
          rust = import ./shells/rust.nix { inherit pkgs banner; };
          rust-tauri = import ./shells/rust-tauri.nix { inherit pkgs banner rust; };
          typescript = import ./shells/typescript.nix { inherit pkgs banner; };
          python = import ./shells/python.nix { inherit pkgs banner; };
        in
        {
          inherit
            rust
            rust-tauri
            typescript
            python
            ;

          # Alles in einer Shell. mkShell übernimmt Pakete und shellHooks aus
          # inputsFrom (Hooks in umgekehrter Reihenfolge), aber keine env-Variablen,
          # deshalb werden die über passthru.shellEnv eingesammelt.
          full = pkgs.mkShell {
            name = "full";
            inputsFrom = [
              python
              typescript
              rust-tauri
            ];
            env = rust-tauri.shellEnv // python.shellEnv;
          };
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree);
    };
}
