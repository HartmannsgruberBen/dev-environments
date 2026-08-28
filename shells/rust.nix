{ pkgs, banner }:
let
  # Werkzeuge, die ausgeführt werden
  tools = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    pkg-config
  ];
  # Bibliotheken, gegen die gelinkt wird
  libs = with pkgs; [ openssl ];
  env = {
    # rust-analyzer braucht die Quellen der Standardbibliothek
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };
in
pkgs.mkShell {
  name = "rust";
  nativeBuildInputs = tools;
  buildInputs = libs;
  inherit env;
  shellHook = banner "Rust-Toolchain" (tools ++ libs);
  passthru.shellEnv = env;
}
