# Remediation Inputs: epic-852-main-sync (issue #852)

- Timestamp: 2026-10-11T00-49
- Source artifacts:
  - `docs/features/active/epic-852-main-sync/policy-audit.2026-10-11T00-49.md`
  - `docs/features/active/epic-852-main-sync/code-review.2026-10-11T00-49.md`
  - `docs/features/active/epic-852-main-sync/feature-audit.2026-10-11T00-49.md`
- Blocking findings: 3

## Context

The full branch diff against `origin/epic/enforcement-hook-precision-integration` (`8ee1b76e6..e0cbb9bc9`, 1,559 paths) includes TypeScript, Python, and bash files that arrived through the merge of `origin/main` (`daa6436cd`). The feature-review coverage procedure requires a coverage artifact for every language with changed files. Only the PowerShell artifact is present; it passes (90.43% repo line, changed files 98.62% and 100.00%). The branch-authored code changes need no remediation.

## Remediation-Required Findings

### RT-1 (blocking): TypeScript coverage artifact absent

- Finding: `coverage/lcov.info` does not exist in the workspace; 34 production `.ts` files under `extensions/drm-copilot/src/` changed on the branch.
- Required action: run the repository TypeScript coverage command on the merged tree (Jest with lcov reporter for `extensions/drm-copilot`) and place or copy the lcov output at `coverage/lcov.info`; record repo-wide line and branch percentages and per-file figures for the changed production files in `docs/features/active/epic-852-main-sync/evidence/qa-gates/`.
- Pass condition: repo-wide line >= 85% and branch >= 75%; each changed production file line >= 85% and branch >= 75% or no regression against `main`.

### RT-2 (blocking): Python coverage artifact absent

- Finding: `artifacts/python/lcov.info` does not exist in the workspace; 13 production `.py` files under `scripts/dev_tools/` changed on the branch.
- Required action: run the repository pytest coverage command on the merged tree with lcov output at `artifacts/python/lcov.info` (use an explicit package/directory `--cov` target, not a single `.py` path, which measures nothing); record figures in `evidence/qa-gates/`.
- Pass condition: repo-wide line >= 85% and branch >= 75%; each changed production file at or above threshold.

### RT-3 (blocking): bash coverage artifact absent

- Finding: `artifacts/pester/kcov/cov.xml` does not exist in the workspace; 16 `.sh` files (e.g. `.claude/lib/bash/parallel-mutation.sh`, `.claude/lib/bash/remove-parallel-item.sh`, `scripts/bash/shell_qc_lib.sh`) changed on the branch.
- Required action: run `scripts/bash/shell-qc.sh test --coverage` (kcov) on the merged tree, or attach the Cobertura `cov.xml` from the PR CI `_shell-coverage.yml` run for head `e0cbb9bc9` or later, and record the line percentage in `evidence/qa-gates/`. Local worktree hooks may deny `bash`/`wsl`; the CI artifact is an acceptable source if it is for the current head.
- Pass condition: line coverage >= 85% (no branch threshold for bash).

## Non-Blocking Observations (no remediation required)

- Code review Info items 1-3 (guard ordering comment, duplicated `-ForEach` tables, `-MockWith` restore pattern).

## Assumptions

- The TypeScript, Python, and bash content is byte-identical to `origin/main` and passed `main`'s CI; the findings are evidence gaps under the review procedure, not observed coverage regressions.
- No branch-authored source change is expected from this remediation; it is evidence production only.
