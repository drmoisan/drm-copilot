# Remediation Cycle 1 — Mirror-Pair SHA-256 Re-Verification

Timestamp: 2026-08-28T00-45
Cycle Timestamp: 2026-08-27T22-47
Task: [P3-T13]
Command: `Get-FileHash -Algorithm SHA256 -LiteralPath <path>` over each of the eight files forming the four mirrored production pairs, run under `pwsh -NoProfile`
EXIT_CODE: 0

## Why a hash and not an inspection

`spec.md` §"Mirror byte-identity must be verified by hash, not by inspection" records that the
repository's own Python parity tests **cannot observe a line-ending difference**, because they
compare `read_text()` results under Python's universal-newline translation, which normalizes
carriage-return/line-feed pairs before comparison. A SHA-256 hash is the only check in this
repository that observes a trailing-byte or line-ending divergence.

## The four pair hashes

### Pair 1 — Claude main gate hook

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` |
| Mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` |

**MATCH.**

### Pair 2 — Claude modes sibling

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` |
| Mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` |

**MATCH.**

### Pair 3 — Codex main gate hook

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` |
| Mirror | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` |

**MATCH.**

### Pair 4 — Codex modes sibling

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` |
| Mirror | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` |

**MATCH.**

## Comparison against the pre-remediation artifact

Each of the four hashes is compared against the value recorded in
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/qa-gates/final-mirror-pair-hashes.2026-08-27T22-42.md`
at its lines 33, 42, 51, and 60:

| Pair | Pre-remediation hash (22-42 artifact) | Post-remediation hash | Equal |
| --- | --- | --- | --- |
| 1 | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` | **Yes** |
| 2 | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` | **Yes** |
| 3 | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | **Yes** |
| 4 | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | **Yes** |

All four are byte-for-byte identical to their pre-remediation values. The same four values were also
recomputed independently by the cycle-1 policy audit, which recorded the prefixes `0c8c55ce…`,
`0ffab72e…`, `b978bad8…`, and `8e116581…` at its §Scope-Constraint Verification, so three
independent measurements now agree.

## Conclusion

**This remediation changed no production byte.** A change of any kind to any of the eight files —
including a change invisible to a line-oriented diff, such as a trailing byte or a line-ending
conversion — would have altered at least one of the four hashes. None changed. The eight production
files stand exactly as the cycle-1 review found them, which is the invariant the plan's Prohibition 1
states and which [P3-T11] proves from the diff side.

Output Summary: All four mirrored production pairs re-verified by SHA-256. Each pair's two hashes are
**equal**, and each of the four hashes **equals the value recorded in
`final-mirror-pair-hashes.2026-08-27T22-42.md`**. Zero production bytes changed by this remediation
cycle. Exit code 0.
