# Remediation Inputs: require-pr-author-agent-for-prs (#231)

## Authoritative Source

- This file is the authoritative remediation requirements source for the review run dated `2026-06-24T15-59`.
- Base branch: `main` (merge-base `258aa903542346cc534c03da39e4b938223c1f2d`)
- Branch head: `0beb721d21c86ed944cc1090bae5085f595ea936`
- Feature folder: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`

## Blocking Findings Summary

- **F-1 (Blocking):** `gh pr edit --body "inline"` is allowed by `enforce-pr-author-skill.ps1`, contradicting AC3, spec FR-2 step 4, FR-4, and the `pr-author` agent documentation, which all state that inline `--body` on `gh pr edit` is blocked by Case A. The Case A inline-body guard is scoped to `isPrCreate` only; the edit path falls through every guard and returns allow. No test exercises this path. This is a pre-existing baseline condition, but the feature documents and asserts the path is closed.

## Fix List

1. **Block inline `--body` on `gh pr edit` (close F-1).**
   - Affected files (apply identical fix to all three):
     - `.claude/hooks/enforce-pr-author-skill.ps1`
     - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`
     - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (preserve the `# Converted hook` header)
   - Expected behavior: `gh pr edit <n> --body "inline text"` and the equals-form `gh pr edit <n> --body='inline'` must be blocked with `PR_AUTHOR_SKILL_BLOCKED` (the Case A reason), the same as `gh pr create` inline body. The `--body-file` + context + sentinel path for `gh pr edit` must remain unchanged. `gh pr edit --title`/`--add-label` (no body flag) must remain allowed.
   - Suggested approach (in `Get-PrAuthorBypassReason`): evaluate the inline-body block (`$hasInlineBody -and -not $hasBodyFile`) for both `isPrCreate` and `isPrEdit` before the edit no-body short-circuit, so an inline-body edit is blocked before reaching the no-body allow path.
   - Cross-ecosystem requirement: after the fix, the root and bundled Claude hooks must remain byte-identical, and the Codex hook must remain identical to root apart from the converted-hook header.
   - Verification commands:
     - `mcp__drm-copilot__run_poshqc_format` (scan folders covering all changed `.ps1`)
     - `mcp__drm-copilot__run_poshqc_analyze` (same scan folders)
     - `mcp__drm-copilot__run_poshqc_test` (scan folder `tests/scripts/claude-hooks`)
     - `diff` the root vs bundled vs Codex hooks to confirm parity.

2. **Add tests for inline `--body` on `gh pr edit` (close the AC5/US5 gap).**
   - Affected file: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
   - Expected behavior: add `It` cases asserting that `gh pr edit 42 --body "inline text"` and `gh pr edit 42 --body='inline'` are blocked with `PR_AUTHOR_SKILL_BLOCKED`, and a regression case confirming `gh pr edit 42 --title "x"` (no body flag) remains allowed. Tests must use the existing seam mocks (no temp files, no real `gh`, no wall-clock).
   - Verification command:
     - `mcp__drm-copilot__run_poshqc_test` (scan folder `tests/scripts/claude-hooks`); confirm 0 failures and that coverage on `enforce-pr-author-skill.ps1` remains line >= 85%.

3. **Refresh evidence and acceptance criteria after the fix.**
   - Affected files:
     - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/regression-testing/backward-compat.md` (add the inline-edit case row)
     - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/evidence/qa-gates/final-pester.md` and `coverage-delta.md` (refresh test counts/coverage)
     - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/spec.md` and `user-story.md` (AC3/AC5 and US3/US5)
   - Expected behavior: AC3, AC5, US3, and US5 may remain checked `[x]` only after the implementation blocks inline `--body` on `gh pr edit` and the new tests pass. Until then they do not reflect verified behavior.
   - Verification command:
     - inspect `spec.md` / `user-story.md` and the refreshed evidence after the fix; rerun the policy/feature audit clauses for AC3/AC5/US3/US5.

## Required Context Package

- Original feature plan: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/plan.2026-06-24T15-17.md`
- Review artifacts (this run):
  - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/policy-audit.2026-06-24T15-59.md`
  - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/code-review.2026-06-24T15-59.md`
  - `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/feature-audit.2026-06-24T15-59.md`
- PR context artifacts:
  - `artifacts/pr_context.summary.txt`
  - `artifacts/pr_context.appendix.txt`
- Spec references: `spec.md` Section 1 (Case A definition), FR-2 step 4, FR-4, AC3.

## Do Not Do

- Do not weaken or remove Cases A/B/C/D/E/F to make tests pass.
- Do not introduce temporary files, real `gh` calls, `Start-Sleep`, or wall-clock reads in tests.
- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not diverge the bundled Claude mirror from root, or the Codex hook body from root (beyond the converted-hook header).
- Do not describe the sentinel as tamper-proof or a security boundary in any documentation.
