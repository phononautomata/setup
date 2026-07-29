# Research workstation setup

This repository documents and automates a reproducible research workflow across:

- **BigBlue** — Mac mini, M1, 16 GB, macOS Ventura 13.7.8
- **MotokoKusanagi** — MacBook Pro, M1 Pro, 16 GB, macOS Sonoma 14.6.1
- **Colony9** — 2 TB WD Elements external drive
- GitHub and shared SSH servers

The first milestone is dependable communication and a deliberate Git push/pull
workflow between the two Macs. Bulk-data storage and synchronization are a
separate milestone because research data needs different safety and capacity
rules from source code.

Start with the [whole-ecosystem map](docs/ecosystem.md).

## Working principles

1. GitHub is the canonical remote for code, manuscripts, and configuration.
2. Each machine has its own SSH identity; private keys are never copied.
3. Generated, raw, confidential, and bulky data do not enter Git by default.
4. BigBlue may be an always-on private endpoint, but it is not a backup by
   itself.
5. Shared servers are compute targets, not synchronization hubs or assumed
   backup locations.
6. Automation begins read-only and becomes mutating only after review.

## Current status

The initial BigBlue audit is captured in [docs/baseline.md](docs/baseline.md).
The proposed first-stage design and decisions are in
[docs/architecture.md](docs/architecture.md).
Routine, non-agentic workflows are specified in
[docs/operations.md](docs/operations.md).
Per-project reconciliation decisions are tracked in
[docs/project-migration.md](docs/project-migration.md).
Backup risks and the staged recovery design are in
[docs/backup-plan.md](docs/backup-plan.md).
The shared coding baseline and per-language conventions are in
[docs/development-environments.md](docs/development-environments.md).
The verified versions and brief purpose of each maintained tool are in
[docs/tooling-inventory.md](docs/tooling-inventory.md).

Run the non-destructive audit on either Mac:

```sh
./scripts/audit-mac.sh
```

The script reports configuration metadata but never prints private keys, public
key contents, Git identity values, tokens, or project file contents.

Compare SSH identity fingerprints between Macs without exposing key material:

```sh
./scripts/ssh-fingerprints.sh
```
