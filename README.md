# Dev Environments (Rust, TypeScript, Python)

Ready-made **development environments**. An environment is a shell (a terminal)
where all tools for a language are already installed: compiler, package manager,
formatter, etc.

---

## Which environments are there?

| Name         | What's inside                                                     | Use for                              |
| ------------ | ----------------------------------------------------------------- | ------------------------------------ |
| `rust`       | rustc, cargo, rustfmt, clippy, rust-analyzer, pkg-config, openssl | regular Rust projects                |
| `rust-tauri` | everything from `rust` + GTK/WebKit libraries                     | Tauri apps (e.g. aevitas)            |
| `typescript` | bun, node, pnpm, eslint, prettier, chromium                       | TypeScript/JavaScript                |
| `python`     | python3, uv                                                       | running Python programs              |
| `full`       | **everything** above combined (rust-tauri + typescript + python)  | projects that use multiple languages |

---

## 1. Start an environment

The command is always the same, only the name after the `#` changes:

```bash
nix develop ~/programming/dev-environments#rust
nix develop ~/programming/dev-environments#rust-tauri
nix develop ~/programming/dev-environments#typescript
nix develop ~/programming/dev-environments#python
```

Afterwards you see what was loaded, for example:

```
Rust-Toolchain:
  rustc            1.97.1
  cargo            1.97.1
  ...
```

**Tip:** `cd` into your project folder first, then you work right there:

```bash
cd ~/programming/rust/my-project
nix develop ~/programming/dev-environments#rust
cargo build
```

**Leave again:**

```bash
exit
```

---

## 2. Start everything at once

One environment with Rust (incl. Tauri), TypeScript **and** Python:

```bash
nix develop ~/programming/dev-environments#full
```

On startup all tool lists are shown one after another.

---

## 3. Run a single command (without entering the shell)

Handy when you just want to run something quickly:

```bash
nix develop ~/programming/dev-environments#python --command uv run main.py
nix develop ~/programming/dev-environments#rust   --command cargo test
```

The command runs inside the environment, afterwards you are back in your normal terminal.

---

## 4. Update (get newer versions)

Which versions are used is stored in `flake.lock`. It is like a bookmark
to a specific state of nixpkgs (the big Nix package collection).
As long as you don't change it, you **always get exactly the same versions**, even a year from now.

**Update everything to the latest state:**

```bash
cd ~/programming/dev-environments
nix flake update
```

**Then check that everything still works:**

```bash
nix flake check
```

**Did the update break something?** Restore the old `flake.lock`
(e.g. with `jj restore flake.lock`) and everything is back to how it was.

---

## 5. Add or remove a tool

Each environment has its own file in the `shells/` folder:

```
shells/rust.nix
shells/rust-tauri.nix
shells/typescript.nix
shells/python.nix
```

Example: add `just` to the Rust environment. Put it into the `tools` list in `shells/rust.nix`:

```nix
tools = with pkgs; [
  rustc
  cargo
  rustfmt
  clippy
  rust-analyzer
  pkg-config
  just        # <- new
];
```

Restart the shell, done. The new tool also shows up automatically in the
startup output. Package names can be found at <https://search.nixos.org/packages>.

**Tool or library?**

- Programs you **run** (cargo, just, …) go into `tools`.
- Libraries your code is **linked** against (openssl, gtk3, …) go into `libs`.

---

## 6. Use a specific version

Many programs exist in nixpkgs in several versions. Just swap the name:

```nix
# shells/typescript.nix
nodejs_22      # instead of nodejs (otherwise takes the current default version)

# shells/python.nix
python = pkgs.python312;   # instead of pkgs.python3
```

Available versions are listed at <https://search.nixos.org/packages>
(e.g. search for `nodejs_` or `python3`).

### Separate update state per environment (advanced)

Normally all environments share **one** nixpkgs state. That saves disk space and
is almost always enough. If you want e.g. a Rust update not to change the Python
environment, give each environment its own state. In `flake.nix`:

```nix
inputs = {
  nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
  nixpkgs-py.url = "github:NixOS/nixpkgs/nixos-unstable";
};
```

Then each state can be updated on its own:

```bash
nix flake update nixpkgs-py   # only Python gets newer
```

---

## 7. Run in a container (Podman)

There is **one** Dockerfile for all environments. Choose the environment with
`--build-arg DEVSHELL=…`.

**Build the image** (in the `dev-environments` folder):

```bash
cd ~/programming/dev-environments
podman build --format docker --build-arg DEVSHELL=rust       -f docker/Dockerfile -t rust-dev .
podman build --format docker --build-arg DEVSHELL=typescript -f docker/Dockerfile -t typescript-dev .
podman build --format docker --build-arg DEVSHELL=python     -f docker/Dockerfile -t python-dev .
podman build --format docker --build-arg DEVSHELL=full       -f docker/Dockerfile -t full-dev .
```

**Start the container** (your project is mounted at `/workspace`):

```bash
podman run -it --rm \
  -v ~/programming/rust/my-project:/workspace \
  rust-dev
```

You land directly inside the environment, in `/workspace`.

If you changed something in `shells/` after building, rebuild the image,
because the container holds a copy of `flake.nix`, `lib/` and `shells/`.

---

## 8. Free up disk space

Old versions stay in the Nix store until you clean up:

```bash
nix-collect-garbage --delete-older-than 14d
```

This deletes old profile generations (older than 14 days) and everything in the Nix store
that nothing needs anymore. That includes the packages of these environments while you are not in them.
No problem: anything missing is simply downloaded again on the next start.

## How is it structured?

```
dev-environments/
├── flake.nix          # entry point: lists all environments
├── flake.lock         # pins the exact versions (don't edit by hand)
├── lib/
│   └── banner.nix     # generates the version output on startup
├── shells/
│   ├── rust.nix
│   ├── rust-tauri.nix # builds on rust.nix
│   ├── typescript.nix
│   └── python.nix
└── docker/
    └── Dockerfile     # one Dockerfile for all environments
```

- **`flake.nix`** is the table of contents. It defines which environments exist and
  that `full` is composed of the others.
- **`shells/*.nix`** are the individual environments. This is where you change tools.
- **`lib/banner.nix`** writes the versions into the startup output at build time.
  That's why the shell starts instantly and doesn't have to ask every program for its version.
- **`flake.lock`** is maintained by `nix flake update`, not by you.
