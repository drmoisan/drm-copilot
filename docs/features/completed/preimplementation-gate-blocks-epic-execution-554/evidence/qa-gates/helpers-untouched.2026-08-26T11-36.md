# P5-T1 — Four `-helpers.ps1` Copies Untouched

Timestamp: 2026-08-26T11-36

Command:

```powershell
git diff --name-only origin/main...HEAD
Get-FileHash -Algorithm SHA256 -LiteralPath <each of the four helpers paths>
```

EXIT_CODE: 0

Output Summary:

Purpose. Decision D1 of `spec.md` makes the byte-identity of the four
`enforce-orchestration-preimplementation-gate-helpers.ps1` copies the proof that the issue #539
orchestration-bookkeeping staging exemption is behaviourally unchanged by this feature. Those four
paths are deliberately absent from the `## DECLARED BLAST RADIUS`.

### Diff presence — all four ABSENT

The full branch diff against `origin/main...HEAD` contains 45 paths. None of the four helpers paths
is among them.

| Path | Present in branch diff |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | False |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | False |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | False |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | False |

### SHA-256 — all four match the recorded branch-point hash

Expected hash (from the P0-T7 baseline artifact
`evidence/baseline/phase0-hook-hashes.2026-08-26T10-18.md`):
`45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B`

| Path | SHA-256 | Matches expected |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | True |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | True |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | True |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | True |

### Verdict

PASS. Zero of four helpers paths appear in the branch diff, and all four hash to the recorded
branch-point value. The issue #539 staging exemption is byte-identical to `HEAD` of `origin/main`.

The hash comparison is case-insensitive (`-ieq`); `Get-FileHash` emits uppercase hexadecimal while
`spec.md` and `plan.2026-08-26T08-40.md` quote the same value in lowercase. The two spellings denote
the same 32-byte digest.
