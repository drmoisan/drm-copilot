# Fail-Open Probe — After Fix (Issue #412, Cycle 1, F-1)

Timestamp: 2026-07-25T20-14

This task re-runs the [P0-T7] commands verbatim, including the mandatory positive control.

## PowerShell probe (working-tree module, in-memory `[pscustomobject]` checkpoint)

Command: `pwsh -NoProfile -Command "Set-Location 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585'; $m = Import-Module ./.claude/lib/orchestrator-state/OrchestratorState.psm1 -Force -PassThru; $state = [pscustomobject]@{ step5_status='verified'; step6_status='blocked_remediation_loop_limit'; step7_status='verified'; step8_status='verified'; blocked_reason='none' }; $errs = @(& $m { param($s) Get-OrchestratorStatePrCreationReadinessError -State $s } $state); Write-Host ('PROBE count=' + $errs.Count); $errs | ForEach-Object { Write-Host ('  [' + $_ + ']') }; $ctl = [pscustomobject]@{ step5_status='pending'; step6_status='verified'; step7_status='verified'; step8_status='verified'; blocked_reason='none' }; $c = @(& $m { param($s) Get-OrchestratorStatePrCreationReadinessError -State $s } $ctl); Write-Host ('POSITIVE-CONTROL count=' + $c.Count); $c | ForEach-Object { Write-Host ('  [' + $_ + ']') }"`

EXIT_CODE: 0

Output (verbatim):

```
PROBE count=1
  [Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.]
POSITIVE-CONTROL count=1
  [Checkpoint PR-creation readiness validation failed: step5_status is pending.]
```

## Python reference gate (authoritative)

Command: `poetry run python -c "from scripts.dev_tools._orchestrator_state_pr_creation_readiness import validate_orchestrator_state_pr_creation_readiness as v; print(v({'step6_status': 'blocked_remediation_loop_limit'}))"` (run from `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a682ed107a9c0c585`)

EXIT_CODE: 0

Output (verbatim):

```
['Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.']
```

## Parity

| Path | Errors | Message |
|---|---|---|
| PowerShell `Get-OrchestratorStatePrCreationReadinessError` | 1 | `Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.` |
| Python `validate_orchestrator_state_pr_creation_readiness` | 1 | `Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.` |

The two strings are byte-identical, including the trailing period. The PowerShell interpolation
(`"Checkpoint PR-creation readiness validation failed: $key is $($field.Value)."`, module line 319)
was not modified by this cycle and matches the Python f-string at
`scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py` line 109:

```python
f"Checkpoint PR-creation readiness validation failed: {key} is {value}."
```

## Before / after

| Probe | Before ([P0-T7]) | After ([P2-T1]) |
|---|---|---|
| `step6_status = blocked_remediation_loop_limit` | 0 errors (fail-open) | **1 error** |
| Positive control `step5_status = pending` | 1 error | **1 error** (unchanged) |

Output Summary: After the fix the PowerShell PR-creation readiness gate returns exactly **one**
error for `step6_status: blocked_remediation_loop_limit`, and its string is byte-identical to the
Python gate's
`Checkpoint PR-creation readiness validation failed: step6_status is blocked_remediation_loop_limit.`.
The mandatory positive control still returns exactly one error
(`Checkpoint PR-creation readiness validation failed: step5_status is pending.`), unchanged from
before the fix, so no pre-existing blocking behavior regressed. The F-1 fail-open is closed and the
two paths now agree on the state this branch made representable.
