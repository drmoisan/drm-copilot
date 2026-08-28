# P6-T9 — Final SHA-256 Re-Verification of the Four Mirrored Production Pairs

Timestamp: 2026-08-27T22-42

Loop iteration: 2 (the same Phase 6 iteration anchored by
`final-poshqc-format.2026-08-27T22-24.md`), taken after the final format pass.

Command:

```powershell
# Step 1 — the authorized per-batch budget counter reset, performed before any re-copy.
Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' | Remove-Item -Force

# Step 2 — recompute the four pairs.
foreach ($p in $pairs) {
  $ha = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[0]).Hash
  $hb = (Get-FileHash -Algorithm SHA256 -LiteralPath $p[1]).Hash
  '{0} :: src={1} :: mir={2} :: {3}' -f $p[0], $ha, $hb, $(if ($ha -eq $hb) { 'MATCH' } else { 'DIFFER' })
}
```

EXIT_CODE: 0

Output Summary:

**Exactly four pairs recorded; all four verdicts are MATCH. No re-copy was required, so the budget
reset was not consumed.**

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

## The budget reset was performed, and then not needed

The task authorizes deleting every file matching `.claude/state/powershell-batch-budget.*.json`
before any re-copy. The reset ran first, unconditionally, so that a re-copy would have been possible
had any pair reported DIFFER:

```text
BEFORE_COUNT=1
BEFORE_FILE=powershell-batch-budget.default.json
AFTER_COUNT=0
```

All four verdicts are MATCH, so **no mirror was re-copied and no `.ps1` file was written**. The
counter is now at zero writes, which is its clean state.

The deleted file is the same gitignored counter named by the issue #510 failure at P6-T5. Deleting it
here is the **budget reset the plan prescribes**, not a remediation of issue #510, and it must not be
read as one: the counter is rewritten by
`.claude/hooks/enforce-powershell-batch-budget.ps1` on the next `.ps1`, `.psm1`, or `.psd1` write
through `Write` or `Edit`, at which point the issue #510 condition returns. The P0-T9 baseline states
this distinction explicitly and the P6-T5 artifact records the failure as pre-existing on its own
evidence, not on the state file's absence.

## No re-copy means no restart

The plan directs that a DIFFER verdict restarts the loop at P6-T1 after re-copying from the
self-hosted source. No verdict is DIFFER, so the loop is not restarted and Phase 6 ends here.

The four hashes are identical to those recorded at
`mirror-pair-hashes.2026-08-26T11-23.md` (P5) and at `batch-c-format-analyze.2026-08-26T11-32.md`
(P4-T12). Nothing mirrored has drifted, and the final format pass (P6-T1, reformatted-file count 0)
touched none of them.

## Two facts recorded alongside, neither part of the four-pair count

- The fifth mirrored file, the coverage settings text-parity pair
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its resources copy, still matches
  at `399D6CE69C821AD47CBD33957BEBE9EB8076FB622F84F686728D42D8862D9FB1` (measured in the same pass at
  P6-T5). It is recorded under P4-T6 because it is a `.psd1` settings file, not a production `.ps1`
  pair.
- All four `-helpers.ps1` copies still hash
  `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B`, the Phase 0 baseline value,
  confirming they remain byte-untouched by Phase 6 as decision D1 requires:

  ```text
  45C339...65C0B :: .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
  45C339...65C0B :: .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
  45C339...65C0B :: extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
  45C339...65C0B :: extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
  ```

## Why a hash and not an inspection

The repository's Python parity tests compare `read_text()` results under Python's universal-newline
translation, which normalizes carriage-return/line-feed pairs before comparison. They therefore
cannot observe a line-ending or trailing-byte divergence. `Get-FileHash` is the only check in this
repository that observes it. The concrete instance in this change:
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` carries **no trailing newline**
while `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` does. Both traits survive
`Copy-Item` and are reflected in the hashes above.

## Verdict

PASS. The artifact records exactly four pairs and all four verdicts are MATCH.
