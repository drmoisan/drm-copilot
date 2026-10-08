# Pre-Remediation Export Surface Subset (remediation plan P0-T7)

Timestamp: 2026-09-29T20-13
Command: ls docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline; sh SCRATCH/run-ps.sh SCRATCH/export-subset.ps1 -BaselineArtifact docs/features/active/2026-09-29-blast-radius-overlap-perf-776/evidence/baseline/export-surface.2026-09-29T18-58.md -ExpectedAddition NONE
EXIT_CODE: 0
Output Summary:
- The baseline listing holds exactly one file starting `export-surface.`: export-surface.2026-09-29T18-58.md (BASELINE_EXPORT_ARTIFACT).
- A13 output: BASELINE-COUNT=64, CURRENT-COUNT=64, MISSING-COUNT=0, ADDED-COUNT=0, SUBSET-RESULT=PASS.
- Result: PASS. The post-Phase-1 tree exports the same 64 signatures as ORIGINAL-BASELINE.
