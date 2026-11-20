# planner-output-validator-rejects-blank-lines (Potential Bug)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Draft
- Severity: High — an enforcement gate that cannot execute its check

## Summary

`.claude/hooks/validate-planner-output.ps1` cannot validate any plan file that contains a blank
line. Because every realistic Markdown plan contains blank lines, the `atomic-planner` `SubagentStop`
gate never actually runs its atomic-plan-contract structure check. It fails with an internal
parameter-binding error before the check begins.

## Root cause

`Get-PlanStructureValidationReport` declares:

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string[]] $Lines
)
```

For a `[string[]]` parameter, PowerShell's `Mandatory` validation rejects an array that contains an
empty-string element. `Get-PlanFileContent` (same file, lines 37-57) reads the plan with
`Get-Content -LiteralPath $Path`, which returns one array element per line **including blank lines**,
and passes that array through unfiltered:

```powershell
$errors = @(Get-PlanStructureValidationReport -Lines $file.Lines)
```

So the binding fails for any plan with at least one blank line.

## Reproduction

Minimal, with a passing control, run from the repo root:

```powershell
. ./.claude/hooks/validate-planner-output.ps1

# Fails: array contains one empty-string element
Get-PlanStructureValidationReport -Lines @('### Phase 0 — X', '', '- [ ] [P0-T1] do a/b.md')
# -> Cannot bind argument to parameter 'Lines' because it is an empty string.

# Control: identical content with the blank line removed
Get-PlanStructureValidationReport -Lines @('### Phase 0 — X', '- [ ] [P0-T1] do a/b.md')
# -> binds and returns normally
```

End-to-end against a real plan, which is how it was found:

```powershell
$plan = 'docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/plan.2026-08-19T08-50.md'
$out = "plan-path: $plan" + [char]10 + "PREFLIGHT: REVISIONS REQUIRED"
$env:CLAUDE_HOOK_INPUT = (@{ output = $out } | ConvertTo-Json -Compress)
& .claude/hooks/validate-planner-output.ps1
# -> Invoke-PlannerOutputValidation: ... Cannot bind argument to parameter 'Lines'
#    because it is an empty string.  (exit 1)
```

Confirmation that the check itself is sound once the input binds: filtering blank lines out of the
same 259-line plan yields `structure error count: 0`.

## Impact

- The `atomic-planner` `SubagentStop` gate does not enforce the atomic-plan-contract structure rules
  (phase sequencing, task numbering, heading format, the path-token requirement at lines 87-97).
  Every plan passes or blocks for the wrong reason.
- The failure mode depends on whether the hook fires. If it fires, `exit 1` blocks every planner
  delegation on a spurious internal error. If it does not fire, the check is silently absent. Both
  outcomes are wrong, and the second is how this behaved in practice during issue #491 — planner
  delegations completed while the structural check never ran.
- This is the "verification gate that cannot fail" pattern: the gate appears to exist and is
  registered, but no plan content can ever reach its assertions.

## Proposed Fix

Filter blank lines at the reader boundary, or relax the parameter contract. The reader boundary is
the safer change because the structure checks are per-line regex matches and are unaffected by the
removal of blank lines:

```powershell
# in Get-PlanFileContent, after reading
$lines = @($lines | Where-Object { $_ -ne '' })
```

Alternatively, replace `[Parameter(Mandatory = $true)]` with a non-validating declaration plus an
explicit null/empty-collection guard inside the function. Do not use `AllowEmptyString` on the
element type alone without confirming the array-level behavior.

## Test Conditions to Consider

- [ ] `Get-PlanStructureValidationReport` accepts an array containing empty-string elements.
- [ ] `Get-PlanFileContent` output binds to `Get-PlanStructureValidationReport` for a plan file that
      contains blank lines, leading blank lines, and consecutive blank lines.
- [ ] End-to-end hook invocation against a real multi-phase plan with blank lines returns exit 0 for
      a conformant plan.
- [ ] Negative control: a plan with a task lacking a path token is still rejected after the fix, so
      the fix does not disable the check it repairs.
- [ ] A plan consisting only of blank lines is handled without an unhandled exception.

## Next Step

- [ ] Promote to GitHub issue (bug template)
- [ ] Audit the other `.claude/hooks/validate-*.ps1` gates for the same `[Parameter(Mandatory)]`-on-
      `[string[]]` pattern, since the defect class is copyable and may be present elsewhere.
