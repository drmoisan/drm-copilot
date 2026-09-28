# Baseline Line Counts and Pair Hashes — issue #539 [P0-T10]

Timestamp: 2026-08-24T17-33

Command: `pwsh -NoProfile -File <scratchpad>/baseline-hashes.ps1` — a throwaway script that reads each path with `Get-Content -Raw`, derives both a newline count and a content-line count, and computes `Get-FileHash -Algorithm SHA256`. The script is a temporary agent-session artifact and is not committed.

EXIT_CODE: 0

## Line-count reading convention

Two figures are reported per file because they differ when a file has no trailing newline:

- **Content lines** — the number of actual text lines, which is what the 500-line cap in `.claude/rules/general-code-change.md` governs.
- **Newline count** — what a newline-counting tool such as `wc -l` reports.

For a file that ends WITH a newline, content lines equal the newline count. For a file that ends WITHOUT a newline, content lines equal the newline count plus one.

## Line counts — four hook copies

| # | Path | Content lines | Newline count | Ends with newline | Bytes |
| --- | --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 340 | 339 | no | 11526 |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 | 336 | yes | 11787 |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 340 | 339 | no | 11526 |
| 7 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 336 | 336 | yes | 11787 |

Both figures agree with the plan preamble: the Claude copy is 340 content lines with no trailing newline so a newline-counting tool reports 339, and the Codex copy is 336 lines. All four are below the 500-line cap, with 160 lines of headroom on the Claude side and 164 on the Codex side.

## Line counts — two existing suites

| Path | Content lines | Newline count | Ends with newline | Bytes | Headroom to 500 |
| --- | --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | 461 | 461 | yes | 25739 | 39 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 494 | 494 | yes | 26832 | 6 |

Both agree with the plan preamble (461 and 494). The near-cap state of both suites is the reason Phase 1 authors new sibling files rather than extending these in place, and the reason [P5-T4] is restricted to a one-line array append.

## Line counts — two PoshQC coverage-settings copies

| Path | Content lines | Newline count | Bytes |
| --- | --- | --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 217 | 217 | 14518 |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | 217 | 217 | 14518 |

## SHA-256 — four hook copies

```
F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C  .claude/hooks/enforce-orchestration-preimplementation-gate.ps1
E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37  .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
F57FAE11FB5E98DC3D06214922A1B1CA4AE200D014873CADF03312042537493C  extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1
E8A2DFC7F7F47219B19F957EBF473489C02B4F0C3CFDB745889B4E08AD1D4F37  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1
```

## SHA-256 — two PoshQC coverage-settings copies

```
2BBEBECBC6F7DD8F028A396680C702086D9980306DC7767269FDE9D9BEE63DF6  scripts/powershell/PoshQC/settings/pester.runsettings.psd1
2BBEBECBC6F7DD8F028A396680C702086D9980306DC7767269FDE9D9BEE63DF6  extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
```

## Within-pair relations (the only hash relations asserted)

- **Claude hook pair (paths 1 and 5): EQUAL.** Both are `F57FAE11...`. Shared SHA-256 prefix `F57FAE11`.
- **Codex hook pair (paths 3 and 7): EQUAL.** Both are `E8A2DFC7...`. Shared SHA-256 prefix `E8A2DFC7`.
- **PoshQC coverage-settings pair: EQUAL.** Both are `2BBEBECB...`, byte-identical at 14518 bytes.

The runsettings equality relation recorded here is the pre-change relation that [P4-T3] must preserve: because the two copies are byte-identical at baseline, they must be byte-identical again after the mirror edit applies the same two coverage-entry hunks that [P2-T3] and [P3-T3] apply to the self-hosted copy.

## No cross-pair claim

No cross-pair equality claim is made or implied. The Claude pair hash (`F57FAE11...`) and the Codex pair hash (`E8A2DFC7...`) are different, and their line counts (340 versus 336), byte counts (11526 versus 11787), and trailing-newline states differ. The two pairs are deliberately divergent implementations of the same behavioral contract, as the plan preamble states, and the coverage line totals recorded by [P0-T8] and [P0-T9] (110 versus 122 instrumented lines) independently corroborate that divergence.

Output Summary: PASS. All eight measured files are recorded. Within-pair SHA-256 equality holds for both hook pairs: the two Claude copies share one hash (prefix `F57FAE11`) and the two Codex copies share another (prefix `E8A2DFC7`). The two PoshQC coverage-settings copies are byte-identical (prefix `2BBEBECB`), so the pre-change runsettings relation that [P4-T3] must preserve is EQUAL. No cross-pair equality is asserted; the two pairs are deliberately divergent. Line counts: hooks 340/336/340/336, suites 461 and 494, runsettings 217 and 217 — every count at or under the 500-line cap.
