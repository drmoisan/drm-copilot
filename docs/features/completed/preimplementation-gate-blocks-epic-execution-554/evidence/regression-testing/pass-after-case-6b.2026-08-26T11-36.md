# Pass-After Evidence — Matrix Case 6b (issue #554)

Timestamp: 2026-08-26T11-36

Command:

```powershell
$c = New-PesterConfiguration
$c.Run.Path = 'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1'
$c.Filter.FullName = '*atomic execution*'
$c.Run.PassThru = $true
$c.Output.Verbosity = 'Detailed'
$r = Invoke-Pester -Configuration $c
```

EXIT_CODE: 0

Output Summary:

| Metric | Value |
| --- | --- |
| **Passed** | **1** |
| Failed | **0** |
| Skipped | 0 |
| Selected by filter | 1 of 83 discovered |
| Pester `Result` | `Passed` |
| Wall time | 1.54 s |

Passing case:

```text
Describing enforce-orchestration-preimplementation-gate.ps1 mode resolution
  Context Fault-1 wording independence, direction (b): the new allow-to-deny change
    [+] denies an orchestrator delegation phrased with "atomic execution" and no mode
        markers against an unready single-feature checkpoint   250ms (134ms|116ms)
```

**The case now yields `deny`.** Both assertions hold: `permissionDecision` is exactly `deny`, and
`permissionDecisionReason` matches `PREIMPLEMENTATION_GATE_BLOCKED`.

## Artifact this supersedes

`docs/features/active/preimplementation-gate-blocks-epic-execution-554/evidence/regression-testing/fail-before-case-6b.2026-08-26T10-18.md`

That artifact recorded `EXIT_CODE: 1` with a matching `ExpectedExitCode: 1`, and the verbatim
assertion failure `Expected: 'deny' / But was: 'allow'` against the unmodified hook. This artifact
records the same `It` block, unchanged in text, now passing against the modified hook.

## The fail-before / pass-after pair, stated precisely

| | Fail-before (2026-08-26T10-18) | Pass-after (2026-08-26T11-36) |
| --- | --- | --- |
| Hook under test | unmodified `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | modified, per P3-T1 through P3-T6 |
| Test file | identical, byte-for-byte unedited between the two runs | identical |
| Observed decision | `allow` | `deny` |
| Asserted decision | `deny` | `deny` |
| Failed count | 1 | 0 |

The `It` block was **not** edited between the two runs. The only variable that changed is the hook's
`Test-ImplementationDelegation`, which P3-T2 replaced with the structural classifier. That isolation
is what makes this pair evidence of the fix rather than evidence of a rewritten assertion.

## Why the outcome changed

Pre-fix, `Test-ImplementationDelegation` serialized the whole `tool_input` object and matched seven
tokens against the resulting text. The fixture's payload is:

```json
{"subagent_type":"orchestrator","prompt":"Begin atomic execution of the approved plan for this feature."}
```

None of the seven tokens is present: no typed-engineer name, no `atomic-executor`, the word
`execution` does not contain the bare token `execute`, and `implementation` does not appear. The
classifier returned `$false`, the delegation was not classified as implementation, and the gate
short-circuited to allow without ever consulting the injected unready checkpoint.

Post-fix, the classifier performs field-scoped reads of `subagent_type` and `prompt` via
`Get-ClaudeHookToolInputString`. `subagent_type` is exactly `orchestrator`; the field-scoped prompt
carries no recognized mode marker, so `Resolve-OrchestrationDelegationMode` returns the default
single-feature mode; the delegation is therefore implementation and is evaluated against the
explicitly injected unready single-feature checkpoint (`route_id` empty, `lifecycle_ready` false),
which denies.

This is the one behaviour change this fix makes in the **allow-to-deny** direction. It is a
behaviour change rather than a preservation, and `spec.md` names it as such in its acceptance
criteria and in `## The Fault-1 wording-independence regression, in BOTH directions`.

## Determinism

The fixture supplies an explicit unready `-CheckpointRaw`. A case that omitted it would fall through
to the on-disk checkpoint at `artifacts/orchestration/orchestrator-state.json`, which is ready during
an orchestrated run, and the deny assertion would then be testing the wrong operand. No temporary
file, filesystem write, wall-clock read, network access, or external process is involved in either
run.

## Note on the exit-code reading

The `EXIT_CODE: 0` above is read from the Pester result object (`FailedCount = 0`, `Result =
Passed`), not from the process exit code. A bare `Invoke-Pester` exits 0 even with a failing case
because `Run.Exit` defaults to `$false`, so the process exit code is not a usable pass/fail signal
for this suite. The fail-before artifact handled the same hazard by computing `exit $r.FailedCount`
explicitly.
