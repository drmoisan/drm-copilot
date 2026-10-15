# Remediation Timing Comparison for AC-2 (P2-T7)

Timestamp: 2026-09-29T20-33
Command: awk 'BEGIN { printf "RATIO=%.2f\n", 213.12 / 40.09 }'
EXIT_CODE: 0
Output Summary:
- Subject: tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1, coverage disabled, same host, Pester 5.6.1.
- Baseline median (ORIGINAL-BASELINE P0-T10, evidence/baseline/historical-runs-timing.2026-09-29T19-09.md): 213.12 s.
- Post-remediation median (P2-T6, evidence/qa-gates/r1-historical-runs-timing.2026-09-29T20-33.md): 40.09 s.
- RATIO=5.32
- Threshold (R6): at least 4.00 (median at most 53.28 s).
- Result: PASS. This closes remediation finding F-1 (RATIO=2.60 in cycle 0).
