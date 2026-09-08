# Baseline — Per-File PowerShell Line Coverage (cycle 2)

Timestamp: 2026-09-07T21-05
Task: [P0-T9]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: transcription of orchestrator-supplied figures from CI run 34158596238 of .github/workflows/_poshqc.yml at commit 3b4f10b9 (no local command executed for the figures; `grep -n "hook-command-scanner" scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was run locally to confirm the two scanner registration lines)
EXIT_CODE: 0

## Provenance

| Field | Value |
|---|---|
| Workflow path | `.github/workflows/_poshqc.yml` |
| Run id | `34158596238` |
| Measured commit | `3b4f10b9` (`3b4f10b9813191d59e6c886978c43ecbd2aea80d`) |
| Run conclusion | success |
| Artifact | `poshqc-test-results`, file `powershell-coverage.xml` |
| Derivation method | sum of the JaCoCo `LINE` counters per `<sourcefile>`, package-qualified |

The `gh` CLI is not in this executor's tool allowlist, so the dispatch and the figure-reading are
orchestrator work per standing constraint 9 of the plan. The executor consumes the supplied figures
only. All seven figures below are transcribed verbatim from the orchestrator's supplied values.

## The seven per-file baselines

Every file this cycle edits, with its baseline line-coverage percentage:

| # | File | Missed | Covered | Total | Line % |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/validate-bash.ps1` | 5 | 85 | 90 | **94.4444** |
| 2 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 4 | 114 | 118 | **96.6102** |
| 3 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 1 | 66 | 67 | **98.5075** |
| 4 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 3 | 64 | 67 | **95.5224** |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 5 | 64 | 69 | **92.7536** |
| 6 | `.claude/hooks/hook-command-scanner.ps1` | 4 | 176 | 180 | **97.7778** |
| 7 | `.codex/hooks/hook-command-scanner.ps1` | 0 | 180 | 180 | **100.0000** |

All seven are numeric percentages. **No placeholder and no `BASELINE_NOT_REPORTED` marker appears
in this artifact**, and none is available as an outcome: run `34158596238` reports all seven, so a
substitution marker would be a recording error rather than a permitted fallback.

All seven are at or above the uniform 85% line-coverage threshold that
`.claude/rules/quality-tiers.md` sets. The lowest is
`.claude/hooks/enforce-parallel-abandon-gate.ps1` at 92.7536, which carries 7.75 points of headroom
above the threshold.

### Derivation of the two scanner figures

Rows 6 and 7 were derived from the `poshqc-test-results` artifact of run `34158596238` by summing
the JaCoCo `LINE` counters per `<sourcefile>` in `powershell-coverage.xml`. That is the same method
that reproduces the other five figures exactly, so the two scanner rows rest on the same derivation
as the five that were independently corroborated by the cycle-1 exit audit.

Both scanner paths are present in the coverage list at
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, confirmed locally in this worktree:

```
$ grep -n "hook-command-scanner" scripts/powershell/PoshQC/settings/pester.runsettings.psd1
253:            '.claude/hooks/hook-command-scanner.ps1'
255:            '.codex/hooks/hook-command-scanner.ps1'
```

Lines 253 and 255, matching the plan. Their presence in `CodeCoverage.Path` is what places both
files inside the coverage denominator and is why run `34158596238` reports a row for each.

## `.codex/hooks/validate-bash.ps1` is deliberately NOT carried

`.codex/hooks/validate-bash.ps1` is **not** a coverage-carrying file for this cycle and no baseline
figure is recorded for it, because **this cycle does not edit it**. R-2.d is Claude-only: the Codex
copy carries no `cd`-chain rule at all. `$script:CdChainedReadCommandPattern` occurs across the
whole repository only in `.claude/hooks/validate-bash.ps1` line 222 and its bundle mirror at the
same line. Edit 6 therefore has no Codex counterpart, and no such rule may be added.

## TOOLCHAIN_SUBSTITUTION

The MCP test runner `mcp__drm-copilot__run_poshqc_test` was **deliberately not used** for any
coverage figure in this artifact. It resolves runsettings from the installed VS Code extension and
cannot see this branch's `CodeCoverage.Path` entries, so it produces no row for the newly registered
files — including both scanner paths — and would report a narrower denominator than the gate
requires. The substitute route actually used for coverage is the CI `workflow_dispatch` of
`.github/workflows/_poshqc.yml`, run `34158596238`, whose figures the orchestrator read and supplied.
No coverage stage was skipped; it was executed on a different host and its output transcribed here.

## Output Summary

Seven numeric per-file line-coverage baselines transcribed from CI run `34158596238` at commit
`3b4f10b9`, workflow `.github/workflows/_poshqc.yml`, conclusion success. Range 92.7536 to
100.0000; all seven at or above the 85% threshold. Zero placeholders and zero
`BASELINE_NOT_REPORTED` markers. `.codex/hooks/validate-bash.ps1` is explicitly excluded from the
carried set because this cycle does not edit it. The MCP runner was not used for any figure, and the
reason is recorded above as a `TOOLCHAIN_SUBSTITUTION`. These seven values are the comparison basis
for the post-change measurement in `[P5-T7]`.
