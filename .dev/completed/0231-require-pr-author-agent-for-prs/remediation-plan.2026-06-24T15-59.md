# Remediation Plan: require-pr-author-agent-for-prs (#231)

- Review run: `2026-06-24T15-59`
- Authoritative source: `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/remediation-inputs.2026-06-24T15-59.md`
- Target blocking finding: **F-1** — inline `--body` on `gh pr edit` is allowed by `enforce-pr-author-skill.ps1`; the Case A inline-body guard is scoped to `gh pr create` (`$isPrCreate`) only, so an inline-body edit falls through every guard and returns allow. This contradicts AC3, spec FR-2 step 4 / FR-4, and the `pr-author` agent documentation. The AC5/US5 inline-edit-body test is missing.
- Feature folder (`<FEATURE>`): `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231`
- Evidence root: `<FEATURE>/evidence/<kind>/` (canonical; see `evidence-and-timestamp-conventions`). No `artifacts/` evidence sub-paths are permitted.

## Scope and Constraints

- Languages in scope: PowerShell only.
- PowerShell per-batch cap: at most 3 production files and 3 test files. This plan touches exactly 3 production `.ps1` copies and 1 test file, which is within the cap. Implementation is a single batch.
- The three production copies must remain in parity after the fix:
  - root `.claude/hooks/enforce-pr-author-skill.ps1`,
  - bundled `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` (byte-identical to root),
  - Codex `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (identical to root apart from the leading `# Converted hook` / review-comment header).
- Preserve behavior NOT in scope of the fix:
  - `gh pr edit` with NO body flags (`--title`, `--add-label`, `--reviewer`) must remain allowed.
  - Case A for `gh pr create` (unchanged behavior), Case B, Case C, and the sentinel Cases D/E/F and Malformed must remain unchanged.
- Do not weaken existing assertions. Do not introduce temp files, real `gh` calls, `Start-Sleep`, or wall-clock reads in tests. Do not modify policy documents under `.claude/rules/` or `.github/instructions/`. Do not describe the sentinel as tamper-proof or a security boundary.
- Each PowerShell production/test batch runs the full PoshQC toolchain (format -> analyze -> test). Restart from format if any stage changes files or fails.

## Verified Current Structure (pre-edit confirmation)

`Get-PrAuthorBypassReason` in all three copies currently has this control flow:

1. `$isPrCreate` / `$isPrEdit` regex match; early return `$null` if neither.
2. `$hasBodyFile` / `$hasInlineBody` regex flags.
3. `if ($isPrCreate) { Case A inline-body block; Case B no-body block }`.
4. `if ($isPrEdit) { if no inline body and no body-file -> return $null (allow) }`.
5. Case C: `--body-file` present but context absent -> block.
6. Cases D/E/F + Malformed: `--body-file` present and context present -> sentinel check.
7. Fallthrough `return $null`.

Root structure begins at line 202; bundled copy begins at line 202; Codex copy is offset by the 2-line `# Converted hook` header (structure begins at line ~205). The exact current text MUST be re-read in this conversation before each Edit, because preflight tracks file state.

## Fix Approach (to be confirmed against current text before editing)

Extend the inline-body block so it applies to BOTH `gh pr create` AND `gh pr edit` when inline `--body` is present without `--body-file`, evaluated BEFORE the `gh pr edit` no-body allow short-circuit. The minimal change is to add a guard that blocks `($isPrCreate -or $isPrEdit) -and $hasInlineBody -and -not $hasBodyFile` with the Case A `PR_AUTHOR_SKILL_BLOCKED` reason, placed before the existing `if ($isPrEdit)` no-body allow path. Case B remains scoped to `gh pr create` only. The `--body-file` + context + sentinel path and the no-body-flag edit allow path remain unchanged. The implementing engineer must verify the exact current block layout per copy and choose the smallest edit that satisfies these constraints.

---

### Phase 0 — Baseline Capture and Policy Reading

