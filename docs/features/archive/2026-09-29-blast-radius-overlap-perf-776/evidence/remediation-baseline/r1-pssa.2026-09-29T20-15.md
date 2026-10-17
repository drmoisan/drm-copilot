# Pre-Remediation Analyzer Findings (remediation plan P0-T9)

Timestamp: 2026-09-29T20-15
Command: sh SCRATCH/run-ps.sh SCRATCH/pssa.ps1 .claude/lib/blast-radius/BlastRadiusConflict.psm1 .claude/lib/blast-radius/BlastRadiusScheduling.psm1
EXIT_CODE: 0
Output Summary:
- PSSA file=.claude/lib/blast-radius/BlastRadiusConflict.psm1 Findings=0
- PSSA file=.claude/lib/blast-radius/BlastRadiusScheduling.psm1 Findings=0
- PSSA-TOTAL=0
- PSSA-FINDING lines: none.
- Note: the first invocation of the same command exited 1 with "Invoke-ScriptAnalyzer: Object reference not set to an instance of an object." before printing any PSSA line (an analyzer exception, not a finding). The identical command was re-run immediately with no file change and exited 0 with the output above.
- Result: PASS.
