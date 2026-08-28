# Phase 0 — Policy Instructions Read (remediation cycle 2)

Timestamp: 2026-08-28T01-25
Task: [P0-T1]
Cycle: remediation cycle 2, issue #554
Worktree: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d`
Command: Read tool applied to each of the seven policy files below, in the order listed
EXIT_CODE: 0

Policy Order: `CLAUDE.md`, then `.claude/rules/general-code-change.md`, then `.claude/rules/general-unit-test.md`, then `.claude/rules/powershell.md`, then `.claude/rules/quality-tiers.md`, then `.claude/rules/plan-acceptance-gates.md`, then `.claude/rules/tonality.md`.

## Files read, in order

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/quality-tiers.md`
6. `.claude/rules/plan-acceptance-gates.md`
7. `.claude/rules/tonality.md`

All seven paths are relative to the worktree root named above. Each file was read from that
worktree, not from any sibling checkout.

## Blob identities of the files read

| # | Path | `git hash-object` |
| --- | --- | --- |
| 1 | `CLAUDE.md` | `b2f98d4b24af2d39c29fa3833314c46647552ee0` |
| 2 | `.claude/rules/general-code-change.md` | `69d31ef89270b44d8e2ccb5c382513e8de26c71d` |
| 3 | `.claude/rules/general-unit-test.md` | `6b70ee410f0630e3cf8e7e1ef9debf02f2295a1e` |
| 4 | `.claude/rules/powershell.md` | `ce86d6ec36ccf95b2454c27a35edf33e4e53b4c1` |
| 5 | `.claude/rules/quality-tiers.md` | `28209fc80bb0be27446ee72cabc3aa6a59ae2d7e` |
| 6 | `.claude/rules/plan-acceptance-gates.md` | `ea905f5ec6080a4513c3a3fd18c03cbd8458cb08` |
| 7 | `.claude/rules/tonality.md` | `d971f5be28aa02722e216e7fe6b92aec04c40a52` |

## Constraints carried into execution from these reads

- `.claude/rules/powershell.md` — toolchain order is format, analyze, test; **type checking is not
  applicable to PowerShell**. Per-batch cap is 3 production and 3 test PowerShell files. Line
  coverage must remain at or above 85 percent; Pester measures no branch coverage, so no branch
  gate applies. Coverage regression on changed lines is a blocking finding. Test files are named
  `*.Tests.ps1` and mirror source structure. Files stay under 500 lines.
- `.claude/rules/quality-tiers.md` — the 85 percent line threshold is uniform across T1 through T4;
  no tier-specific lower floor exists in this repository.
- `.claude/rules/general-unit-test.md` — tests must be independent, isolated, fast, deterministic,
  and readable. No temporary files. No external services. Test files live under `tests/`.
- `.claude/rules/general-code-change.md` — 500-line file cap; fail fast; no broad catch-alls.
- `.claude/rules/plan-acceptance-gates.md` — this worktree carries the extended G1 through G9 rule
  set (G7 through G9 added by issue #519). All of G5 through G9 ship in the Warning channel.
- `.claude/rules/tonality.md` and `CLAUDE.md` — professional, factual, neutral tone; no humour, no
  hyperbole, no decorative metaphor; evidence-first wording.

Output Summary: All seven policy files were read from the target worktree in the mandated order and
their blob identities recorded. No policy file was modified. EXIT_CODE 0.
