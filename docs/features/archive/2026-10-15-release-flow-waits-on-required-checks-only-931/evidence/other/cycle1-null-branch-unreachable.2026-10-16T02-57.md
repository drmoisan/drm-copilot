# Cycle 1 Null-Element Branch Unreachable (Issue #931)

Timestamp: 2026-10-16T02-57
Probe artifact: cycle1-binder-probe.2026-10-16T02-49.md (greatest cycle1-binder-probe.*.md in evidence/baseline/)
PowerShell version line: 7.6.6

Per-form outcomes (diagnostic line quoted verbatim from the probe artifact, ANSI escapes removed):
- single-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`
- mixed-pass-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`
- unary-comma-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`
- cast-single-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`
- cast-mixed-pass-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`
- bare-null: REJECTED. `: Cannot bind argument to parameter 'Checks' because it is null.`

Claim (limited to the six forms actually observed): none of the six probed call forms reaches script line 213, the `$null -eq $check` guard, through the parameter binder on the probed runtime; call forms that were not probed are not covered by the claim.

The probe binds a stand-in scriptblock that declares [CmdletBinding()], [AllowEmptyCollection()], [Parameter(Mandatory = $true)] and [object[]]$Checks, matching script lines 201-206; it does not call Get-CheckSetVerdict itself.

No null-element test was added; the literal title for it occurs 0 times in the test file.

no production edit was made

Output Summary: null-element guard recorded unreachable for the six probed call forms; blank-bucket branch covered by the new test.
