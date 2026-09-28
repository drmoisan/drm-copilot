# Phase 0 — Baseline Per-File Line Coverage, In-Scope Production Copies

Timestamp: 2026-09-07T10-57

Task: [P0-T9]

Command: `python scratchpad/perfile_coverage.py` — package-qualified selection over `artifacts/pester/powershell-coverage.xml`, the report emitted by the same run recorded in [P0-T7]

EXIT_CODE: 0

## Source run

This artifact reads the report produced by the [P0-T7] run. No additional test run was performed, as
the plan requires ("From the same self-hosted run as [P0-T7]"). The route deviation disclosed in
[P0-T7] applies here unchanged: the mandated `pwsh` invocation was refused by the runtime
worktree-isolation guard, the MCP route produced the report, and the report's denominator was
verified element-for-element against this checkout's own 88-entry `CodeCoverage.Path` set (0 missing,
0 extra).

## Selection method

Each percentage is read by the **package-qualified** selection the measurement contract requires:
the `counter` element whose `type` is `LINE`, on the `sourcefile` element whose `name` equals the
bare filename, selected within the enclosing `package` element whose `name` ends with that file's
directory. A bare-filename lookup would be ambiguous, because `validate-bash.ps1`,
`enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, and
`enforce-orchestration-preimplementation-gate-helpers.ps1` each occur under both `.claude/hooks` and
`.codex/hooks` in this report. The exact element path used for every measured file is recorded in
the third column so the selection is reproducible.

Percentage = `covered / (covered + missed)` on the selected `counter`.

For every canonical file reported as absent, the script additionally asserted that the path does not
appear in the `CodeCoverage.Path` list of
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. The assertion held for all four, so
"absent" means "not declared", not "declared but unmeasured".

## Per-file table (one line per in-scope production copy, 28 rows)

| Path | Baseline line coverage | Element path |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 88.0000% (covered=132, missed=18) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-orchestration-preimplementation-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 84.5679% (covered=137, missed=25) | `report/package[@name='<ROOT>/.codex/hooks']/sourcefile[@name='enforce-orchestration-preimplementation-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 92.1569% (covered=47, missed=4) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-promotion-mcp-only.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | absent from CodeCoverage.Path at baseline | n/a |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.4286% (covered=108, missed=4) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-epic-merge-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | absent from CodeCoverage.Path at baseline | n/a |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 95.6989% (covered=89, missed=4) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-epic-worktree-removal-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | absent from CodeCoverage.Path at baseline | n/a |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/validate-bash.ps1` | 90.3846% (covered=47, missed=5) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='validate-bash.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.codex/hooks/validate-bash.ps1` | absent from CodeCoverage.Path at baseline | n/a |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 95.3125% (covered=61, missed=3) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-pr-author-skill-helpers.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 94.1176% (covered=64, missed=4) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-parallel-worktree-removal-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 91.4894% (covered=43, missed=4) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-parallel-abandon-gate.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 91.3043% (covered=21, missed=2) | `report/package[@name='<ROOT>/.claude/hooks']/sourcefile[@name='enforce-pr-author-skill.epic-base-branch.ps1']/counter[@type='LINE']` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash | n/a |

`<ROOT>` above abbreviates
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31`. The `package`
`name` attribute in the emitted report carries that absolute prefix verbatim.

## Row accounting

- 28 rows, one per in-scope production copy.
- 10 rows carry a numeric percentage attributed to a package-qualified element path.
- 14 rows carry the bundle-mirror literal (every mirror under `extensions/drm-copilot/resources/`).
- 4 rows carry the absent-from-list literal: `.codex/hooks/enforce-promotion-mcp-only.ps1`,
  `.codex/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`,
  and `.codex/hooks/validate-bash.ps1`.

10 + 14 + 4 = 28.

## Two conditions recorded because they bind later phases

1. **`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at 84.5679% at baseline,
   which is below the uniform 85% line-coverage threshold.** The file is in scope and will be
   modified, so the post-change gate applies to it. The shortfall is pre-existing and is not created
   by this change, but it is not waived by being pre-existing: the file must reach at least 85% by
   the time the coverage gate is evaluated. Raising it requires either new Codex-side scenarios (in a
   **new** test file, because `legacy-codex-hook-contracts.Tests.ps1` is at 494 of 500 lines) or a
   reduction in its uncovered line count. This is the single largest coverage risk carried into the
   later phases and is recorded here so it is not discovered at the gate.
2. **Four in-scope Codex canonical copies are absent from `CodeCoverage.Path` at baseline.** They
   are production files that will be modified, and the Coverage Exclusion Policy states that no
   production file may be excluded from coverage measurement. The plan registers only the two new
   parser files in the coverage lists (four entries), not these four hooks, so they remain
   unmeasured after this change unless a later phase adds them. This is recorded as an observation,
   not a plan amendment; the executor does not add tasks.

Output Summary: 28 rows recorded, one per in-scope production copy. 10 numeric percentages, each
attributed to its package-qualified element path: 88.0000%, 84.5679%, 92.1569%, 96.4286%, 95.6989%,
90.3846%, 95.3125%, 94.1176%, 91.4894%, 91.3043%. 14 bundle-mirror literals and 4 absent-from-list
literals. One measured file is below the 85% threshold at baseline
(`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, 84.5679%) and four in-scope Codex
canonical copies are outside the declared denominator; both conditions are flagged above.
