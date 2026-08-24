# Final Shell Coverage via CI Dispatch (Issue #396)

Timestamp: 2026-07-22T09-01

Command:

```
git push origin drm-copilot-wt-2026-07-21T21-57
gh workflow run _shell-coverage.yml --ref drm-copilot-wt-2026-07-21T21-57
gh run watch 29922832766 --exit-status
gh run view 29922832766 --log | grep "Bash coverage (lines)"
```

EXIT_CODE: 0

Workflow run URL: https://github.com/drmoisan/drm-copilot/actions/runs/29922832766

bats pass/fail counts: TAP plan `1..80`; 80 passed; 0 failed (0 `not ok`). This includes
the 36 new cleanup-worktrees `@test` cases across the five new suites (enumeration 11,
classification 8, consolidation 6, deletion 6, CLI 5) plus the pre-existing shell-qc
suites.

Output Summary:

- Run conclusion: success (green) on `ubuntu-latest`.
- Bash coverage (lines): 89.0% (post-change).
- Baseline was 88.2% (P0-T3); post-change 89.0% — no regression (coverage increased).
- kcov measures line coverage only; no bash branch-coverage gate per `.claude/rules/shell.md`.

Remediation note: the first post-change dispatch (run 29922246766) was red because bats
`run` merges stderr into `$output` and the checked-in git stub logs its argv to stderr,
which contaminated the exact-equality/`${lines[N]}` assertions in the enumeration and
classification suites, and the CLI source-guard test's `set -e` propagation under kcov.
The fix (commit 4851f3c9) redirects the function stderr to /dev/null inside those
command strings and isolates the wrapper's `set -euo pipefail` in a subshell for the
source-guard test. The re-run (29922832766) is green. The production scripts were not
changed by the remediation, so the P7-T1 format and P7-T2 check results are unaffected;
both were re-run and remained EXIT_CODE 0 with no rewrites, satisfying the single-pass
loop rule for P7-T1..P7-T4.
