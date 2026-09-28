# Pre-Existing Suites, Run Unmodified After the Batch B Edits (issue #554)

Timestamp: 2026-08-26T11-11

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

EXIT_CODE: 1

Output Summary:

| Suite | Passed | Failed | Skipped |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 58 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | **0** | 0 |
| `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 58 | **0** | 0 |
| `PreToolUseSchema.Contract.Tests.ps1` | 15 | **0** | 0 |
| `legacy-codex-hook-contracts.Tests.ps1` | 42 | **1** | 0 |
| **Aggregate** | **241** | **1** | **0** |

The pass/fail counts are read from each run's Pester result object, never from a bare
`Invoke-Pester` exit code: `Run.Exit` defaults to `$false`, so a bare invocation exits 0 even with a
failing case. The aggregate failed count is propagated as the recorded exit code.

## P3-T20 Remains UNCHECKED — the One Failing Case and Why

The single failing case is:

```text
Legacy Codex hooks use native lifecycle contracts
  > keeps the canonical hooks byte-identical to their bundled copies
    Expected strings to be the same, because
    enforce-orchestration-preimplementation-gate.ps1 must publish without drift,
    but they were different.
```

That case compares each name in the suite's static-check list against its copy under
`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. Measured hashes:

| File | Root vs bundle |
| --- | --- |
| `enforce-orchestration-preimplementation-gate.ps1` | **DIFFER** — root `b978bad8b304...`, bundle `db69f084eea3...` |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | MATCH |
| `codex-pretooluse-file-mapping.ps1` | MATCH |

The bundled hash `db69f084eea38ef30f273b95c07a994a17e1f4b6b4963eb39388f4021533f350` is **exactly** the
Codex main gate hook hash recorded in the Phase 0 baseline artifact `phase0-hook-hashes`. The
bundled copy is therefore untouched, and the divergence is entirely the Batch B edit to the
self-hosted `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.

**This is a plan-sequencing condition, not a defect in the Batch B work.** The mirror byte-copy that
resolves it is task **P4-T3**, in Phase 4, which is out of scope for this execution pass. The plan
places the six-suite verification at P3-T20 and the four mirror copies at P4-T1 through P4-T4, so
the assertion at P3-T20 cannot pass by construction once either main gate hook has been edited and
before its mirror has been re-copied.

**Remedy, for the Phase 4 executor:** after P4-T3 copies
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` to its bundled path, re-run this
six-suite command. Every other assertion in the failing suite already passes, including the two that
pin `Test-ImplementationDelegation` to true for `atomic-executor` and false for `task-researcher`
against the replaced structural classifier, and the assertion that every root and bundled hook parses
and stays within 500 lines.

The same pending-mirror condition applies to the Claude surface, but no Claude-side suite in this set
asserts bundled byte-identity, so it produces no failure here.

## The Second Half of the P3-T20 Acceptance Condition Is Satisfied

None of the six suite files appears in the branch diff. `git diff --name-only origin/main...HEAD`
returns 23 paths, and none of them is any of the six:

- the two new production modes files,
- the new Claude mode-resolution suite (new, not an edit to a pre-existing suite),
- the feature documents, research artifact, and evidence artifacts.

The worktree additionally carries the uncommitted Batch B edits to the two main gate hooks, the new
Codex mode-resolution suite, and this phase's evidence artifacts. No pre-existing test file is
modified in either the committed diff or the working tree.
