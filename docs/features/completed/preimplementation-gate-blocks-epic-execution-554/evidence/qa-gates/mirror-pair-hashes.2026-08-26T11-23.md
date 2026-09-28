# SHA-256 Byte-Identity of the Four Mirrored Production Pairs (issue #554)

Timestamp: 2026-08-26T11-23

Command:

```powershell
$pairs = @(
 @('.claude/hooks/enforce-orchestration-preimplementation-gate.ps1',
   'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1'),
 @('.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1',
   'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'),
 @('.codex/hooks/enforce-orchestration-preimplementation-gate.ps1',
   'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1'),
 @('.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1',
   'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1')
)
foreach ($p in $pairs) {
  $ha = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[0]).Hash
  $hb = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[1]).Hash
  '{0} : {1} : {2}' -f $p[0], $ha, $(if ($ha -eq $hb) { 'MATCH' } else { 'DIFFER' })
}
```

EXIT_CODE: 0

Output Summary:

**Four pairs recorded; all four verdicts are MATCH.**

### Pair 1 — Claude main gate hook

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` |
| Mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` |

Verdict: **MATCH**

### Pair 2 — Claude modes sibling

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` |
| Mirror | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` |

Verdict: **MATCH**

### Pair 3 — Codex main gate hook

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` |
| Mirror | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` |

Verdict: **MATCH**

### Pair 4 — Codex modes sibling

| Side | Path | SHA-256 |
| --- | --- | --- |
| Source | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` |
| Mirror | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` |

Verdict: **MATCH**

## Why a Hash and Not an Inspection

The repository's Python parity tests compare `read_text()` results under Python's universal-newline
translation, which normalizes carriage-return/line-feed pairs before comparison. They therefore
cannot observe a line-ending or trailing-byte divergence. `Get-FileHash` is the only check in this
repository that observes it. Each mirror was produced by a scripted `Copy-Item` byte-copy from its
reviewed self-hosted source, never by a re-authored write, precisely because a re-authored write can
satisfy the Python parity tests while failing this hash.

The concrete instance of that hazard in this change: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
carries **no trailing newline** while `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
does. Both traits survive `Copy-Item` and are reflected in the hashes above.

## Two Non-Mirrored Facts Recorded Alongside

Neither is part of the four-pair count; both were measured in the same pass.

- The fifth mirrored file, the coverage settings text-parity pair, also matches at
  `399D6CE69C821AD47CBD33957BEBE9EB8076FB622F84F686728D42D8862D9FB1`. It is recorded under P4-T6, not
  here, because it is a `.psd1` settings file rather than a production `.ps1` pair.
- All four `-helpers.ps1` copies still hash
  `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B`, the Phase 0 baseline value,
  confirming they remain byte-untouched. That is the decision D1 proof obligation and is formally
  recorded at P5-T1.
