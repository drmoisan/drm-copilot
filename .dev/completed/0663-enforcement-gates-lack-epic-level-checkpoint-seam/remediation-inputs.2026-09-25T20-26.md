# Remediation Inputs: #663 Epic-Level Checkpoint Seam

**Timestamp:** 2026-09-25T20-26
**Branch:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` at `ac8ef840`; base `origin/main` `d754f83f`
**Source artifacts:**
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/policy-audit.2026-09-25T20-26.md`
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/code-review.2026-09-25T20-26.md`
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/feature-audit.2026-09-25T20-26.md`

## Remediation-Required Findings

### R1 (Blocking) — CR-1: staging exemption admits a redirection through a backslash-escaped double quote

- **Files:** `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:110-152` and its three byte-identical copies (`.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`).
- **Defect:** `Test-OrchestrationCommandTextUnresolvable` closes a double-quoted span at `\"`. The line `git add docs/features/active/x/a.md && git commit -m "a\"" > src/prod.ts "\"" docs/features/active/x/a.md` is classified exempt, while a POSIX shell performs the `> src/prod.ts` redirection. `origin/main` denied this line.
- **Required change (consistent with D4, no escape modelling):** return `$true` (unresolvable) when a backslash occurs inside a double-quoted span, or when any backslash is immediately followed by `"` or `'`. Correct the `.DESCRIPTION` text at lines 115-120.
- **Required tests (both `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`):** deny rows for the escaped-quote redirection form and for the escaped-quote chain-operator form (`git commit -m "x\"" ; <cmd> ; "\"" -- <exempt path>`); keep all existing D4 and #663 rows passing.
- **Gates:** parity suite (SHA-256 identity of four copies), `legacy-codex-hook-contracts.Tests.ps1`, full PoshQC format/analyze/test with coverage, line coverage >= 85% and no regression for the helpers file.

### R2 (Recommended, same remediation) — CR-2: text branch signal overrides the `-C` selector for the D2 probe

- **File:** `.claude/lib/worktree-resolution/EpicScopeResolution.psm1:336-355` (caller `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:116-117`).
- **Required change:** when `-MatchWorktreeHead` is set, decide the matched branch and the `MERGE_HEAD` probe from the effective worktree (selector, else session root) rather than from a text branch signal, or require both to agree.
- **Required test:** a gate-4 row with a `-C` selector whose HEAD is not `integration_branch` and a command text carrying `branch: <integration_branch>` must not be allowed by the epic path.
- **Gates:** mirror copy, manifest SHA test, coverage >= 85% for the module.

## Optional Items (may be tracked as follow-ups)

- CR-4: mock `Get-EpicScopeCheckpointText` to `$null` in the fixtures of pre-existing gate suites so local gitignored epic state cannot change their outcome.
- CR-5: update the modes-file PURITY header (follow-up 3 in `evidence/other/follow-ups.md`).
- Regenerate PR context against `origin/main` before pr-author; confirm CI green on the remediated head; perform the manual #655 rerun.

## Constraints for the Remediation Plan

- Do not reopen D1-D5. The R1 fix is fail-closed and does not model escapes.
- Batch cap: three production and three test PowerShell files per batch; mirrors byte-copied after each batch.
- No test may create files, read live git state, reference `origin/main`, or use drive-rooted host paths.
