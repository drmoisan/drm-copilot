# Remediation Inputs: pester-completion-consistency (Issue #301)

**Timestamp:** 2026-07-04T11-15
**Author:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/2026-07-03-pester-completion-consistency-301`
**Triggering audit artifacts:**
- `docs/features/active/2026-07-03-pester-completion-consistency-301/policy-audit.2026-07-04T11-15.md` (Section 8: Gaps and Exceptions, Findings 1-2)
- `docs/features/active/2026-07-03-pester-completion-consistency-301/code-review.2026-07-04T11-15.md` (Findings Table, Major findings 1-2)
- `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.2026-07-04T11-15.md` (AC 3: PARTIAL)

## Why Remediation Is Triggered

Per `.claude/skills/feature-review-workflow/SKILL.md` step 8, remediation is required because:
- Coverage regression/exclusion below policy threshold: the four in-scope PowerShell hook files (2 new, 2 modified) have 0% measured coverage due to a `CodeCoverage.Path` configuration gap, below the 90%-new-file / 85%-repo-wide thresholds.
- A required acceptance criterion (AC 3) is evaluated PARTIAL, not PASS.

This is not a functional defect in the shipped hook behavior — the hook implementation itself passes all 51 targeted and 476 full-suite Pester tests, has 0 PSScriptAnalyzer findings, and is byte-for-byte identical to the already-reviewed `.claude/hooks` counterpart (all independently re-verified in this review cycle). The remediation scope below is strictly limited to closing the coverage-measurement and evidence-accuracy gaps.

## Enumerated Fix List

1. **Add the four in-scope hook files to `CodeCoverage.Path`.**
   - File: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
   - Expected behavior: the `CodeCoverage.Path` array (currently lines 23-50) gains four new entries: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`. Follow the existing in-file comment convention used for the Issue #272/#214/#275 precedents (a short comment above the new entries explaining why they are measured here).
   - Verification command: `mcp__drm-copilot__run_poshqc_test` (coverage-enabled) targeting `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1` and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, using the updated `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; confirm `artifacts/pester/powershell-coverage.xml` now contains `<sourcefile>` entries for all four files with line coverage >= 85% and branch coverage >= 75% each.
   - Note: whether the bundled resource copies under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` should also be added to `CodeCoverage.Path` is a decision for `atomic-planner`/`powershell-typed-engineer` to make explicitly (they are byte-identical to the `.codex/hooks/` originals, so measuring the canonical copies may be sufficient; if the bundled path is added too, ensure the coverage-percent math is not double-penalized for identical code appearing twice).

2. **Re-run the coverage-enabled Pester suite and record a corrected baseline-vs-final comparison.**
   - Files: `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/baseline/baseline-powershell-pester.<new-timestamp>.md`, `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/final-powershell-pester.<new-timestamp>.md`, `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/coverage-comparison.<new-timestamp>.md`
   - Expected behavior: each artifact records the actual numeric line/branch coverage percentage read directly from the post-fix `artifacts/pester/powershell-coverage.xml` report-level `<counter type="LINE">`/`<counter type="BRANCH">` (or per-file `<sourcefile>` counters for the four in-scope files), not a value that cannot be located in the artifact by direct text search.
   - Verification command: after regenerating, run `grep -n "<the-cited-figure>" artifacts/pester/powershell-coverage.xml` and confirm a match exists before finalizing the evidence artifact text.

3. **Re-evaluate AC 3 in a follow-up feature-audit.**
   - File: new `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.<new-timestamp>.md` (post-remediation re-review)
   - Expected behavior: AC 3 ("Pester coverage for `enforce-completion-consistency.ps1` passes for the targeted hook test file") is re-evaluated to PASS once the coverage percentage for the in-scope files is confirmed >=85% line / >=75% branch with no regression.

## Do Not Do

- Do not weaken or remove the sentinel/placeholder rejection logic in `Test-IsValidIssueNum`/`Test-IsValidFeatureFolder` to "improve" coverage numbers artificially.
- Do not add the four hook files to `CodeCoverage.Path` in a way that silently drops or renames any of the 15 existing entries.
- Do not mark AC 3 (or the overall feature) PASS without a coverage artifact that actually contains `<sourcefile>` entries for the four in-scope files.
- Do not expand scope to unrelated hook files beyond the four named in Fix 1 and, optionally, their bundled-resource mirrors.
- Do not silently skip re-verifying the cited coverage figures against the regenerated `artifacts/pester/powershell-coverage.xml`; if a cited figure cannot be found via direct text search in the artifact, the evidence artifact is invalid and must be corrected before the cycle can close.

