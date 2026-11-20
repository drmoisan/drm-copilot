# Feature Audit: planner-hook-em-dash-mismatch-357 (#357)

**Audit Date:** 2026-07-17
**Feature Folder:** `docs/features/active/planner-hook-em-dash-mismatch-357`
**Base Branch:** `main` (origin/main @ `070b1aaba8c4c312afacf52b75b18050532abe81`)
**Head Branch:** `drm-copilot-wt-2026-07-17T10-05` @ `f3e159043895305b4d10954aa06162261ba989ef`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `070b1aaba8c4c312afacf52b75b18050532abe81`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-17T10-05` (commit `f3e159043895305b4d10954aa06162261ba989ef`)
- **Merge base:** `67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/planner-hook-em-dash-mismatch-357/evidence/**`
  - Additional evidence: direct `git diff 67c871eb7043755c9b5ba2a62e80fdfa2ba1a7f2..HEAD` inspection and direct inspection of `artifacts/pester/powershell-coverage.xml`
- **Feature folder used:** `docs/features/active/planner-hook-em-dash-mismatch-357`
- **Requirements source:** `issue.md` only (work mode `minor-audit`)
- **Work mode resolution note:** `issue.md` line 3 declares `- Work Mode: minor-audit` explicitly; per `acceptance-criteria-tracking`, the `## Acceptance Criteria` section of `issue.md` is the sole authoritative AC source, and `spec.md`/`user-story.md` are correctly absent from this feature folder.
- **Scope note:** No caller-supplied scope narrowing was detected or accepted; this audit evaluates the full branch diff (`67c871eb..HEAD`) against `main`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md` — only source (per `minor-audit` work mode)

### Acceptance criteria

1. `Get-PlanStructureValidationReport` in `.claude/hooks/validate-planner-output.ps1` accepts `### Phase N — <Title>` (em dash) phase headings.
2. A new/updated Pester test in `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` proves a plan using the em-dash heading format passes validation (regression test, written to fail against the pre-fix regex).
3. Existing fixtures are updated to use the em dash so the suite reflects the real contract rather than masking the mismatch.
4. PoshQC format, analyze, and Pester toolchain all pass with no regressions.

All four items are already marked `[x]` in `issue.md` at the time of this audit (pre-checked by the executing agent). This audit independently re-verifies each item against evidence before treating any check-off as confirmed.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `Get-PlanStructureValidationReport` accepts `### Phase N — <Title>` (em dash) phase headings | PASS | `git diff` line 121: `$phasePattern = '^### Phase (?<Phase>\d+)\s+—\s+(?<Title>.+)$'` (em dash, U+2014, confirmed by direct diff inspection). `evidence/regression-testing/em-dash-pass-after.md` confirms `Invoke-PlannerOutputValidation` returns `Ok = $true` for an em-dash-only plan post-fix. | `git diff 67c871eb..HEAD -- .claude/hooks/validate-planner-output.ps1` | Independently re-verified via direct diff read, not solely from feature-authored evidence. |
| 2 | New/updated Pester test proves em-dash plan passes; written to fail against pre-fix regex | PASS | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` lines 107–128: `It 'allows termination when phase headings use the canonical em dash (U+2014)'`. `evidence/regression-testing/em-dash-fail-before.md` documents the test failing (exit 1) against the unmodified regex; `evidence/regression-testing/em-dash-pass-after.md` documents it passing (exit 0) post-fix. | scoped `Invoke-Pester -Filter.FullName '*allows termination when phase headings use the canonical em dash*'` (per evidence) | Criterion is technically satisfied. Note (tracked separately in code-review, non-blocking to this AC): after AC 3's fixture updates, this test's fixture became identical to the pre-existing "satisfies the structural contract" test, so it no longer independently distinguishes em-dash-only input from the general well-formed-plan case — it still satisfies the literal wording of this AC (a test exists, proves em-dash passes, and was demonstrated to fail-before/pass-after). |
| 3 | Existing fixtures updated to use em dash | PASS | `git diff` confirms three fixture blocks (lines ~48, ~68, ~89 pre-change) changed from ASCII hyphen literals (`'### Phase 1 - Implement'`) to em-dash literals (`` "### Phase 1 `u{2014} Implement" ``) in the "blocks when Phase 0 baseline and policy-read tasks are missing", "blocks when a task omits an explicit path", and "allows termination when the plan satisfies the structural contract" test cases, matching `plan.2026-07-17T10-11.md` task P2-T4. | `git diff 67c871eb..HEAD -- tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` | Independently re-verified via direct diff read. |
| 4 | PoshQC format, analyze, and Pester toolchain all pass with no regressions | PARTIAL | Format: exit 0 final (`evidence/qa-gates/poshqc-format-final.md`). Analyze: exit 0 final, after one documented remediation cycle for a `PSUseBOMForUnicodeEncodedFile` finding (`evidence/qa-gates/poshqc-analyze-final.md`). Test: 7/7 passing (`evidence/qa-gates/poshqc-test-final.md`). No coverage regression occurred (69.87% unchanged, `evidence/qa-gates/coverage-delta.md`). However, "toolchain... pass with no regressions" is evaluated here against the full toolchain policy, which includes the uniform 85%/75% coverage floor (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`) — that floor was not met either before or after this change (69.87% < 85%), and the canonical `artifacts/pester/powershell-coverage.xml` artifact does not measure this file at all. The AC's literal wording ("no regressions") is satisfied; the broader toolchain-compliance bar it implicitly invokes is not fully met. | `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` | See `policy-audit.2026-07-17T14-38.md` Section 8, Gap 1 for the full coverage finding. Downgraded from the pre-checked `[x]` to PARTIAL for this audit's evaluation because "toolchain all pass" is read here to include the coverage gate, which the toolchain does not currently satisfy for this file. |

---

## Summary

**Overall Feature Readiness:** NEEDS REVISION

**Criteria summary:**
- **PASS:** 3 criteria (1, 2, 3)
- **PARTIAL:** 1 criterion (4)
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. AC 4 ("PoshQC format, analyze, and Pester toolchain all pass with no regressions") is PARTIAL rather than PASS: the functional toolchain stages (format, analyze, test-pass/fail) all pass, but the coverage gate implied by "toolchain... pass" is not satisfied — `.claude/hooks/validate-planner-output.ps1` remains at 69.87% line coverage against the repository's uniform 85% requirement, and is not measured by the canonical coverage artifact at all. See `policy-audit.2026-07-17T14-38.md` and `remediation-inputs.2026-07-17T14-38.md`.
2. The duplicate-test finding (AC 2, non-blocking to the AC's literal wording but flagged in code-review) should be resolved for suite maintainability, though it does not change this AC's PASS status.

**Recommended follow-up verification steps:**

1. Add `.claude/hooks/validate-planner-output.ps1` to the coverage-measured file set and add a test for the line-137 error branch; re-run `mcp__drm-copilot__run_poshqc_test` with coverage and confirm >= 85% line coverage.
2. Re-run this feature audit after the coverage remediation lands to confirm AC 4 reaches PASS.

---

## Acceptance Criteria Check-Off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All four items in `issue.md` were already marked `[x]` prior to this audit. Criteria 1–3 are confirmed PASS by this audit's independent evidence review and remain correctly checked. Criterion 4 is evaluated as PARTIAL by this audit (see rationale above) and, per the check-off protocol, should not remain checked while a material gap is open. This audit does not un-check `issue.md` item 4 (this agent's mandate is audit-artifact production, not modification of AC source files' check state beyond checking off newly-passing items); the PARTIAL verdict recorded here supersedes the pre-existing `[x]` mark for review purposes, and the discrepancy is flagged explicitly for the remediation/orchestration layer to resolve (e.g., by un-checking item 4 once the gap is acknowledged, or by closing the coverage gap so the check-off becomes accurate).

### AC Status Summary

- Source: `docs/features/active/planner-hook-em-dash-mismatch-357/issue.md`
- Total AC items: 4
- Checked off (delivered, per this audit's independent verification): 3 (items 1, 2, 3)
- Remaining (unchecked per this audit's verdict, though marked `[x]` in the source file): 1 (item 4 — see discrepancy note above)
- Items remaining: "PoshQC format, analyze, and Pester toolchain all pass with no regressions" — PARTIAL because the uniform coverage floor is not met for the modified production file.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 4 | 3 | 1 (flagged, still marked `[x]` in source pending remediation) | Checkbox-backed, authoritative for `minor-audit` |
