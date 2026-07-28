# Backup and availability plan

## Current state

| Asset | State | Consequence |
| --- | --- | --- |
| BigBlue internal disk | FileVault on; no Time Machine destination | Encrypted at rest, but no verified versioned external recovery |
| MotokoKusanagi internal disk | FileVault on; Time Machine not configured | Encrypted at rest, but no verified versioned external recovery |
| Colony9 | 2 TB exFAT; about 900 GB used and 1.1 TB free; unencrypted; SMART unavailable | Cannot be selected safely as a direct modern Time Machine volume without reformatting |
| GitHub | Active for selected code repositories | Good source history, not a backup of ignored data |
| iCloud+ | 200 GB tier with about 121 GB free | Useful availability layer for selected documents, insufficient for research corpus |

## Colony9 measured contents

Measured on 2026-07-28:

| Tree | Approximate size |
| --- | ---: |
| `audio` | 365 GB |
| `anime` | 236 GB |
| `workshop` | 153 GB |
| `photos` | 49 GB |
| `library` | 17 GB |
| `video` | 5.2 GB |
| `Documents` | 1.4 GB |
| `images` | 639 MB |

The media trees (`audio`, `anime`, and `video`) account for roughly 606 GB.
The likely personal/irreplaceable trees (`photos`, `Documents`, and `images`)
account for approximately 51 GB, subject to user classification. The
`workshop` and `library` trees require comparison with current sources before
they can be considered duplicate, reproducible, or archival.

The user subsequently classified `photos` (49 GB) and `video` (5.2 GB) as
irreplaceable personal material. On 2026-07-28, both trees were copied
additively from Colony9 to BigBlue's internal SSD under:

```text
~/Irreplaceable/Colony9/
```

Read-only `rsync` checksum comparisons with deletion simulation produced zero
differences for both trees. This establishes a verified second physical copy.
Neither source tree was changed or deleted. Both copies remain at the same
location and are not yet a complete disaster-recovery arrangement; an
encrypted off-site third copy remains required.

## Principles

1. Synchronization is not backup.
2. A second copy on another Mac improves availability but does not provide
   version history.
3. Two volumes on one physical disk still share one hardware-failure domain.
4. GitHub protects committed source, not ignored data, local environments, or
   unpushed work.
5. Confidential data requires encryption at rest as well as in transit.
6. A backup is not trusted until a sample restore has succeeded.

## Zero-cost interim state

Until Colony9 can be safely repurposed:

- keep active source committed and pushed to private or public GitHub
  repositories as appropriate;
- use iCloud for selected ordinary documents and notes, never as their only
  recovery mechanism;
- use previewed, add-only `rsync` for selected irreplaceable data copies
  between the Macs or onto Colony9;
- do not mirror disposable environments, caches, builds, or dead-project
  results;
- enable FileVault on both Macs after recovery credentials and backup
  readiness are confirmed;
- maintain an inventory of data that exists in only one place.

This is risk reduction, not a complete backup system.

## Proper target using Colony9

If Colony9's existing 900 GB is copied elsewhere, verified, or explicitly
retired, the clean target is:

1. erase and reformat Colony9 with GUID Partition Map and APFS;
2. use APFS Encrypted for backup/archive volumes;
3. dedicate most or all of the physical disk to Time Machine;
4. connect Colony9 to always-on BigBlue;
5. back up BigBlue directly;
6. share a separately limited Time Machine destination over SMB for
   MotokoKusanagi;
7. encrypt both Time Machine backup sets;
8. perform and document a sample file restore from each Mac.

Apple recommends a Time Machine disk with roughly twice the capacity of the
Mac being backed up. A 2 TB disk is a sensible minimum for two 500 GB Macs only
when it is primarily a backup disk; retaining a large general archive on it
reduces version history and leaves the archive without an independent copy.

## Cloud role

Cloud services complement local backup:

- GitHub: committed code and text history;
- iCloud: selected documents, notes, and device availability;
- institutional or project-approved storage: confidential or shared research
  data where policy permits.

No current cloud allocation is large enough to be the sole backup of the
research corpus, and file synchronization can propagate accidental deletions.

## Required decisions

1. Classify Colony9's `photos`, `workshop`, `library`, `video`, `audio`,
   `anime`, `images`, and `Documents` trees as keep, duplicate, or disposable.
2. Verify FileVault status on MotokoKusanagi.
3. Decide whether zero additional hardware cost is absolute or whether one
   dedicated backup disk is acceptable later.
4. Identify irreplaceable/confidential data that currently has only one copy.
