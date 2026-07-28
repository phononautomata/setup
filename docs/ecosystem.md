# Research ecosystem

This is the top-level map of the two-Mac research environment. It describes
what is operational, which system owns each kind of information, how routine
work flows, and what remains unresolved.

## Components

```text
                         GitHub
                committed source and text
                       /          \
                      /            \
        MotokoKusanagi              BigBlue
        primary mobile Mac          always-on Mac mini
        100.70.32.124                100.76.102.41
                      \            /
                       \          /
                    Tailscale network
                  SSH, rsync, remote work

                            |
                         Colony9
                 existing exFAT archive disk
                  not yet a backup destination
```

### MotokoKusanagi

- Primary mobile workstation.
- M1 Pro, 16 GB, macOS 14.6.1.
- FileVault enabled.
- Tailscale and Remote Login enabled.
- Can initiate and receive SSH/`rsync`.
- Holds the most current initial-migration state for existing projects.

### BigBlue

- Always-available home workstation and compute/transfer endpoint.
- M1, 16 GB, macOS 13.7.8.
- FileVault enabled.
- System sleep disabled on AC power.
- Network wake and automatic restart after power failure enabled.
- Tailscale and Remote Login enabled.
- Can initiate and receive SSH/`rsync`.

### Colony9

- 2 TB USB external disk.
- exFAT and unencrypted.
- Approximately 900 GB used.
- SMART health is unavailable through macOS.
- Contains archives and the original irreplaceable photos/video.
- Must not be erased, reformatted, or assigned to Time Machine yet.

## Sources of truth

| Information | Source of truth |
| --- | --- |
| Committed code, text, and configuration | GitHub repository |
| Uncommitted work | Current working tree; temporary and at risk until committed |
| Public reproducible inputs | Upstream source plus retrieval script/checksum manifest |
| Machine-generated environments/builds | Lockfile or setup script, not copied directories |
| Irreplaceable personal media | Currently Colony9 plus checksum-verified BigBlue copy |
| Confidential research data | Approved encrypted location defined per project |
| Versioned machine recovery | Not established yet |

No Mac should become the permanent universal source of truth. During initial
project migration, MotokoKusanagi is authoritative; after reconciliation,
GitHub is authoritative for committed source.

## Daily code workflow

Before working:

```sh
git fetch origin
git merge --ff-only origin/BRANCH
git status
```

After a coherent unit of work:

```sh
git add PATHS
git commit
git push
```

On the other Mac:

```sh
git fetch origin
git merge --ff-only origin/BRANCH
```

For a project absent from a Mac:

```sh
git clone git@github.com:OWNER/PROJECT.git
```

Do not place a live Git repository inside generic file synchronization.

## Direct access and transfer

Interactive access:

```sh
# From MotokoKusanagi
ssh ademiguel@bigblue

# From BigBlue
ssh alfonso@motokokusanagi
```

Direct transfer:

```sh
rsync -avh --progress SOURCE/ USER@HOST:DESTINATION/
```

Safer repository tooling:

```sh
# Metadata-only machine inventory
./scripts/inventory-workshop.sh

# Compare Git state across same-named projects
./scripts/compare-shared-projects.sh

# Dry-run project file differences
./scripts/compare-project-files.sh PROJECT

# Preview, then add missing subtree files without overwrite or deletion
./scripts/push-project-subtree.sh PROJECT SUBTREE
./scripts/push-project-subtree.sh --apply PROJECT SUBTREE
```

Avoid `rsync --delete` during ordinary research transfers. Synchronization is
not backup.

## What is operational

- Private Tailscale connectivity between both Macs.
- SSH authentication in both directions using unique machine keys.
- Direct `rsync` capability in both directions.
- GitHub push/pull tested in both directions.
- Clone-first project availability demonstrated with `sf_dt`.
- BigBlue configured for unattended operation.
- FileVault enabled on both Macs.
- Irreplaceable Colony9 photos and video copied to BigBlue and verified by
  content checksum.
- Read-only inventory and conservative transfer scripts documented in Git.

## Important unresolved work

### 1. Versioned backup and disaster recovery — critical

Neither Mac has a Time Machine destination. The verified photos/video copies
are on separate disks but at the same physical location. There is no tested
off-site recovery path.

Colony9 cannot safely become a Time Machine disk until all its contents are
classified and every unique keeper has another verified copy. A backup is not
trusted until a sample restore succeeds.

### 2. Uncommitted active-project work — high

Several recent projects have dirty working trees. Changes that exist only in a
working tree are neither in GitHub nor recoverable through Time Machine.
Active work should be reviewed, committed in coherent units, and pushed.

### 3. Environment reproducibility — medium

Python, R, Rust, and container conventions are not yet standardized.
Virtual environments and build directories should be reproducible from
lockfiles and documented bootstrap commands on either Mac.

### 4. Data provenance and confidentiality — medium

Projects need small manifests stating where data comes from, whether it is
reproducible, whether it is confidential, and where it may be stored.

### 5. Maintenance and recovery drills — medium

The ecosystem still needs periodic checks for:

- successful backups and sample restores;
- free disk capacity;
- unpushed commits and long-lived dirty trees;
- Tailscale/SSH availability;
- operating-system and tool updates;
- recovery keys stored outside the protected device.

## Practical assessment

The networking and daily code workflow are functional now. Either Mac can be
used for a Git-backed project, either can reach the other, and BigBlue can act
as an unattended compute node.

The ecosystem is not yet robust against disk loss, theft, fire, or accidental
deletion because versioned and off-site backup remain incomplete. Backup is
the next infrastructure priority; active-project cleanup and environment
reproducibility can proceed alongside normal research work.

## Supporting documents

- [Architecture](architecture.md)
- [Machine baseline](baseline.md)
- [Daily operations](operations.md)
- [Project migration register](project-migration.md)
- [Backup plan](backup-plan.md)

