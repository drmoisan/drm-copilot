# Baseline — bash line coverage (plan task P0-T5)

Timestamp: 2026-09-08T00-55
Tree state: branch `bug/cleanup-worktrees-dirt-classifier-632-r2` at HEAD
`4ffe680ebcebaabbba10faaa490e46a717686535`.

## Route taken (recorded per EA-1 and EA-4)

`kcov` has no local route in this environment, so coverage is capturable only
through a CI dispatch. This is the same run that produced the P0-T4 bats baseline;
`shell-qc test --coverage` runs the suite under `kcov` and prints the summary line.

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`
Run id: 34174142684
Run: <https://github.com/drmoisan/drm-copilot/actions/runs/34174142684>
headSha: `4ffe680ebcebaabbba10faaa490e46a717686535`
Conclusion: `success`
EXIT_CODE: 0

## Output Summary

Baseline bash line coverage: **93.5**

Read verbatim from the run log's `Bash coverage (lines):` line, emitted by
`scripts/bash/shell_qc_lib.sh`. The captured literal was
`Bash coverage (lines): 93.5%`.

No branch-coverage number is recorded. `kcov` prints none, and
`.claude/rules/quality-tiers.md` exempts bash from the branch-coverage threshold
for exactly that reason. The line threshold of 85% still applies and 93.5% clears
it with 8.5 points of margin.

## Note on the parent-supplied reference figure

The kickoff prompt cited 94.2% at integration commit `6dff80ed`. That figure is
superseded and was not reused. The re-captured figure at this run's actual base is
93.5%, so coverage fell 0.7 points across the intervening merge of issue 631.
Both figures clear the 85% floor. The post-change figure in Phase 7 must be
compared against 93.5, not against 94.2.

## Verdict

Coverage baseline is 93.5% line coverage, above the 85% floor.
