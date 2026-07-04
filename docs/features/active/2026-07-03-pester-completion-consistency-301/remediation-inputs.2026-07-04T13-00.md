# Remediation Inputs (Cycle 2): pester-completion-consistency (Issue #301)

**Timestamp:** 2026-07-04T13-00
**Author:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-03-pester-completion-consistency-301`
**Triggering audit artifacts:**
- `docs/features/active/2026-07-03-pester-completion-consistency-301/policy-audit.2026-07-04T13-00.md` (Coverage Metrics table; Gaps and Exceptions Finding 1)
- `docs/features/active/2026-07-03-pester-completion-consistency-301/code-review.2026-07-04T13-00.md` (Findings Table, Major finding; Findings Table, Minor finding)
- `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.2026-07-04T13-00.md` (AC 3: PARTIAL)

**Prior remediation cycle:** `remediation-inputs.2026-07-04T11-15.md` (cycle 1 inputs) and `remediation-plan.2026-07-04T12-00.md` (cycle 1 plan, executed). Cycle 1 closed Fix 1 (`CodeCoverage.Path` exclusion gap), Fix 2 (coverage rerun with accurate evidence), and Fix 4 (TypeScript `tsconfig.json` fix, plus the full-repo `fix_all` gate). Cycle 1 left Fix 3 (AC 3 -> PASS) explicitly and honestly open, because the underlying coverage gap it depended on was not resolved within cycle 1's declared scope.

## Why Remediation Is Triggered (Cycle 2)

Per `.claude/skills/feature-review-workflow/SKILL.md` step 8, remediation is required because:
- Coverage below policy threshold for new/modified production files: `.codex/hooks/enforce-completion-consistency.ps1` (modified) and `.codex/hooks/enforce-completion-helpers.ps1` (new), plus their two bundled-resource mirrors, show 0.00% real line coverage on their tracked canonical paths, below the 85%/90% floors.
- Acceptance criterion 3 remains PARTIAL, not PASS.

This is not a functional defect in the shipped hook behavior. The hook logic is byte-identical to the already-tested `.claude/hooks` counterpart (91.87%/93.02% real coverage) and is behaviorally exercised via a mirror-path test. The gap is specifically that Pester's per-file coverage instrumentation attributes coverage by exact file path, and no test in the repository dot-sources the two canonical `.codex/hooks/` paths that are now tracked in `CodeCoverage.Path`.

## Enumerated Fix List

1. **Retarget or supplement the Codex Pester test to dot-source the canonical `.codex/hooks/` path.**
   - File: `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`
   - Current behavior (line 9): `$script:UnderTest = (Resolve-Path "$PSScriptRoot/../../../extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1").Path`
   - Expected behavior: either (a) change `$script:UnderTest` to resolve the canonical `$PSScriptRoot/../../../.codex/hooks/enforce-completion-consistency.ps1` path instead, or (b) add a second `Describe` block (or duplicate `BeforeAll`/`BeforeEach` targeting a second `$script:UnderTestCanonical` variable) that dot-sources the canonical path in addition to the existing bundled-mirror target, so both paths receive real Pester coverage instrumentation. Do not remove the existing bundled-mirror-path assertions if choosing option (b); the bundled-mirror path should continue to have some verification that it stays byte-identical to the canonical path (a `diff`-style assertion, or an existing/new parity test, is sufficient for that purpose and does not need to duplicate full behavioral coverage).
   - This same retargeting/supplementing is also required for the helper file: no test currently dot-sources `.codex/hooks/enforce-completion-helpers.ps1` directly (it is only indirectly loaded via the hook's own dot-source of the helper file when the hook script itself is dot-sourced from the bundled-mirror path, which does not attribute coverage to the canonical helper file path).
   - Verification command: re-run the coverage-enabled Pester suite (equivalent to `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Import-Module './scripts/powershell/PoshQC' -Force; Invoke-PoshQCTest -Root '.' -ScanFolders @('tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1','tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1')"`, consistent with the tool-routing finding already documented in `evidence/qa-gates/final-powershell-pester.2026-07-04T12-00.md`); confirm `artifacts/pester/powershell-coverage.xml` shows `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` at line coverage >= 85% each.

