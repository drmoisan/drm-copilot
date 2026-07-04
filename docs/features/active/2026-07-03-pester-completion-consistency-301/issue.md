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
- [x] Pester coverage for `enforce-completion-consistency.ps1` passes for the targeted hook test file.
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
