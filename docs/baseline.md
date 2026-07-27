# Baseline

Date: 2026-07-27

## BigBlue

| Area | Observed state |
| --- | --- |
| Hardware | Apple M1, 16 GB memory |
| Operating system | macOS Ventura 13.7.8 |
| Root filesystem | 460 GiB volume, about 279 GiB available |
| Developer tools | Git, OpenSSH, Homebrew, VS Code CLI, Python, Rust, Cargo, R |
| Git | Global name and email configured; default branch is `main` |
| SSH client | OpenSSH 9.0 |
| SSH identities | Several Ed25519 key pairs exist; purpose is not yet catalogued |
| SSH server | Launch service appears enabled; an end-to-end login test remains |
| Docker CLI | Not found |
| Time Machine | No destination configured |
| Workshop | 13 top-level entries under `~/workshop`, approximately 27 GB |
| Private network | Joined Tailscale as `bigblue`; address `100.76.102.41` |

No private-key contents, identity values, or project contents were read during
this audit.

## User-provided inventory

| Asset | Description |
| --- | --- |
| MotokoKusanagi | Main machine; M1 Pro, 16 GB, macOS 14.6.1 |
| iCloud+ | 200 GB tier; approximately 121 GB free |
| Colony9 | WD Elements, 2 TB; approximately 1 TB free |
| MotokoKusanagi workshop | Approximately 140 GB including compressed files |
| Languages/tools | Python, Rust, C, R, LaTeX, VS Code, Zotero, Obsidian, Docker |
| GitHub | Mix of public and private repositories |
| Shared servers | User home directory, no administrator access |
| Data sensitivity | Some projects contain confidential data |
| Preferred workflow | Explicit Git push/pull |

## MotokoKusanagi

Audit date: 2026-07-27

| Area | Observed state |
| --- | --- |
| Hardware | Apple M1 Pro, 16 GB memory |
| Operating system | macOS Sonoma 14.6.1 |
| Root filesystem | 460 GiB volume, approximately 163 GiB available |
| Developer tools | Git, OpenSSH, Homebrew, VS Code CLI, Docker, Python, Rust, Cargo, R |
| Git | Global name and email configured; default branch is `main` |
| SSH client | OpenSSH 9.7 |
| SSH identities | Same set of filenames as BigBlue; actual identity relationship is not yet established |
| SSH server | Launch service appears enabled; an end-to-end login test remains |
| Time Machine | Destination is not working or not configured |
| Workshop | 47 top-level entries under `~/workshop`, approximately 133 GB |
| Private network | Joined Tailscale as `motokokusanagi`; address `100.70.32.124` |

The matching SSH filenames on the two Macs do not prove that the keys are
distinct. Their public-key fingerprints must be compared before choosing or
replacing identities; private keys must not be copied between machines.

Fingerprint comparison established that each Mac's default `id_ed25519` is
unique, but the three additionally named Ed25519 identities are identical on
both machines and were therefore copied. They must not be used as the
machine-to-machine identity. MotokoKusanagi's unique default public key
(`SHA256:tbt/BuwiurQZrnnlHIANWTg961BfBsFvXqGr75mX+A0`) is already present in
BigBlue's `authorized_keys`.

MotokoKusanagi previously had an unintended Git repository rooted at
`~/workshop`, connected to `phononautomata/flows`. It contained one commit
tracking two nested files, one tracked modification, and approximately 256 MB
of mostly dangling objects. On 2026-07-27, its complete `.git` directory and
diagnostic metadata were reversibly moved to:

```text
~/workshop-metadata-archive/workshop-parent-git-20260727T135404Z
```

Nested project repositories and workshop files remained in place.

## Immediate risks and unknowns

1. Neither Mac has a verified working Time Machine destination.
2. Colony9's filesystem, encryption state, health, and backup role are unknown.
3. Existing SSH keys are not labelled by purpose in a machine-readable config.
4. The two workshops differ substantially (27 GB versus 133 GB); their project
   and repository overlap has not been inventoried.
5. Remote access has not been tested from outside the home network.
6. Confidential-data rules need a per-project classification before any data
   synchronization is enabled.

## Connectivity verification

On 2026-07-27, BigBlue successfully reached MotokoKusanagi through Tailscale.
The first probe used Tailscale's Madrid relay while the peers negotiated; the
next probe established a direct local peer-to-peer path. No router
port-forwarding was configured.

## Git synchronization verification

On 2026-07-27, BigBlue initialized and pushed the canonical setup repository to
the private GitHub repository `phononautomata/setup`. MotokoKusanagi then cloned
that repository into `~/workshop/setup`, replacing the earlier manual-copy
workflow with explicit Git push/pull synchronization.

The `nagare` pilot was reconciled on 2026-07-27. BigBlue's clean `main` branch
was a strict ancestor of MotokoKusanagi by two commits and was safely
fast-forwarded through GitHub to `6774e565`. Both repositories were clean and
aligned afterward. File comparison showed that most directory asymmetry came
from machine-local Python environments and Rust build outputs; research data,
results, and caches remain deliberately unreconciled pending classification.
