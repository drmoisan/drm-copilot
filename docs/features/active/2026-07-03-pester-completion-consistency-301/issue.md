# pester-completion-consistency (Issue #301)

- Date captured: 2026-07-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pester-completion-consistency/ (Issue #301)

- Issue: #301
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/301
- Last Updated: 2026-07-04
- Work Mode: minor-audit

## Problem / Why

The Codex completion-consistency hook resource is behind the Claude hook implementation. The local `.codex` hook and bundled Codex resource copy do not include the helper-backed validation logic used by the `.claude` hook, and the Codex helper file is missing. This can cause repeated hook failures and Pester failures when tests or runtime hooks exercise the Codex surface.

## Proposed Behavior

The Codex completion-consistency hook should use the same helper-backed validation behavior and PreToolUse decision shape as the Claude hook. The bundled Codex customization resource should include every helper file required by the hook so a new Codex worktree session receives a runnable hook copy.

## Acceptance Criteria

- [x] The bundled Codex `enforce-completion-consistency.ps1` resource emits `hookSpecificOutput.permissionDecision` values that match the tested Claude hook behavior.
- [x] The bundled Codex customization resource includes `enforce-completion-helpers.ps1`, and the local `.codex` runtime copy is updated for this worktree.
- [ ] Pester coverage for `enforce-completion-consistency.ps1` passes for the targeted hook test file. (Re-evaluated PARTIAL in remediation cycle 1, see `feature-audit.2026-07-04T12-00.md`: `.claude/hooks/enforce-completion-consistency.ps1` and `.claude/hooks/enforce-completion-helpers.ps1` now show real >=85% line coverage, but `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` show 0.00% real line coverage because no test dot-sources those canonical paths; unchecked pending a follow-up cycle.)
- [x] The repository PowerShell quality loop runs through format, analyzer, and Pester without the reported command-resolution failure.

## Constraints & Risks

- Keep the fix scoped to hook parity and test-runner reliability.
- Do not weaken completion evidence validation.
- Preserve the existing Claude hook behavior.

## Test Conditions to Consider

- [ ] Empty and malformed tool input.
- [ ] Write and Edit tool payloads for `artifacts/orchestration/orchestrator-state.json`.
- [ ] Route-driven `pr_gate` enforcement.
- [ ] Codex bundled resource copy includes all dot-sourced dependencies.

## Next Step

- [x] Promote to GitHub issue.
- [x] Create active feature folder.
- [x] Produce and execute the minimal-audit plan.

Outcome: the minimal-audit plan (`docs/features/active/2026-07-03-pester-completion-consistency-301/plan.2026-07-03T22-46.md`) executed Phase 0 through Phase 4. Parity diffs (Phase 3) found the `.codex` local hook/helper files and the bundled Codex resource copies already byte-for-byte identical to their `.claude/hooks` counterparts, so no edit was required; the fix was already staged correctly in the working tree. All 51 targeted Pester tests pass and the full 476-test `tests/scripts/claude-hooks/` suite passes with 0 errors/0 failures. Evidence: `evidence/baseline/phase0-instructions-read.2026-07-03T22-46.md`, `evidence/regression-testing/fail-before-exception.2026-07-03T22-46.md`, `evidence/regression-testing/regression-test-run.2026-07-03T22-46.md`, `evidence/qa-gates/final-powershell-full-suite.2026-07-03T22-46.md`.

### Remediation Cycle 1 Outcome (2026-07-04T12-00)

Remediation plan `remediation-plan.2026-07-04T12-00.md` closed the `CodeCoverage.Path` gap and the root `tsconfig.json` TypeScript typecheck failure:

- **Fix 1 (`CodeCoverage.Path` gap):** Added the four in-scope hook files to `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`'s `CodeCoverage.Path` array (16 pre-existing entries preserved unchanged, 4 new entries added, 20 total). Evidence: `evidence/remediation-baseline/baseline-codecoverage-path-entries.2026-07-04T12-00.md`, `evidence/other/codecoverage-path-diff.2026-07-04T12-00.md`.
- **Fix 2 (coverage rerun):** Regenerated `artifacts/pester/powershell-coverage.xml` with the updated `CodeCoverage.Path`. All four in-scope files now appear as `<sourcefile>` entries (previously absent). Real per-file line coverage: `.claude/hooks/enforce-completion-consistency.ps1` = 91.87%, `.claude/hooks/enforce-completion-helpers.ps1` = 93.02% (both above the 85% floor); `.codex/hooks/enforce-completion-consistency.ps1` = 0.00%, `.codex/hooks/enforce-completion-helpers.ps1` = 0.00% (below the floor — no test dot-sources the canonical `.codex/hooks/` path; the existing Codex test exercises the bundled-extension mirror path instead). No regression on the 16 pre-existing entries. Evidence: `evidence/qa-gates/coverage-comparison.2026-07-04T12-00.md`.
- **Fix 3 (AC 3 re-evaluation):** Re-evaluated to **PARTIAL**, not PASS — see `feature-audit.2026-07-04T12-00.md`. The AC 3 checkbox above is left unchecked pending a follow-up remediation cycle that retargets `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` to the canonical `.codex/hooks/` path (or documents an explicit parity exception), which was outside this cycle's declared scope.
- **Fix 4 (`tsconfig.json` fix):** Added `"types": ["node"]` to `compilerOptions` (one line). `npm run typecheck`, `format:check`, `lint`, and `test:unit` all pass. Evidence: `evidence/other/tsconfig-diff.2026-07-04T12-00.md`, `evidence/qa-gates/final-typescript-typecheck.2026-07-04T12-00.md`, `evidence/qa-gates/final-typescript-format.2026-07-04T12-00.md`, `evidence/qa-gates/final-typescript-lint.2026-07-04T12-00.md`, `evidence/qa-gates/final-typescript-test.2026-07-04T12-00.md`.
- **Final gate:** `poetry run python -m scripts.dev_tools.fix_all` reports PASS for all five branches (json, shell, python, powershell, typescript). Root-cause analysis confirmed the pre-fix json/python/powershell "FAIL"s were cascading cancellations triggered by the typescript branch's real `tsc` failure, resolved by Fix 4. Evidence: `evidence/remediation-baseline/baseline-fix-all.2026-07-04T12-00.md`, `evidence/qa-gates/final-fix-all.2026-07-04T12-00.md`.

Phase 0 (baseline) evidence: `evidence/remediation-baseline/`. Phase 2 (coverage comparison) evidence: `evidence/qa-gates/coverage-comparison.2026-07-04T12-00.md`. Phase 6 (full-repo gate) evidence: `evidence/qa-gates/final-fix-all.2026-07-04T12-00.md`.
