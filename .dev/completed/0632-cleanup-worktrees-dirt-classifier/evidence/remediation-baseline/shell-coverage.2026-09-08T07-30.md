# Phase 0 baseline — bash line coverage (from CI, not from any local invocation)

Timestamp: 2026-09-08T07-30
Task: [P0-T6]
CI run id: 34194469882
Workflow: Shell Coverage (reusable) — `.github/workflows/_shell-coverage.yml`
Conclusion: success
headSha: ea1baef8aad811c6c9d6d12e32c8ab05f636ecaa

Command: gh run view 34194469882 --repo drmoisan/drm-copilot --json databaseId,headSha,conclusion,status,workflowName
  then gh api repos/drmoisan/drm-copilot/actions/runs/34194469882/artifacts
  then gh api repos/drmoisan/drm-copilot/actions/artifacts/10043508097/zip
EXIT_CODE: 0

The figures below were re-derived in this task by parsing `kcov-merged/cov.xml` out of
artifact `10043508097` directly, rather than copied from a prior evidence artifact. The
per-file percentages are computed by counting `<line>` elements with `hits` greater than
zero against the total `<line>` count for each class, because the Cobertura `line-rate`
attribute on a `<class>` element is rounded to three decimal places and would report the
classifier library as `0.940` rather than `94.05%`.

## Headline figures

BaselineRepoLineCoverage: 93.7
BaselineDirtLibLineCoverage: 94.05
Threshold: 85.0

The report root carries `line-rate="0.937"`, `lines-covered="2164"`, `lines-valid="2310"`.
Recomputed, 2164 / 2310 = 93.68%, consistent with the rounded `93.7` recorded here as the
headline. Both headline values are at or above the 85.0 line threshold.

Branch coverage: not evaluated and no branch gate is asserted. kcov measures no branch
coverage for bash, so the 75% branch threshold does not apply per `.claude/rules/shell.md`
and `.claude/rules/quality-tiers.md`. That is a threshold exemption only; no bash
production file is excluded from measurement.

## Per-file table — the eight files matching `scripts/bash/cleanup[-_]worktrees*`

| File | Covered / total lines | Line coverage |
|---|---:|---:|
| `scripts/bash/cleanup-worktrees.sh` | 38 / 39 | 97.44% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 159 / 169 | 94.08% |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 103 / 103 | 100.00% |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 158 / 168 | 94.05% |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 82 / 89 | 92.13% |
| `scripts/bash/cleanup_worktrees_lib.sh` | 187 / 196 | 95.41% |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 162 / 182 | 89.01% |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 46 / 53 | 86.79% |

Eight rows. The glob is written `cleanup[-_]worktrees*` rather than
`cleanup_worktrees*` so that `cleanup-worktrees.sh`, which uses a hyphen, is included. It
is production bash inside kcov's `--include-pattern` (`shell_qc_lib.sh:335`) and it is the
file that arms `--clear-disposable`, so excluding it would leave a blind spot in the file
whose regression would be most consequential. All eight are at or above the 85.0 floor.

## No local coverage route

kcov has **no local route in this worktree**, so no coverage figure in this cycle may be
taken from a local invocation. Verified in this task rather than assumed:

- `command -v kcov` returns non-zero; no kcov binary is on PATH.
- `bash scripts/bash/shell-qc.sh test --coverage` **exits 127 here**, printing
  `bats not installed; cannot run shell tests with coverage.`
- Re-run with the resolved bats binary supplied through the documented seam,
  `env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test --coverage`
  **also exits 127**, printing `kcov not installed; cannot run shell tests with coverage.`
  followed by the missing-tool block. The second run establishes that the 127 is kcov's
  absence and not merely bats's.

Coverage for this cycle is therefore measurable only by a dispatch of
`.github/workflows/_shell-coverage.yml` against a pushed commit, with the numbers read from
that run's merged Cobertura artifact. No task in this plan asserts a local coverage figure.

Output Summary: Baseline read from CI run 34194469882 (success, headSha ea1baef8).
Repository-wide bash line coverage 93.7% (2164/2310); `cleanup_worktrees_dirt_lib.sh`
94.05% (158/168). All eight `cleanup[-_]worktrees*` files at or above the 85.0 threshold.
kcov confirmed absent locally; `test --coverage` exits 127 with and without a bats binary.
