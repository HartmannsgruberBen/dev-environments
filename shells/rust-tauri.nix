{
  pkgs,
  banner,
  rust,
}:
let
  # atk, pango, cairo und gdk-pixbuf bringt gtk3 selbst mit
  libs = with pkgs; [
    dbus
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];
in
pkgs.mkShell {
  name = "rust-tauri";
  inputsFrom = [ rust ];
  buildInputs = libs;
  env = rust.shellEnv;
  shellHook = ''
    ${banner "Tauri-Bibliotheken" libs}
    # GDK (Wayland) braucht org.gnome.desktop.interface, sonst DPI -1 -> WebKitGTK-Webview mit negativem devicePixelRatio
    export XDG_DATA_DIRS="$GSETTINGS_SCHEMAS_PATH:$XDG_DATA_DIRS"
  '';
  passthru.shellEnv = rust.shellEnv;
}
