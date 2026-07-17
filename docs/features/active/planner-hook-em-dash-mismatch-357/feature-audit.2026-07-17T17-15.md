# Feature Audit: planner-hook-em-dash-mismatch-357 (#357)

**Audit Date:** 2026-07-17T17-15
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `67cd49a6e380b25b00b5ad35f93d56d44d4488cf`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit following remediation cycle 2

---

## Scope and Baseline

- **Base branch:** `main`, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`.
- **Head branch/commit:** `drm-copilot-wt-2026-07-17T10-05` @ `67cd49a6e380b25b00b5ad35f93d56d44d4488cf` (includes `f3e15904` initial implementation, `6e7bc63c` remediation cycle 1, and `67cd49a6` remediation cycle 2).
- **Evidence sources:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**` (baseline, remediation-baseline, qa-gates, regression-testing subtrees across all three cycles), direct `git diff 67c871eb..HEAD` inspection, direct read of the current `.claude/hooks/validate-planner-output.ps1` and `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, and this audit's own independently-reproduced CI-equivalent `Invoke-PoshQCTest` run with direct inspection of the resulting `artifacts/pester/powershell-coverage.xml`.
- **Requirements source:** `issue.md` `## Acceptance Criteria` section only (work mode `minor-audit`).
- **Scope note:** No caller-supplied scope narrowing was detected or accepted; this audit evaluates the full branch diff (`67c871eb..HEAD`) against `main`. The caller's instruction to independently re-verify the CI-equivalent coverage claim was followed and is documented in `policy-audit.2026-07-17T17-15.md` and `code-review.2026-07-17T17-15.md`, not treated as scope narrowing.

---

## Acceptance Criteria Inventory

**Authoritative AC source file:** `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`

1. `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` accepts `### Phase N — <Title>` (em dash) phase headings.
2. A new/updated Pester test in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` proves a plan using the em-dash heading format passes validation (regression test, written to fail against the pre-fix regex).
3. Existing fixtures are updated to use the em dash so the suite reflects the real contract rather than masking the mismatch.
4. PoshQC format, analyze, and Pester toolchain all pass with no regressions.

All four items are marked `[x]` in `issue.md` at the time of this audit. This audit independently re-verifies each item before confirming any check-off, per the prior audits' practice.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Notes |
|---|-----------|--------|----------|-------|
| 1 | `Get-PlanStructureValidationReport` accepts `### Phase N — <Title>` (em dash) phase headings | **PASS** (unchanged from cycle 0) | Direct read of `.claude/hooks/validate-planner-output.ps1` line 121: `$phasePattern = '^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$'` (em dash, U+2014). Not touched by remediation cycles 1 or 2; still correct. | Independently re-verified via direct file read for this audit. |
| 2 | New/updated Pester test proves em-dash plan passes; written to fail against pre-fix regex | **PASS** (unchanged from cycle 0) | Direct read of `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` lines 166-187 confirms `It 'allows termination when the plan satisfies the structural contract'` remains present and passing, using an all-em-dash fixture. `evidence/regression-testing/em-dash-fail-before.md` / `em-dash-pass-after.md` document the original fail-before/pass-after regression proof. | Retained unchanged across cycles 1 and 2. |
| 3 | Existing fixtures updated to use em dash | **PASS** (unchanged from cycle 0) | Direct read confirms all phase-heading fixtures in the current test file use `` `u{2014} `` (em dash) escapes, with the single intentional exception at line 153 (`'### Phase 1 Implement'`, no separator), which is the deliberate negative-path fixture for the malformed-heading test, not a masking oversight. | Independently re-verified via direct file read. |
| 4 | PoshQC format, analyze, and Pester toolchain all pass with no regressions | **PASS** (resolved this cycle; upgraded from PARTIAL in cycles 0 and 1) | Format: exit 0 (`evidence/qa-gates/poshqc-format-remediation2-final.md`). Analyze: exit 0, zero findings (`evidence/qa-gates/poshqc-analyze-remediation2-final.md`). Test (MCP tool): 21/21 pass (`evidence/qa-gates/poshqc-test-remediation2-final.md`). No functional regressions at any stage. The coverage gate this AC's "toolchain... pass" wording implicitly invokes (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`, all requiring >= 85% line coverage) is now met: this audit independently reproduced the exact CI-enforced invocation (`Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path`, matching `.github/workflows/_poshqc.yml` verbatim) and confirmed 1286/1286 tests passing (0 failed, 9 skipped) and, via direct inspection of the resulting `artifacts/pester/powershell-coverage.xml`, 93.86% line coverage (107/114) for `.claude/hooks/validate-planner-output.ps1` — above the 85% threshold. | The MCP-tool-wrapped `run_poshqc_test`'s own canonical-artifact output remains stale (it resolves an npx-cached package independent of the workspace), but the actual repository/CI-enforced gate — reproduced directly by this audit, not merely read from evidence — is satisfied. See `policy-audit.2026-07-17T17-15.md` Sections "Coverage Metrics by Language" and 7-8 for full independent-verification detail. |

---

## Summary

**Overall Feature Readiness:** **READY TO MERGE** (upgraded from cycles 0/1's NEEDS REVISION; the blocking coverage gap is resolved)

**Criteria summary:**
- **PASS:** 4 criteria (1, 2, 3, 4)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Resolution of the prior gap:** AC 4 was PARTIAL in both prior audit cycles because the canonical, MCP-tool-produced coverage artifact showed zero coverage for `.claude/hooks/validate-planner-output.ps1`. This audit was directed to independently verify a new claim — that the actual CI-enforced gate (as opposed to the MCP wrapper) is satisfied — and did so by directly reproducing the CI workflow's exact invocation rather than accepting the claim from the evidence file alone. That reproduction succeeded: 93.86% line coverage, above the 85% threshold, with no test failures and no regressions on changed lines. Branch coverage remains an accepted, documented, repo-wide tooling limitation (no `BRANCH` counters emitted for any file in this repository's Pester setup), independently re-confirmed by this audit and not attributable to this feature.

**Remaining non-blocking follow-up (not a condition of this feature's merge):** The `mcp__drm-copilot__run_poshqc_test` MCP tool's own resolution of a stale, npx-cached, separately-published package (independent of this workspace) is a genuine tooling defect that should be filed as a new, separate issue. It does not affect the correctness of this feature's fix, tests, or the CI gate that actually enforces coverage on merge.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules: criteria evaluated as PASS may be checked off if not already checked; criteria evaluated as PARTIAL, FAIL, or UNVERIFIED must remain unchecked.

All four items in `issue.md` are already marked `[x]`. This audit's independent re-verification confirms all four criteria are correctly PASS, including AC 4, which prior audits had left unchecked-in-spirit (flagged as a discrepancy pending resolution). That discrepancy is now resolved: `issue.md`'s existing `[x]` marks for all four items are confirmed accurate by this audit and require no further action or un-checking.

### AC Status Summary

- Source: `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`
- Total AC items: 4
- Checked off (delivered, confirmed by this audit's independent verification): 4 (items 1, 2, 3, 4)
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS, this audit) | Unchecked (this audit) | Notes |
|-------------|----------|------------------------------|--------------------------|-------|
| `issue.md` | 4 | 4 | 0 | Checkbox-backed, authoritative for `minor-audit`; all four items confirmed PASS and correctly marked `[x]` in the source file. |

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17T17-15
