FROM docker.io/library/debian:stable-slim

# Welche Shell aus dem Flake: rust, rust-tauri, typescript, python oder full
ARG DEVSHELL=rust
ENV DEVSHELL=${DEVSHELL}

# Installiere System-Abhängigkeiten mit Pipe-Absicherung
RUN set -o pipefail && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl xz-utils ca-certificates git && \
    rm -rf /var/lib/apt/lists/*

# Installiere Nix über Determinate Systems (mit Pipe-Überprüfung)
RUN set -o pipefail && \
    curl --proto '=https' --tlsv1.2 -sSfL https://install.determinate.systems/nix | \
        sh -s -- install linux \
            --extra-conf "sandbox = false" \
            --init none \
            --no-confirm

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

WORKDIR /env
COPY flake.nix flake.lock ./
COPY lib ./lib
COPY shells ./shells

# Shell schon beim Bauen herunterladen; schlägt das fehl, bricht der Build ab
RUN nix develop "path:/env#${DEVSHELL}" --command true

WORKDIR /workspace
CMD ["/bin/bash", "-lc", "nix develop \"path:/env#${DEVSHELL}\""]
