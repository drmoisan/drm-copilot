# P6-T8 — Final Line Counts for the Eight Production `.ps1` Files

Timestamp: 2026-08-27T22-40

Loop iteration: 2 (the same Phase 6 iteration anchored by
`final-poshqc-format.2026-08-27T22-24.md`)

Command:

```powershell
foreach ($f in $files) { '{0} :: {1}' -f (@(Get-Content -LiteralPath $f)).Count, $f }
```

where `$files` is the four self-hosted production files followed by their four mirrors.

EXIT_CODE: 0

Output Summary:

**All eight counts are integers at or below the 500-line cap. Maximum is 495; minimum is 477.**

### The four self-hosted files

| # | File | Lines | <= 500 |
| --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | **490** | yes |
| 2 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | yes |
| 3 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **495** | yes |
| 4 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | yes |

### The four mirrors

| # | File | Lines | <= 500 |
| --- | --- | --- | --- |
| 5 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | **490** | yes |
| 6 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | yes |
| 7 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **495** | yes |
| 8 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | yes |

Each mirror equals its self-hosted source's count, as byte-identity requires. Pairs 1/5 and 2/6 and
3/7 and 4/8 correspond to the four SHA-256 pairs re-verified at P6-T9.

## Authority and headroom

`.claude/rules/general-code-change.md` sets the cap: "No production code, test code, or reusable
script file may exceed **500 lines**." None of the eight exemptions applies to these files — they are
permanent production hooks, not throwaway scripts, fixtures, or Markdown.

Headroom on the tightest file, the Codex main gate hook, is **5 lines**. That is the file to watch;
the plan's decision to split the mode table and its readiness predicates into the separate
`-modes.ps1` sibling (P2-T15, P3-T7, P3-T11) is what keeps both main hooks under the cap. The counts
are unchanged from the Batch C measurement at `batch-c-format-analyze.2026-08-26T11-32.md`, which is
expected: the final format pass reformatted zero files.

## Verdict

PASS. All eight recorded counts are integers at or below 500.
