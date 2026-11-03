# Line Counts Baseline (Remediation Cycle 1, Issue #1006)

Timestamp: 2026-10-31T09-11
Command: wc -l (via sh SCRATCH/issue-1006-counts.sh) over the three CYCLE_FILES
EXIT_CODE: 0
Output Summary: 126, 465, and 301 physical lines; all below 500.

| File | Physical lines |
|---|---|
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay-demote.ts` | 126 |
| `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts` | 465 |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` | 301 |
