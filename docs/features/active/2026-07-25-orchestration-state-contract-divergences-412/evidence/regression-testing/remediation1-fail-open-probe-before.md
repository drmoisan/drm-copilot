# [expect-fail] Fail-Open Probe — Before Fix (Issue #412, Cycle 1, F-1)

Timestamp: 2026-07-25T20-01

Status: `[expect-fail]`. The PowerShell path returning zero errors is the expected — and defective —
outcome for this task. It documents the F-1 fail-open that Phase 1 closes.

## PowerShell probe (working-tree module, in-memory `[pscustomobject]` checkpoint)

Command: `pwsh -NoProfile -Command "Set-Location 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585'; $m = Import-Module ./.claude/lib/orchestrator-state/OrchestratorState.psm1 -Force -PassThru; $state = [pscustomobject]@{ step5_status='verified'; step6_status='blocked_remediation_loop_limit'; step7_status='verified'; step8_status='verified'; blocked_reason='none' }; $errs = @(& $m { param($s) Get-OrchestratorStatePrCreationReadinessError -State $s } $state); Write-Host ('PROBE count=' + $errs.Count); $errs | ForEach-Object { Write-Host ('  [' + $_ + ']') }; $ctl = [pscustomobject]@{ step5_status='pending'; step6_status='verified'; step7_status='verified'; step8_status='verified'; blocked_reason='none' }; $c = @(& $m { param($s) Get-OrchestratorStatePrCreationReadinessError -State $s } $ctl); Write-Host ('POSITIVE-CONTROL count=' + $c.Count); $c | ForEach-Object { Write-Host ('  [' + $_ + ']') }"`

EXIT_CODE: 0

Output (verbatim):

```
PROBE count=0
POSITIVE-CONTROL count=1
  [Checkpoint PR-creation readiness validation failed: step5_status is pending.]
```

The checkpoint is a `[pscustomobject]`, not a `[hashtable]`. This is load-bearing:
`Get-OrchestratorStateField` reads `$State.PSObject.Properties.Name`, and a hashtable exposes
`Count`/`Keys`/`Values` there rather than checkpoint keys, so every field would read as absent and
the function would return zero errors regardless of content. The module is imported by a
`./`-prefixed relative path; a bare relative path resolves as a module name and fails to load.

The positive control is mandatory and is satisfied: with `step5_status = 'pending'` the same
invocation path returns exactly one error,
`Checkpoint PR-creation readiness validation failed: step5_status is pending.`. This distinguishes
`PROBE count=0` (the function was reached and did not block) from a probe that never reached the
function at all.

## Python reference gate (authoritative)

Command: `poetry run python -c "from scripts.dev_tools._orchestrator_state_pr_creation_readiness import validate_orchestrator_state_pr_creation_readiness as v; print(v({'step6_status': 'blocked_remediation_loop_limit'}))"` (run from `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`)

EXIT_CODE: 0

Output (verbatim):

```
['Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.']
```

## Divergence

| Path | Input | Errors returned |
|---|---|---|
| PowerShell `Get-OrchestratorStatePrCreationReadinessError` | `step6_status = blocked_remediation_loop_limit` | **0** (fail-open) |
| Python `validate_orchestrator_state_pr_creation_readiness` | `step6_status = blocked_remediation_loop_limit` | **1** — `Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.` |

Root cause, `.claude/lib/orchestrator-state/OrchestratorState.psm1` line 319:

```powershell
if ($field.Present -and ($field.Value -eq 'pending' -or $field.Value -eq 'blocked')) {
```

Output Summary: Before the fix the PowerShell PR-creation readiness gate returns **0 errors** for a
checkpoint recording `step6_status: blocked_remediation_loop_limit` — the F-1 fail-open — while the
Python gate it documents parity with returns exactly **1 error**,
`Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.`.
The mandatory positive control returns exactly **1 error**
(`Checkpoint PR-creation readiness validation failed: step5_status is pending.`), confirming the
probe reached the function and that `PROBE count=0` is a genuine fail-open rather than a
non-executing probe. Both commands exited 0; the divergence is in the returned error sets, not in
process status.
