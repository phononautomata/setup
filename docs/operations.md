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

## Migration direction

During initial harmonization, MotokoKusanagi is authoritative for projects that
also exist on BigBlue. Transfer tooling must therefore default to:

```text
MotokoKusanagi -> BigBlue
```

This is a migration rule, not a permanent synchronization design. Existing
BigBlue copies are retained until comparison and verification complete. A
project is never selected by modification timestamps alone, and a directory is
never mirrored wholesale merely because its name matches on both machines.

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

The workshop root should not normally be a Git repository when its child
projects are independent repositories. The inventory reports this condition
explicitly because a parent repository can accidentally track child project
files and make repository boundaries ambiguous.

## Active-project safety

Run a filename-free Git safety report across all workshop repositories:

```sh
./scripts/audit-project-safety.sh
```

Or inspect only selected projects:

```sh
./scripts/audit-project-safety.sh \
  bundles fisheries inditex lifestyles metagillespie scenarios sealog sf_dt
```

The report counts staged, unstaged, and untracked paths and shows the configured
upstream plus the locally known ahead/behind relationship. It does not fetch,
modify repositories, or reveal filenames. Ahead/behind values therefore use
the last fetched remote state; fetch an individual repository before making a
final synchronization decision.

### Retiring an unintended parent repository

Preview the archival operation:

```sh
./scripts/archive-workshop-parent-git.sh
```

Apply it only after reviewing the resolved paths:

```sh
./scripts/archive-workshop-parent-git.sh --apply
```

The script moves only `~/workshop/.git` into a timestamped directory beneath
`~/workshop-metadata-archive`. Before moving it, the script records the remote,
history, tracked tree, tracked status, object summary, and a binary patch of
uncommitted tracked changes. Project files and nested repositories remain in
place. The complete original Git metadata is retained for recovery.

## Comparing shared project histories

From MotokoKusanagi, compare same-named Git repositories over SSH:

```sh
./scripts/compare-shared-projects.sh
```

The script reports branches, commit IDs, dirty state, and whether origins
match. It reads repository metadata only. It does not fetch, merge, copy, or
modify either machine. Run this comparison before any data transfer into an
existing project directory.

## Comparing project files

After Git histories are aligned, preview unversioned and ignored-file
differences from MotokoKusanagi:

```sh
./scripts/compare-project-files.sh PROJECT
```

This wrapper is permanently dry-run. Its normal research-state view excludes:

- Git-tracked files, which are reconciled through Git;
- `.git` and `.DS_Store`;
- Python virtual environments and bytecode caches;
- Rust `target` directories;
- common test, type-checker, and linter caches.

Use `--full` for a forensic comparison containing those paths:

```sh
./scripts/compare-project-files.sh --full PROJECT
```

`deleting` markers mean a path exists only on BigBlue; they are displayed to
make asymmetry visible, but the script cannot delete them. Do not interpret
either preview as authorization to mirror the whole project.

## Adding a project subtree to BigBlue

Preview a named subtree from MotokoKusanagi:

```sh
./scripts/push-project-subtree.sh PROJECT RELATIVE_SUBTREE
```

Apply the reviewed transfer:

```sh
./scripts/push-project-subtree.sh --apply PROJECT RELATIVE_SUBTREE
```

The policy is deliberately conservative:

- copy only files that do not already exist on BigBlue;
- never overwrite an existing destination file;
- never delete anything;
- never transfer `.DS_Store`;
- reject absolute paths and parent-directory traversal;
- record every preview and applied run under
  `~/workshop-transfer-logs`.

This creates a safe union, not a fully harmonized mirror. Same-path conflicts
must be compared and resolved separately. Do not apply a transfer until the
subtree's confidentiality and destination authorization are understood.
