# Daily operations

The finished workflow must remain usable without an AI agent. Every routine
operation should be a documented command or a small reviewable script built on
standard tools.

## Separate the jobs

| Job | Tool | Purpose |
| --- | --- | --- |
| Source history | Git + GitHub | Versioned code, text, configuration, manuscripts |
| Private connectivity | Tailscale + SSH | Reach a machine without exposing router ports |
| Deliberate transfer | `rsync` over SSH | Copy large or unversioned trees on demand |
| Local recovery | Time Machine | Recover earlier versions and deleted local files |
| Data integrity | SHA-256 manifests | Detect incomplete or corrupted copies |
| Reproducibility | Lockfiles, containers, scripts | Recreate software environments and outputs |

Synchronization and backup are not synonyms. A synchronized deletion can
quickly propagate to every connected machine; a backup must preserve a
recoverable earlier state.

## Safety contract for transfer tooling

The transfer wrapper developed for this repository will:

1. preview by default;
2. require an explicit apply flag before copying;
3. never enable deletion by default;
4. distinguish push from pull in its command syntax;
5. preserve partial transfers for safe resumption when appropriate;
6. display the exact source and destination;
7. reject ambiguous or dangerous roots;
8. create a local operation log;
9. offer a separate verification step based on file metadata or checksums.

Confidential projects require an additional policy before transfer. Tailscale
encrypts data in transit, but it does not decide whether the destination is
authorized to store the data, encrypt the destination disk, or provide a
backup.

## Workshop inventory

Run the metadata-only inventory:

```sh
./scripts/inventory-workshop.sh
```

It reports top-level names, sizes, Git state, sanitized remote location,
archive counts, and counts of files larger than 100 MiB. It does not read file
contents or modify projects.
