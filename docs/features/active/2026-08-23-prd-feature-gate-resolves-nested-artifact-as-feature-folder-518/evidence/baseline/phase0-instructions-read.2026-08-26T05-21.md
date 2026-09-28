# Phase 0 Policy Read Evidence — [P0-T1]

Timestamp: 2026-08-26T05-21

Task: [P0-T1]
Plan: `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/plan.2026-08-23T23-22.md`
Work Mode: `full-bug` (AC source is `spec.md`; `user-story.md` is correctly absent)
Workspace root: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a931fa47c98f755c3`

## Policy Order

The order below is the order fixed by `CLAUDE.md` ("Policy Compliance Reading Order") layered with
`.claude/rules/powershell.md` for the PowerShell files in scope, and is the order the plan task
[P0-T1] states. Files were read top to bottom in this sequence.

1. `.github/copilot-instructions.md` — repository tone and communication policy
2. `.github/instructions/general-code-change.instructions.md` — baseline code change rules
3. `.github/instructions/general-unit-test.instructions.md` — baseline unit test rules
4. `.github/instructions/powershell-code-change.instructions.md` — PowerShell code change rules
5. `.github/instructions/powershell-unit-test.instructions.md` — PowerShell unit test rules
6. `.claude/rules/tonality.md` — mirrored tone policy
7. `.claude/rules/general-code-change.md` — mirrored cross-language code change policy
8. `.claude/rules/general-unit-test.md` — mirrored cross-language unit test policy
9. `.claude/rules/powershell.md` — PowerShell toolchain and coding standards
10. `.claude/rules/quality-tiers.md` — module rigor tiers and coverage thresholds
11. `.claude/rules/plan-acceptance-gates.md` — acceptance-gate rules G1 through G6

## Files Read (explicit list, in order)

| # | Path | Read |
| --- | --- | --- |
| 1 | `.github/copilot-instructions.md` | yes |
| 2 | `.github/instructions/general-code-change.instructions.md` | yes |
| 3 | `.github/instructions/general-unit-test.instructions.md` | yes |
| 4 | `.github/instructions/powershell-code-change.instructions.md` | yes |
| 5 | `.github/instructions/powershell-unit-test.instructions.md` | yes |
| 6 | `.claude/rules/tonality.md` | yes |
| 7 | `.claude/rules/general-code-change.md` | yes |
| 8 | `.claude/rules/general-unit-test.md` | yes |
| 9 | `.claude/rules/powershell.md` | yes |
| 10 | `.claude/rules/quality-tiers.md` | yes |
| 11 | `.claude/rules/plan-acceptance-gates.md` | yes |

Every path above was read in full from this workspace root. No policy file was modified.

## Constraints Extracted That Bind This Plan

- PowerShell has no type-checking stage. The toolchain loop is format, then analyze, then test,
  restarting from format on any failure or auto-fix
  (`.claude/rules/powershell.md`, `.github/instructions/powershell-code-change.instructions.md`).
- The PowerShell toolchain must be driven through the MCP server functions
  (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`), not VS Code task wrappers.
- Line coverage must remain at or above 85 percent. No branch-coverage gate applies to PowerShell,
  because Pester does not measure branch coverage (`.claude/rules/quality-tiers.md`,
  `.claude/rules/general-unit-test.md`).
- No production, test, or reusable script file may exceed 500 lines. This governs the [P1-T1]
  placement decision for the 25 new `It` blocks.
- Test files live under `tests/` mirroring the production tree; colocation is prohibited.
- Temporary files in tests are prohibited.
- The bugfix workflow applies: failing regression test first, then the minimal targeted fix, then
  local verification. This is the structure Phases 1 through 3 of the plan follow.
- Policy documents under `.claude/rules/` and `.github/instructions/` must not be modified. The
  plan's Declared write set contains no such file.

## Result

Policy reading complete. No conflicting instruction was found between the `.github/instructions/`
originals and the `.claude/rules/` mirrors for any rule that binds this plan.
