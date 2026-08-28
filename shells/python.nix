{ pkgs, banner }:
let
  python = pkgs.python3;
  tools = [
    python
    pkgs.uv
  ];
  env = {
    # uv nutzt das Nix-Python und lädt keine eigenen Interpreter herunter
    UV_PYTHON = "${python}/bin/python3";
    UV_PYTHON_DOWNLOADS = "never";
    # vorkompilierte PyPI-Wheels (numpy, pandas, …) finden libstdc++/libz
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
    ];
  };
in
pkgs.mkShell {
  name = "python";
  nativeBuildInputs = tools;
  inherit env;
  shellHook = banner "Python-Toolchain" tools;
  passthru.shellEnv = env;
}
