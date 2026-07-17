# Feature Audit: planner-hook-em-dash-mismatch-357 (#357)

**Audit Date:** 2026-07-17T16-00
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `6e7bc63cf7941e82af09ca931ae066e2196b513f`
**Work Mode:** `minor-audit`
**Audit Type:** Re-audit following remediation cycle 1

---

## Scope and Baseline

- **Base branch:** `main`, merge-base `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`.
- **Head branch/commit:** `drm-copilot-wt-2026-07-17T10-05` @ `6e7bc63cf7941e82af09ca931ae066e2196b513f` (includes commit `f3e15904` from the initial implementation and commit `6e7bc63c`, `test(planner-hook): add coverage for malformed phase heading validation`, from remediation cycle 1).
- **Evidence sources:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`, `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**` (both cycle-0 `baseline`/`qa-gates`/`regression-testing` and cycle-1 `remediation-baseline`/`qa-gates` subtrees), direct `git diff 67c871eb..HEAD` inspection, direct inspection of `artifacts/pester/powershell-coverage.xml` and both `pester.runsettings.psd1` copies.
- **Requirements source:** `issue.md` `## Acceptance Criteria` section only (work mode `minor-audit`).
- **Scope note:** No caller-supplied scope narrowing was detected or accepted; this audit evaluates the full branch diff (`67c871eb..HEAD`) against `main`.

---

## Acceptance Criteria Inventory

**Authoritative AC source file:** `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`

