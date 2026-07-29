# Warehouse follow-up migration preview

Status: partially implemented, 2026-07-29.

- Private GitHub repository `phononautomata/warehouse-followup` was created.
- Local Motoko `batch` commits `dffe9db` and `ade6486` establish the
  reproducibility boundary and checkpoint the follow-up source.
- The repository has not been added as a Motoko remote and nothing has been
  pushed to it; approval for that remote change was declined.
- Notebook changes remain untouched and uncommitted.

## Why separate it

The existing `phononautomata/warehouse` repository is public and represents a
completed publication. Its default `main` branch is clean at `801854c`, tagged
`v1.0-pre-submission-4`.

The local `batch` branch is a distinct follow-up research line:

```text
801854c  public reproducibility release; merge base with main
   |
6e52e15  empirical event-wave inference scaffold; already public on origin/batch
   |
04aba5e  baseline bout-clearance simulation model; local only
   |
33134f9  config-driven bout-clearance runner; local only
```

The exact history is already suitable for reuse. No subtree extraction,
rebasing, or copying into a historyless directory is necessary. A new private
remote can receive `batch` as its initial `main` while retaining attribution
and the relationship to the published project.

## Current uncommitted follow-up state

Tracked modifications include:

- bout-clearance configuration;
- simulation core, ensemble, observable, and parameter modules;
- wave analysis;
- analysis notebooks;
- deletion of the older `notebooks/analysis.ipynb`.

Untracked research material includes:

- follow-up configurations;
- simulation and diagnostic scripts;
- manuscript and research notes;
- four follow-up notebooks;
- generated outputs under `output/batch`, `output/flow_structure`, and
  `output/simulations`.

The generated output trees total approximately 23 MB. Their size is modest,
but they remain derived state and should be recreated from configurations and
scripts rather than committed by default.

## Proposed classification

### Commit candidates

- `src/**/*.py`, excluding bytecode caches;
- `scripts/*.py` and deliberate launcher scripts;
- `config/*.json`;
- manuscript source such as `docs/*.tex`, `docs/*.bib`, and research notes;
- selected notebooks after checking for embedded large, private, or
  machine-specific outputs;
- a project README describing the follow-up question and its relationship to
  the published Warehouse paper.

### Exclude as generated

- `output/batch/`;
- `output/flow_structure/`;
- `output/simulations/`;
- `**/__pycache__/` and `*.pyc`;
- LaTeX build products such as `*.aux`, `*.log`, and `*.out`.

### Hold for individual review

- `docs/warehouse_pre.pdf`;
- `docs/manuscript.pdf`;
- `docs/1-s2.0-S0378437106000902-main.pdf`;
- `docs/buffer.pdf`;
- notebooks with embedded outputs;
- `CLAUDE.md`, whose intended long-term role should be decided before commit.

PDFs must not be added merely because they are small. One filename appears to
be a third-party article, and manuscript PDFs are reproducible build products
unless there is an explicit reason to version them.

## Proposed migration sequence

The sequence below records the intended process. Steps through local source
checkpointing are complete; remote attachment and push remain pending.

1. Review notebook output metadata and the held PDF provenance.
2. Extend `.gitignore` for the three generated follow-up output trees and
   document how each can be regenerated.
3. Commit ignore/reproducibility policy separately.
4. Commit source, configurations, and tests as one or more coherent units.
5. Commit reviewed manuscript sources and notebooks separately.
6. Run the available smoke tests or add a minimal one.
7. Create an empty private GitHub repository:

   ```sh
   gh repo create phononautomata/warehouse-followup --private
   ```

8. Add it as a second remote without altering the public origin:

   ```sh
   git remote add followup \
     git@github.com:phononautomata/warehouse-followup.git
   ```

9. Push the follow-up lineage as the private repository's `main`:

   ```sh
   git push -u followup batch:main
   ```

10. Clone the private repository on BigBlue, recreate its environment, and run
    the same smoke test before treating the migration as complete.

## Safety properties

- The public `warehouse/main` branch remains unchanged.
- The current public `origin/batch` is not advanced accidentally.
- Existing Git history and publication provenance are retained.
- Generated outputs remain local and reproducible.
- The new work gains a private off-machine Git history before further
  development.
- The original Motoko directory is retained until the private clone and test
  succeed.
