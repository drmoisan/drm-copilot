# Coverage Delta — Issue #357

Timestamp: 2026-07-17T10:57 (local, America/New_York; workstation clock)

## Source Artifacts
- Baseline: `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/baseline/poshqc-test-baseline.md`
- Post-change: `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/qa-gates/poshqc-test-final.md`

## Aggregate Coverage (`.claude/hooks/validate-planner-output.ps1`, ad hoc per-file Pester measurement)

| Metric | Baseline | Post-change | Delta |
|---|---|---|---|
| Line/command coverage | 69.87% (109/156) | 69.87% (109/156) | 0.00 pp — no regression |
| Branch coverage | Not emitted by Pester 5.6.1's coverage engine (no `BRANCH` counter produced) | Same (not emitted) | Not applicable to this toolchain for any file |

Note on branch coverage: Pester's built-in code-coverage engine reports command/line coverage only; it does not compute a distinct branch metric, confirmed identically in the baseline and post-change ad hoc runs and in the repository's own aggregate `artifacts/pester/powershell-coverage.xml`. This is a pre-existing tooling characteristic, not a change introduced by this fix.

Note on scope: the shared `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` `CodeCoverage.Path` allowlist does not include `.claude/hooks/validate-planner-output.ps1`. Modifying that shared settings file is outside this plan's 2-file change budget (`.claude/hooks/validate-planner-output.ps1` and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` only), so the numbers above were obtained via an ad hoc `Invoke-Pester -CodeCoverage` measurement that reads the same production/test files without modifying any repository file, applied identically at baseline and post-change for a valid comparison.

## Coverage of the Two Edited Regex/Message Lines and the Docstring Line

| File / Line | Content | Baseline | Post-change |
|---|---|---|---|
| `.claude/hooks/validate-planner-output.ps1:121` | `$phasePattern = '^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$'` (regex, fixed in P2-T1) | Executed/covered (unconditional assignment) | Executed/covered — unchanged |
| `.claude/hooks/validate-planner-output.ps1:137` | `$errors.Add("Line ${lineNumber}: phase heading must match ...")` (error message, fixed in P2-T2) | Not covered (no fixture exercises the malformed-phase-heading branch) | Not covered — unchanged; the new Phase 1 regression test exercises only the passing em-dash path, not the malformed-heading error branch, so this line's coverage status is unaffected by the fix |
| `.claude/hooks/validate-planner-output.ps1:17` | `.DESCRIPTION` comment-based-help text (fixed in P2-T3) | Not an executable statement; outside the coverage tool's analyzed-command set at baseline | Not an executable statement; outside the coverage tool's analyzed-command set post-change — no change in coverage status (comment-only lines are not measured by this coverage tool, consistent with `general-unit-test.md`'s allowance for non-executable content) |

## Confirmation of No Regression

- Total analyzed commands (156) and total executed commands (109) are identical at baseline and post-change for `.claude/hooks/validate-planner-output.ps1`; the set of 47 uncovered line numbers is byte-identical between the two runs.
- `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` has no dedicated coverage target under the shared runsettings (it is a test file, excluded from coverage measurement per `general-unit-test.md`'s Coverage Exclusion Policy, which permits excluding `tests/**`).
- No regression on changed lines: both edited lines (121, 137) retain their pre-fix coverage status; line 121 was and remains covered, line 137 was and remains uncovered (no test in scope targets that branch), and the docstring line (17) is non-executable and outside the measured set in both runs.
