# Batch A — PowerShell Per-Batch Budget Counter Reset (issue #554)

Timestamp: 2026-08-26T10-48

Command:

```powershell
# observe
Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File |
    ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName }
# reset
Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' -File |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }
```

EXIT_CODE: 0

Output Summary:

**Counter files found before deletion: 1.** File deleted:

```text
C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a502f12120e44837d\.claude\state\powershell-batch-budget.default.json
```

Counter contents observed before deletion, verbatim:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a502f12120e44837d/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1"
  ],
  "testFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a502f12120e44837d/tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1"
  ]
}
```

**After deletion: 0 files match `powershell-batch-budget.*.json` under `.claude/state/`.** No counter
file remains. Verified by re-enumeration immediately after the deletion (`CountAfter=0`).

## Reading of the Observed Counts

Against the caps of 3 production and 3 test files, Batch A consumed **1 counted production file and 1
counted test file**. Both are at or under the cap, so the reset is a batch-boundary hygiene step
required by the plan and not a remediation of a breach.

The counter records only one of Batch A's two production files. The counter is written by the
`Write|Edit` PreToolUse hook `.claude/hooks/enforce-powershell-batch-budget.ps1` and therefore counts
only writes made through those two tools.
`.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` was produced at P2-T11 by a
scripted byte-copy of the reviewed `.claude` file with a single header substitution, rather than by an
authoring write, so it did not pass through the counted tool path. Recorded here explicitly rather
than left as a discrepancy: the true Batch A production count is **2** logical files, both at or under
the cap of 3, so no cap was exceeded by either reading.

## Not to Be Conflated With Issue #510

`.claude/state/` is gitignored, so this file never appears in a diff and this deletion changes no
tracked content. The deletion is the mechanism the batch-budget hook's own block reason prescribes for
resetting the per-batch counter. It is **not** a remediation of the open issue #510 condition
(`test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerating gitignored
`.claude/state/*.json` counters). Deleting the state file is not a durable fix for that issue and must
not be attempted as one; see
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/baseline/phase0-python-parity.2026-08-26T10-18.md`.

Batch B may now begin with a clear counter.
