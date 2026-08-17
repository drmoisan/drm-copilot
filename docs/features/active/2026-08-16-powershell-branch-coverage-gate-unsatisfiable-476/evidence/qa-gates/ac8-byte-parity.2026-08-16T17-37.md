# AC8 — Root/Bundle Byte Parity (Issue #476)

Timestamp: 2026-08-16T17-37

Command: `Get-FileHash -Algorithm SHA256` over each of the 8 root/mirror pairs in the Scope Summary table, comparing the root hash to the mirror hash (run under `pwsh -NoProfile` from the repository root)

EXIT_CODE: 0

## Hash Comparison

| Pair | Root file | SHA256 (identical for root and mirror) | Verdict |
| --- | --- | --- | --- |
| 1 | `.claude/rules/powershell.md` | `323A0EC339954F57576ACA0977FAAA239FB3841F28B283D577EF79DD42A9857B` | MATCH |
| 2 | `.claude/rules/general-unit-test.md` | `AE4952F075435C563C2C5D126731E4CBBCF6FE9CBE477CB9A1CC13A92F5DA0AC` | MATCH |
| 3 | `.claude/rules/quality-tiers.md` | `EC3292847261636B7C138628E1E3567B2BFBE2B803DC562496AC5397CF1F93AF` | MATCH |
| 4 | `.claude/skills/feature-review-workflow/SKILL.md` | `162F8483F491ED0BDA2964750B63CFAD869BB39BA3C1A4DF3D92E49A32C10F64` | MATCH |
| 5 | `.claude/agents/feature-review.md` | `F70B015AB282A91DF7BE501B8F294F383265E11A2638B7FAA136D15CADD60C2F` | MATCH |
| 6 | `.claude/skills/powershell-qa-gate/SKILL.md` | `EE96B68FA89B9EF3B3EC48B1DE777703A7B11C6CD5D2F7E0C1331ED827DE4AA4` | MATCH |
| 7 | `.agents/skills/general-unit-test/SKILL.md` | `9C72D7763CBEC7CFCFB9A5D1271649B6FAF78C3EA766EBB99BB7B62A48995A06` | MATCH |
| 8 | `.agents/skills/quality-tiers/SKILL.md` | `A32C98DFC63D670A0491E59F0376A2348C4F05E0201604A10A8EF525784EB9A8` | MATCH |

`FAILED_PAIRS=0`.

Mirror paths compared:
- Pairs 1-6: `extensions/drm-copilot/resources/claude-customizations/<same .claude-relative path>`
- Pairs 7-8: `extensions/drm-copilot/resources/codex-and-agents-customizations/<same .agents-relative path>`

## Method Note

Each pair was additionally verified with `diff` at the moment of edit, immediately after the mirror write within the same plan task, so no intermediate state existed in which a root file was edited without its mirror. The hash comparison above is the independent end-state confirmation.

Output Summary: PASS. All 8 root/mirror pairs are byte-identical by SHA256; zero divergent pairs. This is the structural precondition for the P5-T1 parity suites, which enforce the same invariant mechanically.
