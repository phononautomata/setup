# Development environments

The goal is the same project checkout behaving predictably on either Mac,
without trying to make the operating systems byte-for-byte identical.

## Division of responsibility

| Layer | Mechanism | What it controls |
| --- | --- | --- |
| macOS command-line tools | Xcode Command Line Tools | Compiler and Apple SDK |
| Shared utilities | `Brewfile` | Lightweight tools expected on both Macs |
| Python | `uv` plus project files | Python version and dependency lock |
| Rust | `rustup` plus `rust-toolchain.toml` | Rust toolchain per project |
| R | Compatible interpreter plus `renv.lock` | R interpreter and project packages |
| LaTeX | Existing TeX distribution plus project notes | Document build requirements |
| Containers | Optional, project-specific | Services or unusually complex stacks |

Homebrew formula versions are intentionally not frozen globally. macOS and
Apple SDK versions differ between the machines, and forcing every utility to
an identical build would be brittle. Reproducibility belongs in each project:
source code, runtime declaration, lockfile, and a tested command.

The current side-by-side versions and the purpose of each tool are recorded in
[Tooling inventory](tooling-inventory.md).

## Establish the shared baseline

After cloning or pulling this repository, inspect what is missing:

```sh
./scripts/bootstrap-dev-environment.sh
```

The default mode changes nothing. To install missing Brewfile entries:

```sh
./scripts/bootstrap-dev-environment.sh --apply
```

The apply mode installs missing entries but does not perform a blanket upgrade.
On BigBlue, `uv` is installed from Astral's prebuilt standalone release rather
than compiled through Homebrew:

```sh
./scripts/install-uv.sh
./scripts/install-uv.sh --apply
```

Verify at any time with:

```sh
./scripts/verify-dev-environment.sh
```

For a fuller read-only inventory, including optional tools:

```sh
./scripts/audit-dev-environment.sh
```

On Apple silicon, these scripts deliberately prefer `/opt/homebrew` over a
legacy Intel Homebrew under `/usr/local`. BigBlue currently has traces of both.
It also runs Ventura, which Homebrew classifies as Tier 3; heavyweight current
formulae may be compiled from source and fail. For that reason, `uv`, R, and
optional linting tools are not installed through the shared Brewfile.

Commit `Brewfile` changes before applying them on the other Mac. Add a tool only
when it is genuinely useful across projects; project-specific command-line
dependencies belong in that project's setup.

## Python project standard

New or actively maintained Python projects should contain:

```text
pyproject.toml
uv.lock
.python-version
```

The local `.venv/` must be ignored by Git and rebuilt on each machine. Typical
workflow:

```sh
uv python pin 3.13
uv lock
uv sync
uv run python -m PACKAGE_OR_SCRIPT
```

Commit changes to all three project files. In automated or verification runs,
use `uv sync --locked` so an outdated lockfile causes a visible failure instead
of being silently rewritten. Do not copy `.venv`, Python caches, or an entire
Homebrew Python installation between machines.

The Python version is a project decision. `3.13` is a sensible starting point
for a new project in this ecosystem, but an existing project should retain a
working supported version until its tests pass on an upgrade.

## Rust project standard

Keep `Cargo.toml` and `Cargo.lock` in Git. Add a project toolchain declaration,
for example:

```toml
[toolchain]
channel = "1.89.0"
profile = "minimal"
components = ["clippy", "rustfmt"]
```

Save it as `rust-toolchain.toml`. `rustup` then selects the declared toolchain
when commands run inside that repository. Do not transfer `target/`.

## R project standard

Use `renv` for project packages:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

Commit `renv.lock`, `renv/activate.R`, and the small bootstrap files selected by
`renv`; ignore the project library itself. On the other Mac:

```r
renv::restore()
```

Record the tested R major/minor version in the project README. A project that
depends on an exact historical R interpreter needs its own stronger strategy,
such as a container; that complexity is not part of the workstation baseline.

The Macs currently have different R interpreters: BigBlue has 4.1.0 and
MotokoKusanagi has 4.4.2. Do not ask Homebrew on Ventura to build current R.
For an R project that must run on both machines, install CRAN's signed
`R-4.4.2-arm64.pkg` on BigBlue, verify its Apple signature first, and then use
`renv::restore()`. Interpreter alignment is handled separately because the
latest CRAN arm64 release requires macOS 14 and cannot run on BigBlue.

## LaTeX and containers

The existing TeX Live installations differ. For each active manuscript,
document the local build command and test it on both Macs; keep generated
auxiliary and output files out of Git unless the project intentionally publishes
the PDF. Overleaf remains a useful independent build path.

Docker is optional. Add a container definition only when it captures services
or system dependencies that the normal project lockfiles cannot express. It is
not required merely to run ordinary Python, Rust, R, or LaTeX work.

## First project pilot

`sf_dt` is a suitable Python pilot because it already has `pyproject.toml` and
is available on both machines. Before adding a lockfile:

1. confirm its real runtime dependencies are declared;
2. select and record a Python version;
3. generate `uv.lock` on its working branch;
4. run its tests or documented smoke test on MotokoKusanagi;
5. push, pull on BigBlue, run `uv sync --locked`, and repeat the test.

Do this as a project change with its own review. The setup repository does not
modify `sf_dt`.

## Primary references

- [Homebrew Bundle and Brewfiles](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Homebrew support tiers](https://docs.brew.sh/Support-Tiers)
- [`uv` project locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/)
- [`uv` standalone installation](https://docs.astral.sh/uv/getting-started/installation/)
- [`renv` project environments](https://rstudio.github.io/renv/articles/renv)
- [CRAN R binaries for Apple silicon macOS 11+](https://cran.r-project.org/bin/macosx/big-sur-arm64/base/)
- [Rust toolchain override file](https://rust-lang.github.io/rustup/overrides.html#the-toolchain-file)
