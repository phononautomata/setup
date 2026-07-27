# Architecture

## Stage 1: communication and source synchronization

### GitHub as canonical Git remote

Every active code or manuscript project should have one canonical GitHub remote
when its confidentiality and licensing allow it. Both Macs clone independently
and exchange commits through that remote:

```text
MotokoKusanagi <-- fetch/pull · GitHub · push --> BigBlue
```

Do not synchronize a live Git working tree through iCloud Drive or a generic
file-sync service. Concurrent file-level synchronization can interfere with
Git's own repository state and creates an unnecessary second source of truth.

The normal handoff is:

```sh
git status
git pull --ff-only
# work, test, and commit
git push
```

`--ff-only` prevents `git pull` from silently creating a merge commit. A later
shared Git configuration can make this the default after existing workflows
have been checked.

### One SSH identity per machine and purpose

Create, or deliberately select, separate passphrase-protected Ed25519 keys for:

- BigBlue → GitHub
- MotokoKusanagi → GitHub
- BigBlue → shared research servers, where required
- MotokoKusanagi → shared research servers, where required
- MotokoKusanagi → BigBlue

Private keys stay on the machine where they were generated. Only public keys
are registered with GitHub, servers, or BigBlue. `~/.ssh/config` should name the
key for each host and use `IdentitiesOnly yes` to avoid offering unrelated
keys.

Do not enable SSH agent forwarding globally. On multi-user research servers,
use it only for a specific, understood workflow; a process with access to the
forwarded socket can use the forwarded identity while the session is active.

### Private path between the Macs

Recommended candidate: Tailscale Personal, subject to user approval.

Reasons:

- no router port-forwarding;
- works when the laptop changes networks;
- encrypted peer-to-peer connectivity;
- compatible with both installed macOS versions;
- the current Personal plan is sufficient for this two-machine setup at no
  cost.

Tailscale provides connectivity, not storage or backup. BigBlue must also be
awake, connected, and running Remote Login for SSH to work.

Installation is intentionally not automated yet. It requires adding a VPN
system extension and signing in through an external identity provider.

## Stage 2: project layout and reproducibility

Use the same logical root on both machines:

```text
~/workshop/
  project-name/
    README.md
    src/
    tests/
    docs/
    environment/
    data/
      README.md
      raw/          # ignored by Git
      interim/      # ignored by Git by default
      processed/    # selectively tracked only when small and publishable
    outputs/        # ignored or selectively published
```

Each project should state:

- canonical repository URL;
- data classification and provenance;
- how data is obtained or restored;
- environment/build commands;
- which artifacts are reproducible versus irreplaceable;
- server paths, without credentials;
- publication/archive identifiers.

Docker can help reproduce services and system dependencies, but it is not a
universal substitute for native Apple Silicon environments. Python/R lockfiles
and a documented build remain necessary.

## Stage 3: data and backup

This stage needs a separate capacity and threat-model review.

Preliminary tiers:

| Class | Examples | Default handling |
| --- | --- | --- |
| A: source | Code, text, LaTeX, small configs | GitHub Git |
| B: reference | Papers, Zotero metadata, notes | Managed library plus backup |
| C: reproducible data | Downloadable/raw public inputs | Manifest + retrieval script; local storage |
| D: irreplaceable data | Measurements, annotations, manual outputs | At least two verified copies |
| E: confidential | Restricted human or partner data | Encrypted, access-controlled locations only |

Neither a second Mac, GitHub, iCloud sync, nor a single external disk alone
constitutes a complete backup. Colony9 must not become both the primary bulk
store and the only backup of that store.

Git LFS stores pointer files in Git and large objects separately. It is useful
for selected versioned binary assets, but GitHub Free's current 10 GiB storage
and bandwidth allowances make it unsuitable for the main research-data corpus.

## Decisions needed before Stage 1 installation

1. Approve or reject Tailscale as the private-network layer.
2. State whether either Mac uses another VPN, endpoint-security product, or
   institution-managed network profile that might conflict with it.
3. Run the audit script on MotokoKusanagi and return its output.
4. Decide which existing BigBlue SSH key, if any, is the current GitHub key;
   otherwise create a clearly named new one.
