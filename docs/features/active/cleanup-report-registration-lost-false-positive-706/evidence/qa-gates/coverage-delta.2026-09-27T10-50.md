# Coverage Delta: scripts/bash/cleanup_worktrees_scan_helper.sh (P4-T14)

Timestamp: 2026-09-27T10-50
Command: comparison of recorded values (no new command; sources are the P0-T13, P0-T14, P4-T10, P4-T12, and P4-T13 artifacts)
EXIT_CODE: 0
Output Summary: Overall 93.3% -> 93.3% (delta 0.0); per-file line-rate 0.868 (46/53) -> 0.875 (49/56) (delta +0.007, +3 covered of +3 instrumented); new-code coverage 6/6 lines hit. PASS.

| Measure | Baseline (run 36324413557) | Post-change (run 36326020967) | Difference |
| --- | --- | --- | --- |
| Overall `Bash coverage (lines)` | 93.3% | 93.3% | 0.0 |
| Per-file line-rate | 0.868 | 0.875 | +0.007 |
| Per-file covered/total | 46/53 | 49/56 | +3/+3 |
| Zero-hit lines | 7 | 7 | 0 |

New-code coverage (P4-T13): 6 of 6 new or modified instrumented lines have non-zero hits (lines 83, 84, 94, 116, 117, 119; baseline pre-change lines 91, 92, 94 each had hits=1).

Acceptance: post-change overall headline 93.3 >= 85.0; post-change per-file line-rate 0.875 >= 0.85; every instrumented new or modified line has non-zero hits.
