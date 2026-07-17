# Remediation Inputs: planner-hook-em-dash-mismatch-357 (#357)

**Entry Timestamp:** 2026-07-17T14-38
**Triggering Audit Artifacts:**
- `docs/features/active/planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T14-38.md` (Section 8, Gap 1)
- `docs/features/active/planner-hook-em-dash-mismatch-357/code-review.2026-07-17T14-38.md` (Findings Table, Major finding)
- `docs/features/active/planner-hook-em-dash-mismatch-357/feature-audit.2026-07-17T14-38.md` (AC 4, PARTIAL)

**Trigger condition met:** Coverage below policy threshold for a modified file with changed lines in the branch diff (`.claude/hooks/validate-planner-output.ps1`: 69.87% line coverage against the uniform 85% requirement in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`, and below the 80% modified-file remediation-trigger floor used by this review's coverage-verification procedure). The canonical coverage artifact (`artifacts/pester/powershell-coverage.xml`) does not measure this file at all.

---

## Enumerated Fix List

1. **Bring `.claude/hooks/validate-planner-output.ps1` under canonical PowerShell coverage measurement.**
   - File: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
   - Expected behavior: Add `.claude/hooks/validate-planner-output.ps1` to the `CodeCoverage.Path` array so the canonical `mcp__drm-copilot__run_poshqc_test` run produces a real per-file coverage measurement for this hook in `artifacts/pester/powershell-coverage.xml`, consistent with how prior issues (e.g. #272, #214, #275, #301, #305 per the existing comments in that settings file) added their touched hook files to this same allowlist.
   - Verification command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, then inspect `artifacts/pester/powershell-coverage.xml` directly (e.g. via a short Python/PowerShell snippet) to confirm a `validate-planner-output.ps1` entry now exists with a `line-rate`/`LINE` counter.

2. **Add a test targeting the currently-uncovered error branch at line 137.**
   - File: `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
   - Expected behavior: Add an `It` case supplying a plan whose `### Phase` heading is malformed (e.g., missing the separator entirely, such as `### Phase 1 Implement`, or using some other non-matching separator) so that `Get-PlanStructureValidationReport`'s `-not $phaseMatch.Success` branch (line 136–140) executes and the fixed error-message text (line 137, `"Line ${lineNumber}: phase heading must match ..."`) is exercised and asserted on via `Should -Match`.
   - Verification command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`; confirm the new test passes and that line 137 now reports covered in the ad hoc or canonical coverage measurement.

3. **Re-run the full toolchain and confirm the coverage floor is met.**
   - Files: `.claude/hooks/validate-planner-output.ps1`, `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
   - Expected behavior: Format -> analyze -> test (with coverage) all pass in a single clean pass; line coverage for `.claude/hooks/validate-planner-output.ps1` reaches >= 85% (branch coverage measurement is a known Pester 5.6.1 tooling limitation — no `BRANCH` counter is emitted for any file in this repository's Pester setup, so branch coverage cannot be raised or lowered by this remediation and should be documented as an accepted tooling constraint, not silently ignored).
   - Verification command: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, each scoped to the files above; record exit codes and coverage percentages in new `evidence/qa-gates/` artifacts under this feature folder.

4. **(Optional, Minor severity, non-blocking) Deduplicate the new em-dash regression test.**
   - File: `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
   - Expected behavior: Either remove the now-duplicate `It 'allows termination when phase headings use the canonical em dash (U+2014)'` (lines 107–128) in favor of the pre-existing `It 'allows termination when the plan satisfies the structural contract'` (lines 84–105, already em-dash after fixture updates), or differentiate its fixture so it adds distinct test signal rather than repeating an existing test verbatim.
   - Verification command: `mcp__drm-copilot__run_poshqc_test` scoped to the test file; confirm test count and pass/fail results after the change.

---

## Do Not Do

- Do not lower the 85% line / 75% branch coverage threshold, add a tier-specific exception, or exclude `.claude/hooks/validate-planner-output.ps1` from coverage measurement to make the gate pass artificially. `general-unit-test.md`'s Coverage Exclusion Policy explicitly prohibits excluding production source paths from coverage measurement.
- Do not widen the change budget beyond what is required to close this specific gap (adding one file path to the coverage allowlist and one test case). Do not touch unrelated hook files, unrelated fixtures, or the vendored `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` copy as part of this remediation cycle (that copy is a separate, non-blocking Info finding — see code review).
- Do not silently skip the coverage-comparison step; record baseline-vs-post-change coverage numbers in a new evidence artifact per `evidence-and-timestamp-conventions`.
- Do not weaken any existing assertion to make a new or existing test pass.
- Do not claim AC 4 in `issue.md` is fully satisfied until the canonical coverage artifact shows >= 85% line coverage for `.claude/hooks/validate-planner-output.ps1`.

---

## Pointer to Audit Artifacts

- Policy audit: `docs/features/active/planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T14-38.md`
- Code review: `docs/features/active/planner-hook-em-dash-mismatch-357/code-review.2026-07-17T14-38.md`
- Feature audit: `docs/features/active/planner-hook-em-dash-mismatch-357/feature-audit.2026-07-17T14-38.md`

---

## Handoff Note

This file is authored by `feature-review` per this agent's Required Outputs contract. Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, plan authoring for this remediation cycle is the responsibility of `atomic-planner`, delegated by the orchestrator; `feature-review` does not author or execute the remediation plan itself. The orchestrator should route this file's enumerated fix list to `atomic-planner` to produce `remediation-plan.md` per the atomic-plan-contract, then proceed through the standard preflight -> execution -> reaudit chain.
