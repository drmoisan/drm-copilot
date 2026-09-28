# Baseline — bash line coverage, read from CI rather than from any local invocation

Timestamp: 2026-09-09T00-00

Task: [P0-T5]

## Why this figure is not measured locally

kcov has **no local route in this worktree**. `command -v kcov` resolves nothing, and
`run_test_coverage` (`scripts/bash/shell_qc_lib.sh:293-320`) preflights kcov before any test
runs, so the coverage stage aborts at that preflight.

Observed directly in this task:

Command: `env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test --coverage`
EXIT_CODE: 127

```
kcov not installed; cannot run shell tests with coverage.
Missing required tool: kcov
Devcontainer install (apt-get): apt-get update && apt-get install -y kcov
macOS (Homebrew): brew install kcov
Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y kcov
On Windows, use WSL for best results.
```

`bash scripts/bash/shell-qc.sh test --coverage` exits **127** here. The bats binary was
supplied through the `SHELL_QC_BATS_BIN` seam for this probe, so the 127 is attributable to
the kcov preflight and not to a missing bats. Coverage is measured only by a
`workflow_dispatch` of `.github/workflows/_shell-coverage.yml` against a pushed commit, and
the numbers below are read from that run's merged Cobertura artifact. **No locally derived
bash coverage figure is asserted anywhere in this plan.**

## Source run

Command: `gh api repos/drmoisan/drm-copilot/actions/runs/34229386300 --jq '{id, conclusion, head_sha, name}'`
EXIT_CODE: 0

```
{"conclusion":"success","head_sha":"7d7a661f88c082184a892e153922f22af43e6a40","id":34229386300,"name":"Shell Coverage (reusable)"}
```

Run id: **34229386300**. Conclusion `success`. headSha `7d7a661f88c082184a892e153922f22af43e6a40`.

The per-file and headline figures below were extracted from that run's `shell-coverage`
artifact by the cycle-2 exit reaudit, using these `gh` reads:

Command: `gh api repos/drmoisan/drm-copilot/actions/runs/34229386300/artifacts`
Command: `gh api repos/drmoisan/drm-copilot/actions/artifacts/10057356590/zip`
then parsing `kcov-merged/cov.xml`.

EXIT_CODE: 0

Artifact `shell-coverage`, id `10057356590`, 385025 bytes. The recorded figures are carried
from
`evidence/qa-gates/dirt-lib-coverage.2026-09-08T10-00.md` and
`evidence/qa-gates/coverage-delta.2026-09-08T10-00.md`, which record the same run id and the
same headSha that the `gh api` read above independently confirms in this task.

## Headline figures

BaselineRepoLineCoverage: 93.69
BaselineDirtLibLineCoverage: 94.12
Threshold: 85.0

Both headline figures are numbers and both are at or above the 85.0 uniform line threshold.
They were computed by counting `<line>` elements with non-zero `hits` against the total
`<line>` count, not by reading the rounded Cobertura `line-rate` attribute: the report root
carries `lines-covered="2166"` and `lines-valid="2312"`, and 2166 / 2312 = 93.69%. The
classifier library is 160 / 170 = 94.12%.

## Per-file table — the eight files matching `scripts/bash/cleanup[-_]worktrees*`

| File | Covered / total | Line coverage |
|---|---:|---:|
| `scripts/bash/cleanup-worktrees.sh` | 38 / 39 | 97.44% |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 159 / 169 | 94.08% |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 103 / 103 | 100.00% |
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 160 / 170 | 94.12% |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 82 / 89 | 92.13% |
| `scripts/bash/cleanup_worktrees_lib.sh` | 187 / 196 | 95.41% |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 162 / 182 | 89.01% |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 46 / 53 | 86.79% |

Eight rows, all eight files named. The glob is written `cleanup[-_]worktrees*` rather than
`cleanup_worktrees*` so that `cleanup-worktrees.sh`, which uses a hyphen, is included.

## Branch coverage

Not evaluated and no branch gate is asserted. kcov measures line coverage only for bash, so
the 75% branch threshold does not apply, per `.claude/rules/shell.md` and
`.claude/rules/quality-tiers.md`. That is a threshold exemption only: no bash production file
is excluded from measurement and all eight files above remain in the denominator.

Output Summary: repository-wide bash line coverage 93.69% (2166/2312) and
`scripts/bash/cleanup_worktrees_dirt_lib.sh` 94.12% (160/170), both above the 85.0 threshold,
from CI run 34229386300 at headSha `7d7a661f`. kcov has no local route in this worktree and
`bash scripts/bash/shell-qc.sh test --coverage` exits 127 here, observed in this task.
