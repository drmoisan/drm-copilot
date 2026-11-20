# Remediation Inputs: planner-hook-em-dash-mismatch-357 (#357)

**Entry Timestamp:** 2026-07-17T16-00
**Remediation Cycle:** 2
**Triggering Audit Artifacts:**
- `docs/features/active/planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T16-00.md` (Section 7, Gap 1)
- `docs/features/active/planner-hook-em-dash-mismatch-357/code-review.2026-07-17T16-00.md` (Findings Table, Major finding)
- `docs/features/active/planner-hook-em-dash-mismatch-357/feature-audit.2026-07-17T16-00.md` (AC 4, PARTIAL)

**Trigger condition met:** Coverage below policy threshold for a modified file with changed lines in the branch diff, and coverage artifact still absent for that file after a prior remediation attempt. `.claude/hooks/validate-planner-output.ps1` ad hoc line coverage is 73.72% (up from 69.87% pre-cycle-1, but below the uniform 85% requirement in `.claude/rules/quality-tiers.md` and `.claude/rules/powershell.md`), and the canonical coverage artifact (`artifacts/pester/powershell-coverage.xml`) still contains zero entries for this file, independently confirmed by this audit via direct `grep`.

**Root cause (carried forward from cycle 1's own evidence, independently corroborated by this audit):** `mcp__drm-copilot__run_poshqc_test` resolves its Pester settings from `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (a bundled copy), not from `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (the repo canonical copy that cycle 1 edited). The two files are otherwise byte-identical except for this one missing allowlist entry. `git log --oneline -- extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` confirms commit `f3701f7f` (issue #344) previously updated this exact bundled file in the same commit as the `scripts/` copy — the established repository pattern is to keep both files synchronized.

---

## Enumerated Fix List

1. **Sync the bundled PoshQC settings copy so the canonical MCP-driven coverage measurement actually reaches `.claude/hooks/validate-planner-output.ps1`.**
   - File: `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
   - Expected behavior: Add `'.claude/hooks/validate-planner-output.ps1'` to this file's `CodeCoverage.Path` array, in the same position/style as the entry already present in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (added by cycle 1), including a matching one-line comment referencing issue #357. This mirrors the established pattern from commit `f3701f7f` (issue #344), which updated both copies together.
   - Verification command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, then inspect `artifacts/pester/powershell-coverage.xml` directly (`grep -n "sourcefilename=\"validate-planner-output" artifacts/pester/powershell-coverage.xml`) to confirm a non-empty match now exists with a `line-rate`/`LINE` counter.
   - Note: confirm both settings files remain otherwise identical after this edit (`diff extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1` should show no differences), so this fix does not introduce unrelated drift between the two copies.

2. **Add test coverage for `Get-PlanFileContent`'s real disk-read body (or another currently-uncovered surface) to close the remaining gap to >= 85% line coverage.**
   - File: `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`
   - Expected behavior: Every existing test mocks `Get-PlanFileContent` rather than exercising its real `Test-Path`/`Get-Content` logic (lines 45-57), which is the largest contiguous block of the 28 remaining uncovered lines per `evidence/qa-gates/coverage-delta-remediation1.md`. Add at least one test that invokes `Get-PlanFileContent` directly (not through the mocked boundary) against a real, non-existent path (asserting `Exists = $false`) and, if feasible without violating the "no temporary files in tests" rule (`general-unit-test.md`), against a fixture path that already exists on disk within the test tree (e.g., the test file itself) to assert `Exists = $true` and a populated `Lines` array. Do not create temporary files to satisfy this test.
   - Verification command: `mcp__drm-copilot__run_poshqc_test` scoped to `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`; after fix #1 lands, inspect `artifacts/pester/powershell-coverage.xml` directly for this file's numeric line-rate and confirm it is >= 85%. If still below 85% after this test addition, identify and cover additional uncovered lines (see the remaining-uncovered-lines list in `evidence/qa-gates/coverage-delta-remediation1.md`) until the threshold is met.

3. **Re-run the full toolchain and confirm the coverage floor is met via the canonical artifact.**
   - Files: `.claude/hooks/validate-planner-output.ps1` (no change expected unless a covering test requires one), `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
   - Expected behavior: Format -> analyze -> test (with coverage) all pass in a single clean pass; the canonical `artifacts/pester/powershell-coverage.xml` reports line coverage >= 85% for `.claude/hooks/validate-planner-output.ps1` (branch coverage remains an accepted, documented tooling limitation — no `BRANCH` counter is emitted for any file in this repository's Pester setup — and should continue to be documented as such, not silently ignored).
   - Verification command: `mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`, each scoped to the files above; record exit codes and the canonical artifact's numeric coverage in new `evidence/qa-gates/` artifacts under this feature folder for this second remediation cycle.

---

## Do Not Do

- Do not lower the 85% line / 75% branch coverage threshold, add a tier-specific exception, or exclude `.claude/hooks/validate-planner-output.ps1` from coverage measurement to make the gate pass artificially. `general-unit-test.md`'s Coverage Exclusion Policy explicitly prohibits excluding production source paths from coverage measurement.
- Do not widen the change budget beyond what is required to close this specific gap (syncing one settings file entry and adding test coverage for the remaining uncovered surface). Do not touch the vendored `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1` copy (a separate, unrelated file — the *hook* itself, not a settings file — tracked as a non-blocking Informational finding).
- Do not create temporary files in tests to exercise `Get-PlanFileContent`'s real-path branch; use an existing on-disk path within the test tree if a real-path positive case is needed, per `general-unit-test.md`'s prohibition on temporary files in tests.
- Do not silently skip the coverage-comparison step; record baseline-vs-post-change coverage numbers (cycle-1 ad hoc 73.72% vs. this cycle's canonical-artifact measurement) in a new evidence artifact per `evidence-and-timestamp-conventions`.
- Do not weaken any existing assertion to make a new or existing test pass.
- Do not claim AC 4 in `issue.md` is fully satisfied until the canonical coverage artifact shows >= 85% line coverage for `.claude/hooks/validate-planner-output.ps1`.
- Do not introduce unrelated drift between the two `pester.runsettings.psd1` copies while syncing the one required entry; confirm the files remain otherwise identical after the edit.

---

## Pointer to Audit Artifacts

- Policy audit: `docs/features/active/planner-hook-em-dash-mismatch-357/policy-audit.2026-07-17T16-00.md`
- Code review: `docs/features/active/planner-hook-em-dash-mismatch-357/code-review.2026-07-17T16-00.md`
- Feature audit: `docs/features/active/planner-hook-em-dash-mismatch-357/feature-audit.2026-07-17T16-00.md`
- Prior cycle's artifacts (superseded but retained for history): `policy-audit.2026-07-17T14-38.md`, `code-review.2026-07-17T14-38.md`, `feature-audit.2026-07-17T14-38.md`, `remediation-inputs.2026-07-17T14-38.md`, `remediation-plan.2026-07-17T14-38.md`

---

## Handoff Note

This file is authored by `feature-review` per this agent's Required Outputs contract. Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, plan authoring for this remediation cycle is the responsibility of `atomic-planner`, delegated by the orchestrator; `feature-review` does not author or execute the remediation plan itself. The orchestrator should route this file's enumerated fix list to `atomic-planner` to produce a new `remediation-plan.<timestamp>.md` per the atomic-plan-contract, then proceed through the standard preflight -> execution -> reaudit chain.
