{ pkgs, banner }:
let
  tools = with pkgs; [
    bun
    nodejs
    pnpm
    eslint
    prettier
    chromium
  ];
  env = { };
in
pkgs.mkShell {
  name = "typescript";
  nativeBuildInputs = tools;
  inherit env;
  shellHook = banner "TypeScript-Toolchain" tools;
  passthru.shellEnv = env;
}
