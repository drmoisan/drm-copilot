# Coverage Delta (Issue #396)

Timestamp: 2026-07-22T09-01

Command:

```
gh run download 29922832766 --name shell-coverage --dir artifacts/pester/kcov-ci
grep -oE 'line-rate="[0-9.]+"' artifacts/pester/kcov-ci/cov.xml   # overall + per class
```

EXIT_CODE: 0

Source run: https://github.com/drmoisan/drm-copilot/actions/runs/29922832766 (green)

## Overall Coverage (line)

| Metric | Value |
|---|---|
| Baseline overall (P0-T3, run 29918840204) | 88.2% |
| Post-change overall (P7-T3, run 29922832766) | 89.0% |
| No-regression check | PASS (89.0% >= 88.2% baseline; >= 85% threshold) |

## Per-File Line Coverage (new production files)

| File | Line coverage | >= 85% |
|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 100.0% | PASS |
| `scripts/bash/cleanup_worktrees_lib.sh` | 88.5% | PASS |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 89.8% | PASS |

Values are the Cobertura `line-rate` attributes from the merged `cov.xml`
(`artifacts/pester/kcov-ci/cov.xml`), expressed as percentages.

## Outcome

PASS. Overall line coverage is 89.0% (>= 85% and not regressed below the 88.2%
baseline), and each of the three new production files is >= 85% line coverage. Branch
coverage is not applicable for bash (kcov reports line coverage only, per
`.claude/rules/shell.md`); there is no bash branch-coverage gate.
