# Cycle 1 Binder Probe (Issue #931)

Timestamp: 2026-10-16T02-49
Command: sh SCRATCH/binder-probe.sh
EXIT_CODE: 0
PowerShell version: 7.6.6

Note: the raw output carried ANSI colour escape sequences (ESC[31;1m ... ESC[0m) around the message; they are omitted below. In this run the message line was printed without a ` | ` gutter. Each line quoted below is the full diagnostic output line with escapes removed. PROBE_EXIT was 1 for every form.

## Form: single-null
Argument: @($null)
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

## Form: mixed-pass-null
Argument: @([pscustomobject]@{bucket=1}, $null)
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

## Form: unary-comma-null
Argument: (,$null)
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

## Form: cast-single-null
Argument: ([object[]]@($null))
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

## Form: cast-mixed-pass-null
Argument: ([object[]]@([pscustomobject]@{bucket=1}, $null))
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

## Form: bare-null
Argument: $null
Output:
: Cannot bind argument to parameter 'Checks' because it is null.
Outcome: REJECTED
Diagnostic line: `: Cannot bind argument to parameter 'Checks' because it is null.`

Output Summary: binder-rejects-null-element
- single-null: REJECTED
- mixed-pass-null: REJECTED
- unary-comma-null: REJECTED
- cast-single-null: REJECTED
- cast-mixed-pass-null: REJECTED
- bare-null: REJECTED
