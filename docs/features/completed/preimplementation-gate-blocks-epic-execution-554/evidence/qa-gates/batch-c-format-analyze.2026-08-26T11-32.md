# Batch C — PowerShell Format and Analyze (issue #554)

Timestamp: 2026-08-26T11-32

Command:

```text
mcp__drm-copilot__run_poshqc_format  (workspace_root = the worktree root)
mcp__drm-copilot__run_poshqc_analyze (workspace_root = the worktree root)
```

Run in that order. The numeric finding count is read from the equivalent self-hosted invocation,
because the MCP surface reports success without enumerating a count — the same methodology used for
the Batch A and Batch B artifacts:

```powershell
Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force
Invoke-PoshQCAnalyze -Root (Get-Location).Path
```

EXIT_CODE: 0

Output Summary:

**Final pass: 0 analyzer findings across the repository, and all four mirror pairs verify as MATCH.**
The self-hosted analyzer emitted the single line:

```text
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d
```

| Severity | Count in the final pass |
| --- | --- |
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| **Total** | **0** |

## Formatting Changed No File, So No Re-Copy Was Required

The four mirror pair hashes were captured immediately before the format run (at P4-T10) and again
immediately after it. They are identical, which is the direct proof that formatting reformatted no
mirrored file:

| Pair | SHA-256 before and after format | Verdict |
| --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` (Claude) | `0C8C55CE222EE9241B061A2964D5A0BB7154EB57F2B91A9D0F049B4DA82B863E` | **MATCH** |
| `enforce-orchestration-preimplementation-gate-modes.ps1` (Claude) | `0FFAB72EF27B3AE38F60A38DC1BA60A5F974FAC91A4FA7D28F5094A790B455A4` | **MATCH** |
| `enforce-orchestration-preimplementation-gate.ps1` (Codex) | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | **MATCH** |
| `enforce-orchestration-preimplementation-gate-modes.ps1` (Codex) | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | **MATCH** |
| `pester.runsettings.psd1` (settings text-parity pair, not one of the four) | `399D6CE69C821AD47CBD33957BEBE9EB8076FB622F84F686728D42D8862D9FB1` | **MATCH** |

`git status --porcelain` reported the same paths before and after the format run, all of them Phase 4
edits made deliberately by P4-T1 through P4-T8. Because no mirrored file changed, **no re-copy was
performed and therefore no batch-budget counter reset was triggered** — the plan conditions that
reset on "before any re-copy", and the antecedent did not occur.

Mirror line counts at the end of the final pass, all at or under the 500-line cap:

| Mirrored file | Lines |
| --- | --- |
| `extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 490 |
| `extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 477 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 495 |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 477 |

Each equals its self-hosted source's line count, as byte-identity requires.

## Loop Iterations

Format ran once and reformatted zero files. Analyze ran once and produced zero findings. No stage
failed and no stage changed a file, so the format-then-analyze sequence completed in a **single
pass** and the loop was not restarted.

## True Counted-File Total for Batch C — the Counter Under-Records

The batch-budget counter at `.claude/state/powershell-batch-budget.default.json` reads, at the end
of this phase:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "scripts/powershell/PoshQC/settings/pester.runsettings.psd1",
    "extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1"
  ],
  "testFiles": []
}
```

(paths shown repo-relative for readability; the counter stores them absolute).

**The counter records 2 production files. The true counted-file total for Batch C is 6.** The
discrepancy is expected and is stated here rather than left implicit, because an unstated
under-record is indistinguishable from a budget breach at review time.

`.claude/hooks/enforce-powershell-batch-budget.ps1` is registered on the `Write|Edit` PreToolUse
matcher, so it observes only files written through those two tools. The four mirror copies of P4-T1
through P4-T4 were produced by a **scripted `Copy-Item` byte-copy**, which is not a `Write` or an
`Edit` and therefore never reaches the matcher. Those four writes bypassed the counter entirely.

| Batch C file | How written | Counted by the hook |
| --- | --- | --- |
| `extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Copy-Item` byte-copy | no |
| `extensions/.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `Copy-Item` byte-copy | no |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Copy-Item` byte-copy | no |
| `extensions/.../codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `Copy-Item` byte-copy | no |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `Edit` | **yes** |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` | `Edit` | **yes** |
| `extensions/.../claude-customizations/pack-manifests/core.json` | `Edit` | no — JSON is not a counted extension |
| `extensions/.../codex-and-agents-customizations/pack-manifests/core.json` | `Edit` | no — JSON is not a counted extension |

The byte-copy is not a workaround for the budget; it is the method the plan's decision D6 treatment
**requires**, because the Python parity tests cannot observe a line-ending or trailing-byte
divergence and a re-authored write can pass them while failing the SHA-256 pair gate. The concrete
instance in this change is that the Claude main gate hook carries no trailing newline while the Codex
one does.

Against the plan's declared batch structure the counts hold. The counter was reset at the head of
P4-T4, so the second three-file production group is the P4-T4 copy plus the two `pester.runsettings.psd1`
edits: **3 production files, at the cap of 3, not over it.** The first group, P4-T1 through P4-T3, is
likewise 3 files against the same cap, and was measured against the reset performed at P3-T23. Every
one of the six `.ps1` and `.psd1` files in Batch C is a mechanical byte-copy or text-parity copy of an
already-reviewed source under the decision D6 treatment, so the logical production count for the
whole change remains 3, not 8.
