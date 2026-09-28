# Coverage Comparison Against Baseline — [P4-T5]

Timestamp: 2026-08-26T06-32

Task: [P4-T5]
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`
Baseline source: `evidence/baseline/baseline-poshqc-test.2026-08-26T05-28.md` ([P0-T5])
Post-change source: `evidence/qa-gates/qc-poshqc-test.2026-08-26T06-32.md` ([P4-T3])

Both sets of figures were read from `artifacts/pester/powershell-coverage.xml` in JaCoCo form, written
by the respective PoshQC test run. `artifacts/` is gitignored, so the XML is not committed and its
numeric contents are transcribed. No placeholder appears in this artifact.

## The Five Required Numeric Values

| # | Value | Number |
| --- | --- | --- |
| 1 | Baseline overall line coverage, from [P0-T5] | **96.14 %** |
| 2 | Post-change overall line coverage, from [P4-T3] | **96.15 %** |
| 3 | Baseline per-file line coverage, `.claude/hooks/enforce-prd-feature-before-planner.ps1` | **90.32 %** |
| 4 | Post-change per-file line coverage, same file | **91.35 %** |
| 5 | Line coverage of the lines changed by this plan | **100.00 %** |

## Overall Line Coverage

| Metric | Baseline ([P0-T5]) | Post-change ([P4-T3]) | Delta |
| --- | --- | --- | --- |
| Lines covered | 6656 | 6667 | +11 |
| Lines missed | 267 | 267 | 0 |
| Lines total | 6923 | 6934 | +11 |
| **Line coverage** | **96.14 %** | **96.15 %** | **+0.01 pp** |

The denominator grew by 11 analyzable lines and the covered count grew by the same 11, so the missed
count is unchanged at 267. Every analyzable line this change added is covered.

**The post-change overall figure of 96.15 % is at or above the 85 percent threshold.** It exceeds it
by 11.15 percentage points, and it is also above the baseline, so there is no overall regression.

## Per-File Line Coverage for the Changed Hook

| Metric | Baseline ([P0-T5]) | Post-change ([P4-T3]) | Delta |
| --- | --- | --- | --- |
| Lines covered | 84 | 95 | +11 |
| Lines missed | 9 | 9 | 0 |
| Lines total (analyzable) | 93 | 104 | +11 |
| **Line coverage** | **90.32 %** | **91.35 %** | **+1.03 pp** |

All 11 analyzable lines added to the hook are covered, and the missed count is unchanged at 9. The
per-file figure of 91.35 % is above the 85 percent threshold and above its own baseline.

The same nine lines are missed before and after: numbers 206, 207, 210, 213, 214, and 216 are the
file-reading body of `Get-PrdFeatureCheckpointFolder`, and 443, 445, and 447 are the entry-point
statements below the dot-source guard that tests bypass by design. None is a line this change touched.

## Changed-Line Coverage

The changed-line figure was computed rather than asserted. The post-image line numbers changed by this
plan were taken from `git diff -U0 96ba4e37 HEAD -- .claude/hooks/enforce-prd-feature-before-planner.ps1`
and intersected with the per-line coverage records in the JaCoCo `sourcefile` element for that file.

| Metric | Value |
| --- | --- |
| Changed post-image lines in the diff | 128 |
| Of those, lines Pester treats as analyzable | 24 |
| Analyzable changed lines **covered** | **24** |
| Analyzable changed lines **missed** | **0** |
| **Changed-line coverage** | **100.00 %** |

The missed-line-number list for the changed set is empty. The gap between 128 changed lines and 24
analyzable ones is expected: the majority of the diff is comment-based help rewritten by [P2-T6] and
the rationale comments on the new indeterminate-marker branch, and a comment carries no executable
instruction for Pester to instrument.

## Explicit Verdicts

- **The post-change overall figure is at or above 85 percent.** 96.15 % against a threshold of 85 %.
- **The changed-line figure shows no regression against the baseline.** Changed-line coverage is
  100.00 %, which cannot regress against any baseline; equivalently, the missed-line count for the
  hook is 9 both before and after the change, so no line that was covered at baseline became uncovered,
  and every line the change introduced is covered.
- The per-file figure for the changed hook also rose, from 90.32 % to 91.35 %, and the overall figure
  rose from 96.14 % to 96.15 %. Neither metric regressed in either direction measured.

## Branch Coverage

**No branch-coverage threshold applies to PowerShell**, per `.claude/rules/quality-tiers.md`. Pester
does not measure branch coverage in any output format, so the threshold is unevaluable rather than
waived. That exemption is a capability limit on an unevaluable threshold and is not a licence to
exclude any file from measurement: under the Coverage Exclusion Policy in
`.claude/rules/general-unit-test.md`, PowerShell production files remain in the coverage denominator,
and no file was excluded from measurement by this change. `CodeCoverage.Path` in
`pester.runsettings.psd1` already lists the hook and needed no edit, because this change creates no
new production file.

Output Summary: Baseline overall line coverage 96.14 percent (6656 of 6923); post-change overall line
coverage 96.15 percent (6667 of 6934). Baseline per-file line coverage for
`.claude/hooks/enforce-prd-feature-before-planner.ps1` 90.32 percent (84 of 93, 9 missed);
post-change per-file line coverage 91.35 percent (95 of 104, 9 missed). Coverage of the lines changed
by this plan is 100.00 percent: of 128 changed post-image lines, 24 are analyzable and all 24 are
covered, with zero missed. The post-change overall figure of 96.15 percent is above the 85 percent
threshold, and the changed-line figure shows no regression against the baseline, the missed-line count
for the hook being 9 both before and after. No branch-coverage threshold applies to PowerShell per
`.claude/rules/quality-tiers.md`, because Pester does not measure branch coverage. No file was
excluded from coverage measurement.
