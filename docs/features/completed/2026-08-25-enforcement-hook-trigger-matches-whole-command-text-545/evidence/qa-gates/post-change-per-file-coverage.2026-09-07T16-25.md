# [P12-T8] Post-change per-file line coverage

Timestamp: 2026-09-07T16-25

Command:

```
gh workflow run _poshqc.yml --ref bug/enforcement-hook-trigger-matches-whole-command-text-545-r3
gh run view 34139262327 --json conclusion,url
gh run download 34139262327 --name <pester-artifact>   # artifacts/pester/powershell-coverage.xml
```

The workflow `.github/workflows/_poshqc.yml` imports the self-hosted
`scripts/powershell/PoshQC/PoshQC.psm1` from the checked-out branch and resolves
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` from that same checkout, so the
`CodeCoverage.Path` entries registered by [P4-T10] are honoured.

EXIT_CODE: 0

TOOLCHAIN_SUBSTITUTION: the plan text for this task names the self-hosted PoshQC command run
locally. `pwsh`, `powershell`, and `cmd` are not invocable anywhere in this session, so that command
could not be executed on this machine. The MCP test runner
(`mcp__drm-copilot__run_poshqc_test`) was deliberately **not** substituted, because it resolves its
runsettings from the *installed* VS Code extension rather than from this checkout and would
therefore omit the four `CodeCoverage.Path` entries that [P4-T10] added. The figures below were
produced instead by dispatching `.github/workflows/_poshqc.yml` against the pushed branch, which
runs the same self-hosted module against the same checked-out runsettings. This is a route
substitution, not a measurement substitution: the measuring code and the settings file are
identical to those the plan text names.

## Measurement provenance

| Field | Value |
|---|---|
| Route | CI dispatch of `.github/workflows/_poshqc.yml` |
| Run id | `34139262327` |
| Conclusion | `success` |
| Run URL | `https://github.com/drmoisan/drm-copilot/actions/runs/34139262327` |
| Measured at commit | `cc83c0c8` |
| Source artifact | `artifacts/pester/powershell-coverage.xml` from that run, downloaded and parsed |
| Overall line coverage | `94.0209` percent (covered `8287`, missed `527`) |
| Overall reading method | the report-level `counter` element whose `type` is `LINE` |
| Per-file selection method | package-qualified: the `sourcefile` element matching the bare filename, selected within the enclosing `package` whose name ends with that file's directory |

The full Pester suite was GREEN on that clean CI checkout. That re-confirms the finding recorded
earlier in this feature that the two failures observed locally are ambient-state artifacts of this
worktree and are not caused by this change.

## Output Summary

All **18** changed or added canonical production PowerShell files produced a coverage row. Zero
rows were missing, which confirms the [P4-T10] `CodeCoverage.Path` registration landed and is being
honoured by the measuring run. **Thirteen** of the eighteen are at or above the 85 percent line
threshold; **five** are below it and are the subject of [P12-T9].

## Per-file line coverage (canonical production files)

| # | File | Covered | Missed | Percent | At or above 85 |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 176 | 4 | 97.7778 | yes |
| 2 | `.claude/hooks/hook-command-invocation.ps1` | 122 | 2 | 98.3871 | yes |
| 3 | `.codex/hooks/hook-command-scanner.ps1` | 180 | 0 | 100.0000 | yes |
| 4 | `.codex/hooks/hook-command-invocation.ps1` | 120 | 4 | 96.7742 | yes |
| 5 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 136 | 18 | 88.3117 | yes |
| 6 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 141 | 25 | 84.9398 | **no** |
| 7 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | 56 | 4 | 93.3333 | yes |
| 8 | `.codex/hooks/enforce-promotion-mcp-only.ps1` | 43 | 22 | 66.1538 | **no** |
| 9 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 64 | 3 | 95.5224 | yes |
| 10 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 24 | 2 | 92.3077 | yes |
| 11 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 | 5 | 94.9495 | yes |
| 12 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 44 | 24 | 64.7059 | **no** |
| 13 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 | 5 | 93.2432 | yes |
| 14 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 114 | 4 | 96.6102 | yes |
| 15 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 51 | 16 | 76.1194 | **no** |
| 16 | `.claude/hooks/validate-bash.ps1` | 83 | 5 | 94.3182 | yes |
| 17 | `.codex/hooks/validate-bash.ps1` | 29 | 44 | 39.7260 | **no** |
| 18 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 64 | 5 | 92.7536 | yes |

Each percentage above is attributed to its package-qualified element path: the `sourcefile` element
named for the bare filename, selected inside the `package` element whose name ends with `.claude/hooks`
or `.codex/hooks` respectively. Bare-filename selection alone would be ambiguous for the ten
filenames that exist on both the Claude and the Codex side; the package qualification resolves it.

## Bundle mirrors

`CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` holds **zero**
entries under `extensions/drm-copilot/resources/`. Verified by searching that file for the literal
`extensions/drm-copilot/resources`, which returns no match. Every bundle mirror of a file in the
table above is therefore recorded with the literal entry below.

| Bundle mirror | Coverage entry |
|---|---|
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1` | outside the coverage denominator - bundle mirror, parity enforced by content or hash |

Parity for the Claude mirrors is enforced by content comparison in
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`; parity for the Codex mirrors
is enforced by SHA-256 comparison in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
Both mechanisms are recorded green in `evidence/qa-gates/parity-mechanisms.2026-09-07T15-57.md`
([P12-T5]), and the recomputed hash pairs are recorded in
`evidence/other/pair-hash-parity.2026-09-07T15-52.md` ([P12-T4]).

## Acceptance

- One numeric percentage per changed or added canonical production file: **18 of 18** present.
- Each attributed to its package-qualified element path: recorded above.
- One literal entry per bundle mirror: **18 of 18** present, all carrying the required literal.
