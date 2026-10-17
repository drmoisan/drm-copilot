# Phase 0 Policy Reads (P0-T1)

Timestamp: 2026-10-07T21-45
Task: [P0-T1]
Policy Order: CLAUDE.md -> .github/copilot-instructions.md -> general code change -> general unit test -> quality tiers -> Python -> PowerShell -> TypeScript -> plan acceptance gates -> tonality

## Files read (in order, from the worktree root)

1. `CLAUDE.md`
2. `.github/copilot-instructions.md`
3. `.claude/rules/general-code-change.md`
4. `.github/instructions/general-code-change.instructions.md`
5. `.claude/rules/general-unit-test.md`
6. `.github/instructions/general-unit-test.instructions.md`
7. `.claude/rules/quality-tiers.md`
8. `.claude/rules/python.md`
9. `.claude/rules/python-suppressions.md`
10. `.github/instructions/python-code-change.instructions.md`
11. `.github/instructions/python-unit-test.instructions.md`
12. `.claude/rules/powershell.md`
13. `.github/instructions/powershell-code-change.instructions.md`
14. `.github/instructions/powershell-unit-test.instructions.md`
15. `.claude/rules/typescript.md`
16. `.claude/rules/typescript-suppressions.md`
17. `.github/instructions/typescript-code-change.instructions.md`
18. `.github/instructions/typescript-unit-test.instructions.md`
19. `.claude/rules/plan-acceptance-gates.md`
20. `.claude/rules/tonality.md`

## Diff base

Command: git merge-base HEAD origin/main
EXIT_CODE: 0
Output Summary: 08ee030d9584bf15882fbb3654c8e38f34c7c359

- Equals planning SHA `43c9e95eaa39b3d896a9da5501cd57953033c2bc`: no.
- The recorded value `08ee030d9584bf15882fbb3654c8e38f34c7c359` is the diff base for every later task (plan Fixed Design Inputs rule).

## Policy files unmodified

Command: git diff --quiet 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- .claude/rules .github/instructions
EXIT_CODE: 0
Output Summary: no difference under `.claude/rules` or `.github/instructions` against the diff base.

## Named plan deviations (execution)

- DEV-1 Diff base: origin/main was merged at f5e96db8 (not rebased). `git merge-base HEAD origin/main` = 08ee030d9584bf15882fbb3654c8e38f34c7c359, which replaces 43c9e95eaa39b3d896a9da5501cd57953033c2bc in every `git diff` in the plan, including this task's policy-file check.
- DEV-2 Upstream drift (43c9e95e..08ee030d): handoff production sources in the write set, the Python taskmaster test and support module, `codex-planning-only-registry.Tests.ps1`, and `.codex/hooks/enforce-epic-planning-only.ps1` are unchanged. Changed: (a) `extensions/drm-copilot/jest.config.cjs` is 398 lines; the P6-T1 insertion point is re-derived before editing. (b) `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` is 311 lines; P3-T9 appends after the last existing `it` and the hunk-header check uses the re-derived last line of that block. (c) `tests/scripts/codex-hooks` has 43 `.ps1` files, not 41. (d) Several not-edited handoff tests changed upstream; the plan's not-edited `git diff --quiet` checks remain valid against 08ee030d.
- DEV-3 P0-T14/P7-T10 ExpectedExitCode: set to the observed P0-T14 exit code; recorded as a deviation if it is not 2.
- DEV-4 PowerShell observation substitution (operator decision 2026-10-01, Option A): PowerShell-expression observations (`(Get-Content -LiteralPath <path>).Count`) are replaced by a non-PowerShell observation (`awk 'END{print NR}'`, which counts newline-terminated lines and matches `Get-Content` line counts for files ending in a newline).
- DEV-5 PoshQC XML evidence: where the local Pester XML cannot satisfy a Pester-output or PowerShell-coverage assertion (P0-T17, P0-T18, P1-T6, P7-T15, P7-T16), the observed state is recorded, the assertion is marked pending CI poshqc evidence, and the task remains unchecked.
- DEV-6 `quality-tiers.yml` now exists (added upstream by a6d2afa6, #734). See the P0-T2 artifact.