- [x] [P0-T1] Read the policy files in required order and record an evidence artifact at `<FEATURE>/evidence/baseline/phase0-instructions-read.md`. Artifact MUST include `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`. Acceptance: artifact exists with all three required fields populated.
- [x] [P0-T2] Read and record the exact current content of `Get-PrAuthorBypassReason` in all three hook copies (root `.claude/hooks/enforce-pr-author-skill.ps1`, bundled `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`, Codex `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`) into `<FEATURE>/evidence/remediation-baseline/hook-structure-baseline.md`. Artifact MUST include `Timestamp:` and, per file, the line range of the function and the inline-body/no-body guard text. Acceptance: artifact records the current guard structure for all three copies.
- [x] [P0-T3] Confirm baseline byte-equality of root vs bundled hook and Codex-vs-root parity (root identical to Codex except the `# Converted hook` header) and record the result at `<FEATURE>/evidence/remediation-baseline/baseline-parity.md`. Artifact MUST include `Timestamp:`, `Command:` (the comparison commands used), `EXIT_CODE:`, and `Output Summary:` stating whether root==bundled and Codex==root-minus-header. Acceptance: artifact records the pre-fix parity state.
- [x] [P0-T4] Capture the baseline PoshQC format result over the scan folders covering all changed `.ps1` files (`.claude/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks`, `tests/scripts/claude-hooks`) via `mcp__drm-copilot__run_poshqc_format`. Record at `<FEATURE>/evidence/remediation-baseline/baseline-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields.
- [x] [P0-T5] Capture the baseline PoshQC analyze result over the same scan folders via `mcp__drm-copilot__run_poshqc_analyze`. Record at `<FEATURE>/evidence/remediation-baseline/baseline-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: artifact exists with all four fields.
- [x] [P0-T6] Capture the baseline PoshQC test result with coverage over scan folder `tests/scripts/claude-hooks` via `mcp__drm-copilot__run_poshqc_test`. Record at `<FEATURE>/evidence/remediation-baseline/baseline-test.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including the numeric baseline test counts (pass/fail) and the baseline line-coverage percent for `enforce-pr-author-skill.ps1`. Acceptance: artifact records numeric coverage headline (not a placeholder).

### Phase 1 — Block Inline `--body` on `gh pr edit` (Production + Tests, single batch)

- [x] [P1-T1] Edit root `.claude/hooks/enforce-pr-author-skill.ps1` `Get-PrAuthorBypassReason` so the inline-body block (`$hasInlineBody -and -not $hasBodyFile`) applies to both `$isPrCreate` and `$isPrEdit`, evaluated before the `gh pr edit` no-body allow short-circuit, returning the Case A `PR_AUTHOR_SKILL_BLOCKED` reason. Acceptance: `gh pr edit 42 --body "inline"` and `gh pr edit 42 --body='inline'` return the Case A reason; `gh pr edit 42 --title "x"` (no body flag), Case B (create-only), Case C, and Cases D/E/F/Malformed are unchanged in the file text.
- [x] [P1-T2] Apply the identical fix to bundled `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1` so it remains byte-identical to the root copy. Acceptance: bundled file matches root byte-for-byte after the edit.
- [x] [P1-T3] Apply the identical fix to Codex `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1`, preserving the leading `# Converted hook` review-comment header. Acceptance: Codex file is identical to root except for the converted-hook header lines.
- [x] [P1-T4] Add an `It` case to `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` asserting `gh pr edit 42 --body "inline text"` (no `--body-file`) is BLOCKED with `PR_AUTHOR_SKILL_BLOCKED`, using the existing seam mocks (no temp files, no real `gh`, no wall-clock). Acceptance: new `It` passes against the fixed hook and exercises the inline-edit-body path (AC5/US5 coverage).
- [x] [P1-T5] Add an `It` case to the same test file asserting `gh pr edit 42 --body='inline'` (equals-form, no `--body-file`) is BLOCKED with `PR_AUTHOR_SKILL_BLOCKED`. Acceptance: new `It` passes against the fixed hook.
- [x] [P1-T6] Add a regression `It` case to the same test file confirming `gh pr edit 42 --title "x"` (no body flag) remains ALLOWED, and confirm the pre-existing `gh pr edit --add-label`/`--title` and `--body-file`+sentinel allow cases still pass without weakening any assertion. Acceptance: new regression `It` passes and no existing assertion is modified or removed.
- [x] [P1-T7] Run the PoshQC toolchain for this batch in order: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` (scan folders covering all changed `.ps1`), then `mcp__drm-copilot__run_poshqc_test` (scan folder `tests/scripts/claude-hooks`). Restart from format if any stage changes files or fails. Record the loop result at `<FEATURE>/evidence/qa-gates/phase1-poshqc-loop.md` with `Timestamp:`, `Command:` (each stage), `EXIT_CODE:` (each stage), and `Output Summary:`. Acceptance: all three stages pass in a single pass with 0 test failures.

### Phase 2 — Final QA Loop, Coverage Verification, Parity, and Evidence/AC Refresh

- [x] [P2-T1] Run the final PoshQC format stage `mcp__drm-copilot__run_poshqc_format` over the scan folders covering all changed `.ps1` files. Record at `<FEATURE>/evidence/qa-gates/final-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: format reports a clean pass; if it changes files, restart the loop.
- [x] [P2-T2] Run the final PoshQC analyze stage `mcp__drm-copilot__run_poshqc_analyze` over the same scan folders. Record at `<FEATURE>/evidence/qa-gates/final-analyze.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: 0 analyzer findings.
- [x] [P2-T3] Run the final PoshQC test stage with coverage `mcp__drm-copilot__run_poshqc_test` over scan folder `tests/scripts/claude-hooks`. Record at `<FEATURE>/evidence/qa-gates/final-pester.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:` including post-change numeric test counts (pass/fail) and the post-change line-coverage percent for `enforce-pr-author-skill.ps1`. Acceptance: 0 test failures and numeric coverage recorded.
- [x] [P2-T4] Verify line coverage for `enforce-pr-author-skill.ps1` remains line >= 85% with no regression on changed lines, comparing the baseline (`<FEATURE>/evidence/remediation-baseline/baseline-test.md`) and post-change (`final-pester.md`) values. Record the delta at `<FEATURE>/evidence/qa-gates/coverage-delta.md` reporting baseline coverage, post-change coverage, and changed-line coverage. Acceptance: post-change line coverage >= 85% and no regression on changed lines; otherwise the plan outcome is remediation-required.
- [x] [P2-T5] Verify cross-ecosystem parity after the fix: root vs bundled hook byte-identical, and Codex hook identical to root apart from the converted-hook header. Record at `<FEATURE>/evidence/qa-gates/final-parity.md` with `Timestamp:`, `Command:` (the comparison commands), `EXIT_CODE:`, and `Output Summary:` stating root==bundled and Codex==root-minus-header. Acceptance: parity holds for all three copies.
- [x] [P2-T6] Update `<FEATURE>/evidence/regression-testing/backward-compat.md` to add the inline-edit-body case row (`gh pr edit --body "inline"` -> blocked, Case A) and confirm the `gh pr edit --title` allowed row. Acceptance: the inline-edit-body blocked row and the no-body-flag allowed row are both present and reflect verified post-fix behavior.
- [x] [P2-T7] Correct the prematurely-checked acceptance criteria in `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/spec.md` (AC3, AC5) and `docs/features/active/2026-06-24-require-pr-author-agent-for-prs-231/user-story.md` (US3, US5) so they reflect verified behavior only after the fix and passing tests. Note: these items were checked `[x]` before inline `gh pr edit --body` was actually blocked and before the inline-edit-body test existed; they may remain `[x]` only because P1 (block) and P1-T4/T5 (tests) and P2 (coverage/parity) now establish the behavior. Acceptance: AC3/AC5 in spec.md and US3/US5 in user-story.md are reconciled against the post-fix verified state with no unverified `[x]` remaining.
