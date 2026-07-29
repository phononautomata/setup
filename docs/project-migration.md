# Project migration register

This register records per-project decisions during the initial
MotokoKusanagi-to-BigBlue harmonization. It prevents a bulk synchronization
rule from being applied to projects with different value, sensitivity, or
reproducibility.

| Project | Git state | Research-state policy | Status |
| --- | --- | --- | --- |
| `setup` | Both Macs aligned through GitHub | No bulk data | Active and verified |
| `nagare` | Both Macs clean at `6774e565` | Do not transfer data/results; retain existing copies until storage review | Inactive/cold |
| `netcom` | Same commit; dirty on both; no remote | Inspect working-tree differences | Pending |
| `securefood` | Same commit; dirty on both | Inspect working-tree differences and data sensitivity | Pending |
| `inditex` | Divergent commits; dirty on both | Preserve both states before reconciliation | Pending |
| `scenarios` | Divergent commits; dirty on both | Preserve both states before reconciliation | Pending |
| `sf_dt` | Motoko branch `dev_claude` pushed; BigBlue clean at `6686c65` | Clone code only; transfer data only when a task requires it | Active and available |

## Inactive projects

An inactive project is not automatically deleted or synchronized:

- keep its Git remote and committed history when available;
- do not replicate disposable environments, builds, caches, or results;
- do not consume backup capacity until the value of irreplaceable inputs is
  assessed;
- list large existing copies as cleanup candidates;
- delete only through a separate, explicit and recoverable cleanup decision.

For `nagare`, MotokoKusanagi was two commits ahead and authoritative. BigBlue
was safely fast-forwarded through GitHub. The subsequent file comparison showed
large, independent virtual environments, Rust builds, caches, raw transport
data, and result sets. Because the project is no longer active and the user
does not need the data, none of those unversioned trees will be transferred.

## Lightweight clone-first workflow

`sf_dt` established the normal path for an active project that exists only on
MotokoKusanagi:

1. confirm the Motoko working tree is clean;
2. push the active branch if it exists only locally;
3. clone or fetch that branch on BigBlue;
4. leave ignored data, environments, and build outputs behind;
5. retrieve or transfer a specific data subtree only when work requires it.

MotokoKusanagi's `dev_claude` branch was initially local-only. After it was
pushed to GitHub, BigBlue checked out a shallow copy at `6686c65`, tracking
`origin/dev_claude`. The BigBlue checkout was approximately 382 MB rather than
MotokoKusanagi's roughly 8 GB project directory.

## Active-project safety snapshot

Read-only audit date: 2026-07-29. Counts do not reveal filenames. Ahead/behind
values use locally cached remote references and are not a substitute for a
fresh fetch before synchronization.

| Project | Branch | Staged | Unstaged | Untracked | Upstream | Ahead/behind |
| --- | --- | ---: | ---: | ---: | --- | --- |
| `bundles` | `main` | 0 | 0 | 8 | none; no origin | — |
| `famitsu` | `main` | 0 | 1 | 4 | none; no origin | — |
| `fisheries` | `refactor/src-architecture` | 0 | 0 | 1 | `origin/refactor/src-architecture` | 0/0 |
| `inditex` | `main` | 0 | 2 | 7 | `origin/main` | 0/0 |
| `lifestyles` | `main` | 0 | 1 | 1 | `origin/main` | 0/0 |
| `metagillespie` | `main` | 0 | 5 | 3 | `origin/main` | 0/0 |
| `scenarios` | `main` | 0 | 1 | 2 | `origin/main` | 0/0 |
| `sealog` | `main` | 0 | 0 | 0 | none; no origin | — |
| `sf_dt` | `dev_claude` | 0 | 0 | 0 | `origin/dev_claude` | 0/0 |

Immediate interpretation:

- `sealog` and `sf_dt` are clean.
- No audited GitHub-backed project has a locally known unpushed commit.
- `inditex` and `metagillespie` have the largest counts of uncommitted paths
  among the recently active projects and deserve the first human review.
- `bundles`, `famitsu`, and `sealog` have no `origin`; decide whether each is a
  real project needing a private/public remote or merely a local collection.
- `fisheries` has only one untracked path, but its meaning must be reviewed
  before ignoring, committing, or removing it.