## Addendum: TypeScript Toolchain Failure (user-directed, added before cycle 1 planning began)

**Timestamp:** 2026-07-04T12-00
**Source:** User directive during orchestration, not a `feature-review` finding. Folded into this cycle's inputs because no `remediation-plan` had been authored yet when this was raised.

The user directed that repository-wide TypeScript errors be fixed as part of this orchestration, and that `poetry run python -m scripts.dev_tools.fix_all` must pass before the next `feature-review` run.

**Root cause (already diagnosed; do not re-diagnose):** The root-level TypeScript project (`tsconfig.json` at repo root, covering `src/hello-typescript.ts` and `tests/unit/hello-typescript.test.ts` — a project distinct from `extensions/drm-copilot`, which has its own separate `tsconfig.json`/`tsconfig.jest.json` and was independently confirmed clean) fails `npm run typecheck` with:
- `src/hello-typescript.ts(1,1): error TS2584: Cannot find name 'console'.`
- `tests/unit/hello-typescript.test.ts(5,31): error TS2584: Cannot find name 'console'.`
- `tests/unit/hello-typescript.test.ts(10,5): error TS2591: Cannot find name 'require'.`

Cause: root `tsconfig.json` has no `types` compiler option, and `@types/node` (already a devDependency, already present at `node_modules/@types/node`) was not being picked up for this ambient-global resolution.

**Fix (already verified locally, then reverted by the orchestrator so it goes through the proper delegation/evidence pipeline instead of being applied directly):** add `"types": ["node"]` to `compilerOptions` in the root `tsconfig.json` (immediately after the `"lib": ["ES2022"]` line). Verified this single-line change alone resolves all three errors with `npm run typecheck` exiting 0, without needing to add `"dom"` to `lib` (this is a Node-targeted scaffold, not a browser target) and without needing `@types/jest` (not installed; the test file imports `describe`/`expect`/`it`/`jest` explicitly from `@jest/globals` rather than relying on ambient jest globals).

4. **Add `"types": ["node"]` to the root `tsconfig.json`.**
   - File: `tsconfig.json` (repo root)
   - Expected behavior: `compilerOptions.types` becomes `["node"]`; no other line in the file changes.
   - Verification command: `npm run typecheck` (repo root) exits 0 with no errors; `npm run format:check`, `npm run lint`, and `npm run test:unit` (repo root) also exit 0 (all three were independently confirmed to already pass before this fix — this task must not regress them).
   - Full-repo gate: `poetry run python -m scripts.dev_tools.fix_all` must complete with `Branch Results` showing `PASS` for all five branches (json, shell, python, powershell, typescript) — this was independently confirmed locally after applying the fix above (exit code 0, all five branches PASS).
   - Scope boundary: this task is limited to the one-line `tsconfig.json` change at repo root. It does not touch `extensions/drm-copilot/tsconfig.json` or `extensions/drm-copilot/tsconfig.jest.json`, which are a separate TypeScript project already confirmed clean (`npx tsc -p tsconfig.json --noEmit` exits 0) and out of scope for issue #301.

## Pointer to Audit Artifacts

- `docs/features/active/2026-07-03-pester-completion-consistency-301/policy-audit.2026-07-04T11-15.md`
- `docs/features/active/2026-07-03-pester-completion-consistency-301/code-review.2026-07-04T11-15.md`
- `docs/features/active/2026-07-03-pester-completion-consistency-301/feature-audit.2026-07-04T11-15.md`

## Handoff Note

Per `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, plan authoring for this remediation belongs to `atomic-planner`, preflight and execution to `atomic-executor`, and reaudit to `feature-review`. This `feature-review` session has no subagent-delegation mechanism available in its current toolset, so it cannot directly invoke `atomic-planner` to author `remediation-plan.md`. The orchestrator (or the user) should delegate plan authoring to `atomic-planner` using this file as the remediation-inputs source, per the full handoff chain documented in that skill.
