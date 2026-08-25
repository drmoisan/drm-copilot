# Recomputed Claude Pair-Hash Parity — issue #539 [P4-T7]

Timestamp: 2026-08-24T19-57

Command:

```
pwsh -NoProfile -Command '@(...four Claude-side paths...) | ForEach-Object { $raw = Get-Content -Raw -LiteralPath $_; ...; Get-FileHash -Algorithm SHA256 -LiteralPath $_ }'
```

The command reads each path with `Get-Content -Raw`, derives both a newline count and a content-line
count, reads the byte length from `Get-Item`, and computes `Get-FileHash -Algorithm SHA256`.

EXIT_CODE: 0

## Method

The same content was landed on both members of each pair by copying the canonical file to its bundle
mirror ([P4-T1] for the hook pair, [P4-T2] for the helper pair). Equality is verified by SHA-256, not
asserted by construction. Content lines equal the newline count for a file ending with a newline, and
the newline count plus one for a file ending without one.

## Claude hook pair — production-file list paths 1 and 5

| # | Path | SHA-256 | Content lines | Bytes |
| --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `D4E539F4FBDA38C61415F7217225101F164EFBFED0590B8EE75DA9CF1B4FC11D` | 355 | 12495 |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `D4E539F4FBDA38C61415F7217225101F164EFBFED0590B8EE75DA9CF1B4FC11D` | 355 | 12495 |

**Relation: EQUAL.** Shared SHA-256 prefix `D4E539F4`. Both files end without a trailing newline, so a
newline-counting tool reports 354 for each. 355 content lines is 145 lines below the 500-line cap.

## Claude helper pair — production-file list paths 2 and 6

| # | Path | SHA-256 | Content lines | Bytes |
| --- | --- | --- | --- | --- |
| 2 | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 |

**Relation: EQUAL.** Shared SHA-256 prefix `45C339FD`. Both files end with a trailing newline, so the
newline count and the content-line count agree at 349. 349 content lines is 151 lines below the cap.

## Baseline comparison

The [P0-T10] baseline recorded the Claude hook pair as EQUAL at prefix `F57FAE11`, 340 content lines,
11526 bytes. Both members moved together to `D4E539F4` at 355 content lines, 12495 bytes: the pair
relation is preserved and the hook grew by 15 lines for the helper dot-source and the allow-side
exemption call. The helper pair did not exist at baseline; both members were created in this feature
and are equal on first measurement.

## No cross-pair claim

No cross-pair (Claude versus Codex) equality claim is made or implied. The Codex pair is recorded
separately in the [P5-T7] artifact. The two pairs are deliberately divergent implementations of the
same behavioral contract, as the plan preamble states.

Output Summary: PASS. Within-pair SHA-256 equality holds for both Claude pairs. The hook pair shares
prefix `D4E539F4` at 355 content lines and 12495 bytes; the helper pair shares prefix `45C339FD` at
349 content lines and 12852 bytes. Both counts are below the 500-line cap. No cross-pair equality is
asserted.