2. **Re-run the coverage-enabled Pester suite and record a corrected baseline-vs-final comparison for cycle 2.**
   - Files: `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/remediation-baseline/baseline-powershell-pester.<new-timestamp>.md`, `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/final-powershell-pester.<new-timestamp>.md`, `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/coverage-comparison.<new-timestamp>.md`
   - Expected behavior: each artifact records the actual numeric per-file `<counter type="LINE">` figures for all four in-scope files, re-derived by direct `grep`/inspection of the regenerated `artifacts/pester/powershell-coverage.xml`, not copied from a prior cycle's artifact.
   - Verification command: after regenerating, run `grep -n "<the-cited-figure>" artifacts/pester/powershell-coverage.xml` and confirm a match exists before finalizing the evidence artifact text (same fail-closed rule as cycle 1).
   - No-regression check: confirm the two `.claude/hooks/*` files' coverage does not drop below their current 91.87%/93.02% figures, and confirm all 16 pre-existing `CodeCoverage.Path` entries are unaffected.

3. **Re-evaluate AC 3 in a follow-up feature-audit.**
   - File: new `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.<new-timestamp>.md` (post-cycle-2 re-review)
   - Expected behavior: AC 3 ("Pester coverage for `enforce-completion-consistency.ps1` passes for the targeted hook test file") is re-evaluated to PASS once all four in-scope files (not just two) are confirmed >=85% line coverage with no regression, and `issue.md`'s AC 3 checkbox is checked `[x]` by the reviewing agent at that time (not before).

4. **Correct the reversed rationale sentence in the cycle-1 bundled-mirror scope-decision evidence file (non-blocking, documentation-accuracy only).**
   - File: a new evidence artifact, e.g. `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/other/codecoverage-bundled-mirror-decision-correction.<new-timestamp>.md`, or an inline correction note appended to `evidence/other/codecoverage-bundled-mirror-decision.2026-07-04T12-00.md` (do not silently edit the timestamped cycle-1 artifact's original text; append a dated correction instead, consistent with append-only evidence conventions).
   - Expected behavior: the correction states plainly that the original file's claim ("the Pester test suites... exercise the canonical `.codex/hooks/` paths, not the bundled mirror paths") was reversed from fact, and cites the correct fact (the Codex test exercises the bundled mirror, not the canonical path) with a pointer to `feature-audit.2026-07-04T12-00.md` and `code-review.2026-07-04T13-00.md` as the artifacts that identified and independently re-confirmed the discrepancy.
   - This is optional relative to Fix 1-3 above (which are required to close AC 3); it does not block AC 3 closure on its own, but should not be silently dropped.

## Do Not Do

- Do not weaken or remove the sentinel/placeholder rejection logic in `Test-IsValidIssueNum`/`Test-IsValidFeatureFolder` to "improve" coverage numbers artificially.
- Do not delete or reduce the existing bundled-mirror-path test coverage in `enforce-completion-consistency-codex.Tests.ps1` when adding canonical-path coverage; both paths should end up covered (either both dot-sourced, or the mirror path's byte-identity to the canonical path is itself asserted).
- Do not add the two bundled-mirror files (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/*`) to `CodeCoverage.Path` merely to "pass" a coverage number — the cycle-1 scope decision to exclude them (to avoid double-counting identical code) remains valid; the fix is to make the *canonical* files' coverage real, not to change which files are tracked.
- Do not mark AC 3 or the overall feature PASS without a coverage artifact that shows all four in-scope files (not two) at or above the coverage floor.
- Do not cite a coverage figure in a new evidence artifact that cannot be located via direct text search in the regenerated `artifacts/pester/powershell-coverage.xml`.

## Pointer to Audit Artifacts

- `docs/features/active/2026-07-03-pester-completion-consistency-301/policy-audit.2026-07-04T13-00.md`
- `docs/features/active/2026-07-03-pester-completion-consistency-301/code-review.2026-07-04T13-00.md`
- `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.2026-07-04T13-00.md`

## Handoff Note

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, plan authoring for this remediation cycle belongs to `atomic-planner`, preflight and execution to `atomic-executor`, and reaudit to `feature-review`. This `feature-review` session has no subagent-delegation mechanism available in its current toolset, so it cannot directly invoke `atomic-planner` to author `remediation-plan.md`. The orchestrator (or the user) should delegate plan authoring for cycle 2 to `atomic-planner` using this file as the remediation-inputs source.
