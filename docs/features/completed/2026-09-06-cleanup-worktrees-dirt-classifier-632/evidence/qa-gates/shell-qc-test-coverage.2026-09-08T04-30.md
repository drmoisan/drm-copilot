# Final QC — P7-T4 coverage and P7-T5 delta

Timestamp: 2026-09-08T04-30
Commit under test: `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
Run by: orchestrator (EA-4; `kcov` has no local route in this worktree, so the CI
dispatch is the only route, and per EA-1 it is canonical).

## P7-T4 — coverage stage

Command: `gh workflow run .github/workflows/_shell-coverage.yml --ref bug/cleanup-worktrees-dirt-classifier-632-r2`
Run id: 34182198357
Run: <https://github.com/drmoisan/drm-copilot/actions/runs/34182198357>
Event: `workflow_dispatch`
headSha: `ad6bc946bbf0ad9e69756b2155eae19771a232d8`
Conclusion: `success`
EXIT_CODE: 0

Output Summary:

- TAP plan line: `1..390`
- `ok` lines: 390
- `not ok` lines: 0
- `Bash coverage (lines): 92.9%`

The run printed a `Bash coverage (lines):` line, so this is a real measurement
rather than the silent-zero path where `print_coverage_summary` returns 0 having
printed nothing.

## P7-T5 — coverage delta

BaselineLineCoverage: 93.5
PostChangeLineCoverage: 92.9
Threshold: 85.0

The post-change repository-wide figure clears the 85.0 threshold with 7.9 points
of margin. It is 0.6 points below the baseline, which is the arithmetic effect of
adding a 425-line library whose own coverage is below the repository average
rather than a reduction in coverage of any pre-existing line.

### Per-file figures, read from the merged Cobertura report

Source: the `shell-coverage` artifact of run 34182198357,
`kcov-merged/cov.xml`, downloaded with `gh run download`. Per-file percentages
computed as covered lines over instrumented lines.

| File | Line coverage | Covered / instrumented |
|---|---|---|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | **82.63%** | 138 / 167 |
| `scripts/bash/cleanup_worktrees_scan_helper.sh` | 86.79% | 46 / 53 |
| `scripts/bash/cleanup_worktrees_report_records_lib.sh` | 89.01% | 162 / 182 |
| `scripts/bash/cleanup_worktrees_enumerate_lib.sh` | 92.13% | 82 / 89 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 94.08% | 159 / 169 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 95.41% | 187 / 196 |
| `scripts/bash/cleanup-worktrees.sh` | 97.44% | 38 / 39 |
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 100.00% | 103 / 103 |

The overall `line-rate` attribute on the report root is `0.929`, which agrees with
the headline the run log printed.

## P7-T5 acceptance is NOT met

The new classifier library is the lowest-covered file in the family at 82.63%,
and the plan's P7-T5 acceptance condition names two specific paths that must be
covered, stating that an uncovered line in either "is a finding requiring a new
scenario entry, not a waiver".

### The `CONTENT_IN_HISTORY` depth-fallback path is NOT covered

Uncovered lines in `cleanup_worktrees_dirt_lib.sh`, with content:

```
  95: 	out=$(cleanup_wt_git --no-optional-locks -C "$wt" rev-list \
  98: 		return 2
 113: 		if ((drc > 1)); then
 114: 			return 2
 117: 	return 1
```

Lines 113 and 114 are the depth-fallback hard-failure branch the acceptance
condition names: a `diff-index` exit above 1 must return 2, which the caller maps
to `UNIQUE`. Nothing executes it. Line 117, the ordinary "no candidate matched"
return, is also never executed.

### The full set of 29 uncovered lines

`74, 75, 76, 77, 95, 98, 113, 114, 117, 148, 151, 155, 160, 190, 191, 233, 234, 258, 259, 269, 270, 273, 274, 305, 308, 309, 343, 415, 416`

Grouped by what they are:

- **Fail-closed error branches** — `95`, `98` (rev-list read failure), `113`,
  `114` (diff-index hard failure), `148`, `151`, `155` (diff read failure),
  `305` (`log --find-object` read failure), `343` (staged-probe return
  propagation).
- **Fail-closed `UNIQUE` emissions** — `233`/`234`, `258`/`259`, `273`/`274`,
  `308`/`309`. Each is a `printf 'UNIQUE|'` plus `return 0` reached only when a
  classifier git read failed.
- **A success-path emission** — `269`/`270`, a `printf 'CONTENT_ON_MAIN|'` plus
  `return 0`. The ladder has two `CONTENT_ON_MAIN` emission sites and only one is
  exercised.
- **Ordinary non-error returns** — `117` (no staged-tree candidate matched),
  `190`/`191` (the non-build-artifact filename fallthrough), `160` (a diff-line
  case arm).
- **A clear-failure record** — `415`/`416`, the `ACTION|dirt-clear|...|FAILED`
  emission.
- **A constant array** — `74` through `77`, the session-artifact path list.

### Why this is blocking rather than a rounding complaint

The concentration is the problem, not the percentage. The uncovered set is
almost exactly the fail-closed machinery: the branches that decide what happens
when a classifier git read fails. Fail-closed is the property that stops this
tool from reporting "safe to delete" about work that exists only in that
worktree, and the spec states it explicitly — any non-zero exit from any
classifier git read maps the entry to `UNIQUE`, which makes the worktree
`HAS_UNIQUE`, which refuses the clear.

AC-13 provides one `dirt_classifier_read_error` scenario, and it demonstrably
covers one of these sites rather than all of them. A read failure at any of the
other sites reaches a line no test has ever executed.

The direction of the residual risk is the dangerous one for this feature: if one
of those uncovered branches does not in fact return the fail-closed value, the
classifier reports a disposable verdict for an entry it could not read, and
`--clear-disposable` destroys it.

## Verdict

P7-T4 passes. **P7-T5 fails.** New scenario entries are required for the
uncovered fail-closed branches, per the acceptance condition's own instruction
that this is a finding rather than a waiver. P7-T8 cannot be declared while
P7-T5 is unmet.
