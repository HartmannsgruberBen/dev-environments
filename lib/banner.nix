# Erzeugt einen shellHook, der Name + Version der Pakete ausgibt.
# Die Versionen setzt Nix beim Bauen ein, beim Start läuft kein Programm.
{ lib }:
title: pkgs: ''
  echo "${title}:"
  ${lib.concatMapStringsSep "\n" (
    p: ''printf "  %-16s %s\n" "${lib.removeSuffix "-wrapper" (lib.getName p)}" "${lib.getVersion p}"''
  ) pkgs}
''
