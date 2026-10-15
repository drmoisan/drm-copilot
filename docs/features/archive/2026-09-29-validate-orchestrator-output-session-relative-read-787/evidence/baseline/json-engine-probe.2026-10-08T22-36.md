# JSON Engine Probe (P0-T16)

Timestamp: 2026-10-08T22-36
Command: sh SCRATCH/run-ps.sh SCRATCH/json-engine-probe.ps1
EXIT_CODE: 0
Output Summary:
CFJ_NAN_ACCEPTED=True
CFJ_DEPTH70_ACCEPTED=True
STJ_NAN_REJECTED=True
STJ_DEPTH70_REJECTED=True
PWSH_VERSION=7.6.6

Result: PASS. ConvertFrom-Json accepts the NaN literal and 70-deep nesting; System.Text.Json with default options rejects both, so rows H9 and H10 are satisfiable.
