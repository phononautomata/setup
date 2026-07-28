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

