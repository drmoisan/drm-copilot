# Phase 0 policy-read evidence — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T1]
Feature: 2026-08-29-blast-radius-powershell-calling-convention-598
Work Mode: full-bug (sole acceptance-criteria source is `spec.md`; `user-story.md` is absent by design)

Policy Order: the order defined by `.claude/skills/policy-compliance-order/SKILL.md`, extended by
`[P0-T1]` of `plan.2026-08-29T16-05.md` to include `quality-tiers.md`, `tonality.md`, and
`plan-acceptance-gates.md`:

1. `CLAUDE.md` (standing instructions)
2. `.claude/rules/general-code-change.md` (cross-language code change policy)
3. `.claude/rules/general-unit-test.md` (cross-language unit test policy)
4. `.claude/rules/powershell.md` (language-specific: PowerShell is the change surface)
5. `.claude/rules/quality-tiers.md` (tier system and uniform coverage thresholds)
6. `.claude/rules/tonality.md` (communication tone policy)
7. `.claude/rules/plan-acceptance-gates.md` (acceptance-gate rules G1 through G9)

## Files read

All paths are repo-relative to the workspace root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7`.
Line counts were derived with
`pwsh -NoProfile -Command "@(<paths>) | ForEach-Object { '{0}|{1}' -f $_, @(Get-Content -LiteralPath $_).Count }"`.

| # | Path | Lines |
| --- | --- | --- |
| 1 | `CLAUDE.md` | 56 |
| 2 | `.claude/rules/general-code-change.md` | 80 |
| 3 | `.claude/rules/general-unit-test.md` | 105 |
| 4 | `.claude/rules/powershell.md` | 97 |
| 5 | `.claude/rules/quality-tiers.md` | 51 |
| 6 | `.claude/rules/tonality.md` | 80 |
| 7 | `.claude/rules/plan-acceptance-gates.md` | 257 |

Seven of seven files read in full.

## Constraints extracted that bind this feature

- `.claude/rules/general-code-change.md:49` — no production, test, or reusable script file may exceed
  500 lines. `DiscoveryValidation.psm1` is at that cap and requires condensation before insertion.
- `.claude/rules/powershell.md:20` — toolchain order is format, then analyze, then test; restart from
  step 1 if any step fails or changes files.
- `.claude/rules/powershell.md:40` — per-batch cap of 3 production files and 3 test files unless an
  explicit override has been approved. No override has been approved for this feature.
- `.claude/rules/powershell.md:95` — weakening assertions merely to make tests pass is prohibited.
- `.claude/rules/general-unit-test.md:23` and `.claude/rules/quality-tiers.md:33` — line coverage must
  remain at or above 85%. Pester measures no branch coverage, so no branch gate applies
  (`.claude/rules/powershell.md:64`).
- `.claude/rules/general-unit-test.md:73` — creation and use of temporary files in tests is
  prohibited.
- `.claude/rules/tonality.md` — professional, factual, neutral tone in all authored content,
  including these artifacts.
- `.claude/rules/plan-acceptance-gates.md` — G1 through G9; read for acceptance-condition
  interpretation. This feature authors no plan, so the gates are consumed rather than applied.

EXIT_CODE: 0

Output Summary: Seven policy files read in the stated order, with line counts recorded above.
No policy file was modified.
