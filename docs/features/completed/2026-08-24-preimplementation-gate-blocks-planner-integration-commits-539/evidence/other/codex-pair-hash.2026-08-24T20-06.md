# Recomputed Codex Pair-Hash Parity — issue #539 [P5-T7]

Timestamp: 2026-08-24T20-06

Command:

```
pwsh -NoProfile -Command '@(...four Codex-side paths...) | ForEach-Object { $raw = Get-Content -Raw -LiteralPath $_; ...; Get-FileHash -Algorithm SHA256 -LiteralPath $_ }'
```

The command reads each path with `Get-Content -Raw`, derives both a newline count and a content-line
count, reads the byte length from `Get-Item`, and computes `Get-FileHash -Algorithm SHA256`. The
figures below were recomputed after the [P5-T5] format stage, so they reflect the final on-disk
state, not the state immediately after the copy.

EXIT_CODE: 0

## Method

The same content was landed on both members of each pair by copying the canonical file to its bundle
mirror ([P5-T1] for the hook pair, [P5-T2] for the helper pair). Equality is verified by SHA-256, not
asserted by construction, and is independently re-asserted at runtime by the
`keeps the canonical hooks byte-identical to their bundled copies` test in
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, which passed in [P5-T5].

## Codex hook pair — production-file list paths 3 and 7

| # | Path | SHA-256 | Content lines | Bytes |
| --- | --- | --- | --- | --- |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `F1243BC5882F4F85F3219CA2FFE47AC824BA8DAD782195EF77A3AB4DF2CEA2F8` | 351 | 12877 |
| 7 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `F1243BC5882F4F85F3219CA2FFE47AC824BA8DAD782195EF77A3AB4DF2CEA2F8` | 351 | 12877 |

**Relation: EQUAL.** Shared SHA-256 prefix `F1243BC5`. Both files end with a trailing newline, so the
newline count and the content-line count agree at 351. 351 content lines is 149 lines below the
500-line cap.

## Codex helper pair — production-file list paths 4 and 8

| # | Path | SHA-256 | Content lines | Bytes |
| --- | --- | --- | --- | --- |
| 4 | `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | 349 | 12852 |

**Relation: EQUAL.** Shared SHA-256 prefix `45C339FD`. Both files end with a trailing newline, so the
newline count and the content-line count agree at 349. 349 content lines is 151 lines below the cap.

## Baseline comparison

The [P0-T10] baseline recorded the Codex hook pair as EQUAL at prefix `E8A2DFC7`, 336 content lines,
11787 bytes. Both members moved together to `F1243BC5` at 351 content lines, 12877 bytes: the pair
relation is preserved and the hook grew by 15 lines for the helper dot-source and the allow-side
exemption call. The helper pair did not exist at baseline; both members were created in this feature
and are equal on first measurement.

## No cross-pair claim

No cross-pair (Codex versus Claude) equality claim is made or implied. The Claude pair is recorded
separately in the [P4-T7] artifact. The two hook implementations are deliberately divergent —
different content-line counts (351 versus 355), different byte counts (12877 versus 12495), and
different trailing-newline states — as the plan preamble states.

The two HELPER files do happen to share the hash `45C339FD` across the Claude and Codex sides,
because [P3-T1] deliberately authored the Codex helper byte-identical to the Claude helper: the
classifier is pure string logic and a single content minimises the divergence surface. That is a
recorded authoring choice of [P3-T1], not a cross-pair equality claim, and no contract requires it.

Output Summary: PASS. Within-pair SHA-256 equality holds for both Codex pairs. The hook pair shares
prefix `F1243BC5` at 351 content lines and 12877 bytes; the helper pair shares prefix `45C339FD` at
349 content lines and 12852 bytes. Both counts are below the 500-line cap. No cross-pair equality is
asserted.
