# Pre-Existing Suites — Re-Check After the Four Phase 4 Mirror Byte-Copies (issue #554)

Timestamp: 2026-08-26T11-20

This artifact records the **re-run** of the P3-T20 six-suite verification, executed after P4-T1
through P4-T4 copied all four mirrored production files. It does **not** replace
`pre-existing-suites.2026-08-26T11-11.md`, which remains the honest record of the intermediate state
in which the Codex bundled mirror had not yet been re-copied. Both artifacts are retained.

Command:

```powershell
$suites = @(
    'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1',
    'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1',
    'tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1',
    'tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1',
    'tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1'
)
$total = 0
foreach ($s in $suites) {
    $c = New-PesterConfiguration
    $c.Run.Path = $s
    $c.Run.PassThru = $true
    $c.Output.Verbosity = 'None'
    $r = Invoke-Pester -Configuration $c
    $total += $r.FailedCount
}
exit $total
```

The command is **identical** to the one recorded in `pre-existing-suites.2026-08-26T11-11.md`. No
suite file was edited, and no assertion was weakened.

EXIT_CODE: 0

Output Summary:

| Suite | Passed | Failed | Skipped |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 58 | **0** | 0 |
| `PreToolUseSchema.Contract.Tests.ps1` | 15 | **0** | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 43 | **0** | 0 |
| **Aggregate** | **242** | **0** | **0** |

Every per-suite failed count is the integer 0 and the aggregate exit code is 0.

The pass/fail counts are read from each run's Pester result object (`$r.PassedCount`,
`$r.FailedCount`, `$r.SkippedCount`), never from a bare `Invoke-Pester` exit code: `Run.Exit`
defaults to `$false`, so a bare invocation exits 0 even with a failing case.

## What Changed Between the Two Runs

The only difference is the four mirror byte-copies applied by P4-T1 through P4-T4. No test file was
touched, and no production logic was altered between the two runs.

The single case failing at 2026-08-26T11-11 was:

```text
Legacy Codex hooks use native lifecycle contracts
  > keeps the canonical hooks byte-identical to their bundled copies
```

It failed because `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` carried the Batch B
edit while its bundled mirror still held the Phase 0 baseline content. `legacy-codex-hook-contracts.Tests.ps1`
therefore reports **43 passed, 0 failed** here against **42 passed, 1 failed** before — the same 43
assertions, with the byte-identity assertion now satisfied by the P4-T3 copy.

Measured hashes at this run, root versus bundle:

| File | Root | Bundle | Verdict |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | `B978BAD8B304B2917AFBE524F0043F5018FF0F06C7719A27550C6E888A3B706D` | MATCH |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | `8E1165818AE0AE20B63486D2AA51D98A7875FEA9BA7D2F15E0762DF850AA4F0A` | MATCH |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `45C339FD4B4B1702230518B6FCDEB863A08BCB7A7540F46C5F7851C730765C0B` | (unchanged) | MATCH |

The two assertions that pin `Test-ImplementationDelegation` to true for `atomic-executor` and false
for `task-researcher` against the replaced structural classifier pass in both runs.

## Second Half of the P3-T20 Acceptance Condition

None of the six suite files appears in the branch change set. Checked against the union of
`git diff --name-only origin/main...HEAD` and `git status --porcelain`:

| Suite path | Result |
| --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | ABSENT |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | ABSENT |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | ABSENT |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | ABSENT |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | ABSENT |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | ABSENT |

P3-T20 is therefore checked off on this artifact.
