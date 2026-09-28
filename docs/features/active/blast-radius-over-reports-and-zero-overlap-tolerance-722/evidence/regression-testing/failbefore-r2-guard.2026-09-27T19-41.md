# R2 Fail-Before: Guard Suite (Remediation Cycle 1, P0-T13) [expect-fail]

Timestamp: 2026-09-27T19-41
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
EXIT_CODE: 0
ExpectedExitCode: 0

(A2 exits 0 whatever the test outcome; the fail signal is FailedCount.)

## Output (verbatim summary lines)

```text
TotalCount=27
PassedCount=26
FailedCount=1
FAILED: enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree
```

Finding line from the Pester Detailed output (ANSI colour codes removed):

```text
    .claude/lib/blast-radius/BlastRadiusScheduling.psm1:384 [DynamicInvocation] in Get-BlastRadiusPairDecision: ampersand-invoked variable $relation is not a [scriptblock] parameter, so its target cannot be verified statically (fail-closed), but got 1.
```

## Checks

- FailedCount=1: yes.
- Exactly one FAILED line, ending with "reports no Python invocation beyond the allowlist across the guarded tree": yes.
- Output contains the literal "ampersand-invoked variable $relation is not a [scriptblock] parameter": yes.

Output Summary: PASS (expect-fail task; R2 reproduced). Exit 0; TotalCount=27, PassedCount=26, FailedCount=1; the single failure is the guarded-tree scan It, reporting BlastRadiusScheduling.psm1:384 [DynamicInvocation] for $relation.
