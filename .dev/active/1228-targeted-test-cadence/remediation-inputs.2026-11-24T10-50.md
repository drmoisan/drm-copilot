# Remediation Inputs (Issue #1228), feature re-audit 2026-11-24T10-50

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: design

**Entry timestamp:** 2026-11-24T10-50
**Feature folder:** `.dev/active/1228-targeted-test-cadence`
**Base branch:** `main` (merge base `a4ebf96688106d9bcd0baf51d237a6b77c055560`)
**Head reviewed:** `4ac1f0be8688ddbd9c18a4de072d3f0095dc9cfd` on `feature/targeted-test-cadence-1228`
**Work mode:** `full-feature`; AC sources are `spec.md` and `user-story.md` (28 of 28 met as written)
**Finding count:** 1 (autonomous: 1)
**Supersedes:** `remediation-inputs.2026-11-24T07-15.md` (F1 and F2 resolved by commit `4ac1f0be8`)
**Target remediation plan:** `.dev/active/1228-targeted-test-cadence/remediation-plan.2026-11-24T10-50.md` (to be authored by `atomic-planner`)
**Audit artifacts:**
- `.dev/active/1228-targeted-test-cadence/policy-audit.2026-11-24T10-50.md`
- `.dev/active/1228-targeted-test-cadence/code-review.2026-11-24T10-50.md`
- `.dev/active/1228-targeted-test-cadence/feature-audit.2026-11-24T10-50.md`

## Findings

### F3 - Feature-review coverage Stop hook grades the selection-run report as the repo-wide figure

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a change to repository hook scripts, their Pester tests, the spec decision text, and the ledger on this branch; spec non-goal "no hook changes" is a design choice the owner's autonomous-mode rule lets the planner amend with a recorded decision, and no external system or CI result is needed.
Finding-Scope: design

Files: `.claude/hooks/validate-feature-review-coverage-metrics.ps1` (`Get-LanguageRepoCoverage`, `Get-JacocoRepoCoverage`, `Get-LcovRepoCoverage`), `.claude/hooks/validate-feature-review-coverage.ps1` (the `Test-LanguageCoverageRow` call at line 229), `.claude/hooks/validate-feature-review-coverage-freshness.ps1`, their bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, their tests under `tests/scripts/claude-hooks/validate-feature-review-coverage*.Tests.ps1`, and `spec.md` D3.

Current state: the branch makes the remediation gate run the cycle's selection in coverage mode and makes the review read repo-wide totals from the final-QC artifact, re-running only the branch's or cycle's selection when a report is stale, "never the full suite". The unchanged Stop hook reads the root LINE counter of the local `artifacts/pester/powershell-coverage.xml` (and `artifacts/python/lcov.info`, `coverage/lcov.info`, `artifacts/csharp/coverage.xml`) as the repo-wide figure and blocks completion unless the policy audit records a FAIL coverage verdict when that figure is below the floor. The freshness hook requires the report to postdate the newest commit touching the language. After a remediation gate, a reviewer that follows the branch's rules can therefore complete only by recording a false repo-wide FAIL or by running the full suite. Spec D3 states that a selection run satisfies the freshness hook "without a full run" and that no hook code changes; it does not account for the metrics hook. This review reproduced the conflict: after the reviewer's D3 selection re-run (721 tests, 1002 covered and 47974 missed lines, 2.05%), the hook refused completion with "PowerShell repo-wide coverage is 2.05% ... but the policy-audit contains no FAIL verdict", while the true repo-wide figure from the final QA run is 96.85%.

Fix (planner chooses the mechanism and records the decision):
1. Make the repo-wide check of the coverage Stop hook distinguish a full-suite report from a selection report, and grade only a full-suite report as repo-wide. Candidate mechanisms: a run-scope marker written by `Invoke-PoshQCParallelTest` and the launcher when `-TestPath` or selected files are passed, read by the hook; or reading the repo-wide figure from the final-QC evidence named in the policy audit. A selection report then supplies per-file figures only, as the remediated agent text states.
2. Keep freshness and per-file checks for selection reports; keep the repo-wide FAIL requirement for a full-suite report below the floor.
3. Amend spec D3 (and the Out of Scope "Hooks and validators" line) with a recorded autonomous-mode decision, and add the hooks to ledger entry `0014` (Files Changed, stored patch, revert steps) in the same commit.
4. Copy the edited hooks to their bundles byte-identically; add Pester rows for the selection-report and full-report cases; PowerShell production coverage of the changed hook files must meet the 85% line threshold with no regression on changed lines.

Verification: the new hook rows pass; a review after a selection run with a below-floor root counter and a PASS policy audit is accepted by the hook; a full-suite report below the floor is still rejected without a FAIL verdict; bundle parity and ledger chain tests pass.

## Ledger and records

- Extend ledger entry `0014` in the same commit as the hook change, regenerate its stored patch from the merge base, and keep the commit subject token `reduction: 0014`.
- Leave every acceptance criterion as checked; this finding does not reopen a criterion as written, but the spec D3 text must be corrected.

## Do not do

- Do not lower any coverage threshold, add a coverage exclusion, or make the hook skip the repo-wide check for a full-suite report.
- Do not change CI workflows, the frozen epic surfaces (D5), the D10 standalone Copilot agents and prompts, or the docs estate owned by epic #1217.
- Do not hand-edit a generated file; do not add Python (hooks are PowerShell or bash).
- Do not use serial, single-process, shuffled, or reversed test runs.
- Write evidence only under `.dev/active/1228-targeted-test-cadence/evidence/<kind>/`, append-only, with clock-read timestamps.