1. `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` accepts `### Phase N — <Title>` (em dash) phase headings.
2. A new/updated Pester test in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` proves a plan using the em-dash heading format passes validation (regression test, written to fail against the pre-fix regex).
3. Existing fixtures are updated to use the em dash so the suite reflects the real contract rather than masking the mismatch.
4. PoshQC format, analyze, and Pester toolchain all pass with no regressions.

All four items are marked `[x]` in `issue.md` at the time of this audit. This audit independently re-verifies each item before treating any check-off as confirmed, per the prior audit's practice.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Notes |
|---|-----------|--------|----------|-------|
| 1 | `Get-PlanStructureValidationReport` accepts `### Phase N — <Title>` (em dash) phase headings | PASS (unchanged from cycle 0) | Direct read of `.claude/hooks/validate-planner-output.ps1` line 121: `$phasePattern = '^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$'` (em dash, U+2014). Not touched by remediation cycle 1; still correct. | Independently re-verified via direct file read for this audit. |
| 2 | New/updated Pester test proves em-dash plan passes; written to fail against pre-fix regex | PASS (unchanged from cycle 0; the specific test that satisfies this AC — `allows termination when the plan satisfies the structural contract` — was retained after cycle 1 removed its duplicate) | Direct read of `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` lines 102-123 confirms the em-dash-only structural-contract test remains present and passing. `evidence/regression-testing/em-dash-fail-before.md` / `em-dash-pass-after.md` document the original fail-before/pass-after regression proof from cycle 0. | Cycle 1 removed the *duplicate* em-dash test flagged in the prior code review, not the original one satisfying this AC; the AC remains satisfied by the retained test. |
| 3 | Existing fixtures updated to use em dash | PASS (unchanged from cycle 0) | Direct read confirms all fixtures in the current test file use `` `u{2014} `` (em dash) escapes. | Independently re-verified via direct file read. |
| 4 | PoshQC format, analyze, and Pester toolchain all pass with no regressions | **PARTIAL (unchanged disposition from cycle 0; incremental improvement, gap not closed)** | Format: exit 0 (`evidence/qa-gates/poshqc-format-remediation1-final.md`). Analyze: exit 0 (`evidence/qa-gates/poshqc-analyze-remediation1-final.md`). Test: 7/7 pass (`evidence/qa-gates/poshqc-test-remediation1-final.md`). No functional regressions. However, the coverage gate this AC's "toolchain... pass" wording implicitly invokes (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`, all requiring >= 85% line coverage) remains unmet: ad hoc coverage is 73.72% (up from 69.87% at cycle-0 baseline, but still below 85%), and the canonical `artifacts/pester/powershell-coverage.xml` artifact still contains zero entries for this file — independently confirmed by this audit via direct `grep`. Root cause (independently corroborated): the cycle-1 allowlist edit landed only in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the MCP `run_poshqc_test` tool actually reads the separate bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, which was not updated. | See `policy-audit.2026-07-17T16-00.md` Section 7, Gap 1, and `remediation-inputs.2026-07-17T16-00.md` for the full finding and required second-cycle fix list. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION (unchanged from cycle 0's verdict; remediation cycle 1 made verified partial progress but did not resolve the blocking gap)

**Criteria summary:**
- **PASS:** 3 criteria (1, 2, 3)
- **PARTIAL:** 1 criterion (4)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC 4 remains PARTIAL rather than PASS: the functional toolchain stages (format, analyze, test pass/fail) all pass cleanly, and the test-suite duplicate flagged in cycle 0 has been resolved, but the coverage gate is still unmet. Ad hoc line coverage improved from 69.87% to 73.72% (a genuine, verified gain covering the exact lines targeted by cycle 1), yet remains below the uniform 85% threshold, and the canonical coverage artifact still does not measure this file at all due to a settings-file synchronization gap discovered during remediation cycle 1 but not yet fixed.

**Recommended follow-up verification steps:**

1. Add the same `CodeCoverage.Path` allowlist entry to `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (the file the MCP tool actually reads), matching the established pattern used for prior issues (#272, #214, #275, #301, #305, #312, #328, #334, #344).
2. Add further tests targeting an uncovered surface (e.g., `Get-PlanFileContent`'s real disk-read body, lines 45-57) to close the gap from 73.72% to >= 85% line coverage.
3. Re-run the full PowerShell toolchain and confirm the canonical `artifacts/pester/powershell-coverage.xml` now contains a `validate-planner-output.ps1` entry with line coverage >= 85%.
4. Re-run this feature audit after the second remediation cycle lands to confirm AC 4 reaches PASS.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules: criteria evaluated as PASS may be checked off if not already checked; criteria evaluated as PARTIAL, FAIL, or UNVERIFIED must remain unchecked.

All four items in `issue.md` are already marked `[x]`. Criteria 1-3 are confirmed PASS by this audit's independent re-verification and remain correctly checked. Criterion 4 is again evaluated as PARTIAL (an improvement over cycle 0's evidence, but still short of the coverage threshold), and per the check-off protocol should not be represented as fully satisfied. Consistent with the prior audit's practice, this agent's mandate is audit-artifact production, not modification of AC source files' check state beyond checking off newly-passing items; this audit does not un-check `issue.md` item 4, but the discrepancy between the source file's `[x]` mark and this audit's PARTIAL verdict is again flagged explicitly for the remediation/orchestration layer to resolve once the second remediation cycle closes the coverage gap.

### AC Status Summary

- Source: `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`
- Total AC items: 4
- Checked off (delivered, per this audit's independent verification): 3 (items 1, 2, 3)
- Remaining (unchecked per this audit's verdict, though marked `[x]` in the source file): 1 (item 4 — coverage gate unmet; see discrepancy note above)
- Items remaining: "PoshQC format, analyze, and Pester toolchain all pass with no regressions" — PARTIAL because the uniform coverage floor is not met for the modified production file, and the canonical coverage artifact does not measure it at all.

| Source File | Total AC | Checked (PASS, this audit) | Unchecked (this audit) | Notes |
|-------------|----------|------------------------------|--------------------------|-------|
| `issue.md` | 4 | 3 | 1 (flagged; still marked `[x]` in source pending second remediation cycle) | Checkbox-backed, authoritative for `minor-audit` |

---

**Audit Completed By:** feature-review (Claude Code subagent)
**Audit Date:** 2026-07-17T16-00
