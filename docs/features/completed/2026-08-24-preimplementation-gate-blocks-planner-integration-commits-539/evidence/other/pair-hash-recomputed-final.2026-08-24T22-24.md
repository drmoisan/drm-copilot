# Recomputed Pair-Hash Parity — final QA loop, all four pairs — issue #539

Timestamp: 2026-08-24T22-24

This artifact supersedes the numeric values in the two earlier pair-hash artifacts
`evidence/other/claude-pair-hash.2026-08-24T19-57.md` [P4-T7] and
`evidence/other/codex-pair-hash.2026-08-24T20-06.md` [P5-T7]. See "Discrepancy" below.

## Method

Command:

```
pwsh -NoProfile -Command "<for each of the eight paths> $raw = Get-Content -Raw -LiteralPath $p; $lf = ([regex]::Matches($raw,\"`n\")).Count; $trailing = $raw.EndsWith(\"`n\"); $contentLines = if ($trailing) { $lf } else { $lf + 1 }; (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash; (Get-Item -LiteralPath $p).Length"
```

Content lines are counted as line-feed occurrences, plus one when the file does not end with a
trailing newline, so a file with no terminating newline is not under-counted. Byte length is read
from `Get-Item`. Equality is decided by SHA-256 over the raw bytes, not by line count.

The working tree was verified identical to `HEAD` for all eight paths before measuring
(`git diff --stat HEAD -- <hook paths>` produced no output), so these are the delivered values.
Cross-checked independently against git object storage for path 1:
`git show HEAD:.claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | sha256sum` returns
`bf3fe18d0de06f871e80a3962fc69bf1551e4015f4351e98979f087ebe911ca9` and
`git cat-file -s` returns `14327`, matching row 1 exactly.

EXIT_CODE: 0

## Measured values (all eight files)

| # | Path | SHA-256 | Content lines | Bytes | Trailing NL |
| --- | --- | --- | ---: | ---: | :---: |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `BF3FE18D0DE06F871E80A3962FC69BF1551E4015F4351E98979F087EBE911CA9` | 382 | 14327 | no |
| 2 | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 | yes |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `DB69F084EEA38EF30F273B95C07A994A17E1F4B6B4963EB39388F4021533F350` | 382 | 14916 | yes |
| 4 | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 | yes |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `BF3FE18D0DE06F871E80A3962FC69BF1551E4015F4351E98979F087EBE911CA9` | 382 | 14327 | no |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 | yes |
| 7 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `DB69F084EEA38EF30F273B95C07A994A17E1F4B6B4963EB39388F4021533F350` | 382 | 14916 | yes |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 | yes |

## Pair relations

| Pair | Members | Relation | Shared SHA-256 prefix |
| --- | --- | --- | --- |
| Claude hook | 1 and 5 | **EQUAL** | `BF3FE18D` |
| Claude helper | 2 and 6 | **EQUAL** | `45C339FD` |
| Codex hook | 3 and 7 | **EQUAL** | `DB69F084` |
| Codex helper | 4 and 8 | **EQUAL** | `45C339FD` |

All four canonical/bundle pairs are byte-identical, which is stronger than the content-equality
the Claude pair contract requires and exactly the byte-identity the Codex pair contract requires.

The two HELPER files share hash `45C339FD` across the Claude and Codex sides because [P3-T1]
deliberately authored the Codex helper byte-identical to the Claude helper. The two HOOK files
differ (`BF3FE18D` at 14327 bytes versus `DB69F084` at 14916 bytes) because the canonical Claude
and Codex hooks are deliberately divergent implementations of the same contract, consistent with
their differing executable-line totals in the coverage report (113 versus 125).

## Discrepancy with the [P4-T7] and [P5-T7] artifacts

The two earlier pair-hash artifacts recorded values that do not match the delivered files:

| Pair | Earlier artifact recorded | Actually delivered at HEAD |
| --- | --- | --- |
| Claude hook | `D4E539F4…`, 355 lines, 12495 bytes | `BF3FE18D…`, 382 lines, 14327 bytes |
| Codex hook | `F1243BC5…`, 351 lines, 12877 bytes | `DB69F084…`, 382 lines, 14916 bytes |
| Claude helper | `45C339FD…`, 349 lines, 12852 bytes | `45C339FD…`, 349 lines, 12852 bytes — **matches** |
| Codex helper | `45C339FD…`, 349 lines, 12852 bytes | `45C339FD…`, 349 lines, 12852 bytes — **matches** |

Both helper rows match exactly; only the two hook rows are stale. The canonical hooks were last
committed at 19:34 (Claude, `d57de8d8`) and 19:44 (Codex, `31bfba39`), before the earlier
artifacts were written at 19:57 and 20:06, so the earlier figures were expected to match and do
not. The measurement in this artifact is cross-checked against git object storage, so the values
above are the delivered ones.

**What this does and does not affect.** The property the acceptance criteria require is
within-pair equality, and that property holds — verified here by SHA-256, and independently
verified by the two contract suites that assert it programmatically rather than by reading these
artifacts: the `keeps the canonical hooks byte-identical to their bundled copies` test in
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` and
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, both passing in [P7-T3]
and [P7-T6] respectively. The defect was in the recorded numbers, not in the delivered files.

## Output Summary

PASS. All eight files measured against a working tree verified identical to `HEAD`. All four
canonical/bundle pairs are byte-identical: Claude hook `BF3FE18D` (382 lines, 14327 bytes),
Claude helper `45C339FD` (349 lines, 12852 bytes), Codex hook `DB69F084` (382 lines, 14916
bytes), Codex helper `45C339FD` (349 lines, 12852 bytes). The two hook rows in the [P4-T7] and
[P5-T7] artifacts are superseded by this one; the two helper rows in those artifacts were already
correct.
