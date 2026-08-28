# Fail-Before Evidence — Matrix Case 6b (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```powershell
$c = New-PesterConfiguration
$c.Run.Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1'
$c.Run.PassThru = $true
$c.Run.Exit = $false
$c.Output.Verbosity = 'Detailed'
$r = Invoke-Pester -Configuration $c
exit $r.FailedCount
```

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:

| Metric | Value |
| --- | --- |
| Passed | **0** |
| **Failed** | **1** |
| Skipped | 0 |
| Total | 1 |
| Wall time | 898 ms |

Failing case:

```text
enforce-orchestration-preimplementation-gate.ps1 mode resolution
  > Fault-1 wording independence, direction (b): the new allow-to-deny change
    > denies an orchestrator delegation phrased with "atomic execution" and no mode
      markers against an unready single-feature checkpoint
```

Verbatim assertion failure:

```text
Expected strings to be the same, but they were different.
Expected length: 4
Actual length:   5
Strings differ at index 0.
Expected: 'deny'
But was:  'allow'
           ^
```

**The observed pre-fix decision was `allow`. The asserted decision is `deny`.** The single failure is
the `[expect-fail]` outcome this task requires, and it is the only failing case in the run.

## Why the Pre-Fix Classifier Returns Allow

The run was executed against the **unmodified** hook at
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, whose
`Test-ImplementationDelegation` serializes the whole `tool_input` object and matches seven tokens
against the resulting text:

```powershell
$payloadText = ($ToolInput | ConvertTo-Json -Depth 20 -Compress)
return $payloadText -match '(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)'
```

The fixture's serialized `tool_input` is:

```json
{"subagent_type":"orchestrator","prompt":"Begin atomic execution of the approved plan for this feature."}
```

None of the seven tokens is present. The four typed-engineer names and `atomic-executor` do not
appear; the word `execution` does not contain the bare token `execute`; and the word `implementation`
does not appear at all. The classifier therefore returns `$false`, the delegation is not classified as
implementation, and the gate short-circuits to allow at the `-not $requiresReadyCheckpoint` branch
without ever consulting the injected unready checkpoint.

This is Fault 1 in `spec.md`: classification depends on prompt wording. A semantically identical
prompt phrased with the word `execute` is denied.

## What Changes the Outcome

The structural classifier applied at P3-T2 replaces the whole-payload scan with field-scoped reads of
`subagent_type` and `prompt`. Under it, `subagent_type` is exactly `orchestrator`, the field-scoped
prompt carries no recognized mode marker, so the resolved mode is the default single-feature mode and
the delegation IS implementation. It is then evaluated against the explicitly injected unready
single-feature checkpoint (`route_id` empty, `lifecycle_ready` false), which denies.

The corresponding pass-after artifact is written at P5-T6 and supersedes this one.

## Determinism Note

The fixture supplies an explicit unready `-CheckpointRaw`. A case that omitted it would fall through
to the on-disk checkpoint at `artifacts/orchestration/orchestrator-state.json`, which is ready during
an orchestrated run, and the deny assertion would then be testing the wrong operand. No temporary
file, filesystem write, wall-clock read, network access, or external process is involved.
