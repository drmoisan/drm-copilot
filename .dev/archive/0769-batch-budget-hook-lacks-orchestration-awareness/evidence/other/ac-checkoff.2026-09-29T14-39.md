# Acceptance-Criteria Check-Off (#769, P12-T1 to P12-T23)

Timestamp: 2026-09-29T14-39
Command: for n in 1..23: git grep -c -F -e "- [x] AC-n:" -- FEATURE/spec.md FEATURE/issue.md
EXIT_CODE: 0
Output Summary: each of AC-1 through AC-23 prints one path:count line for spec.md and one for issue.md. Only `- [ ]` was changed to `- [x]`; no criterion text was changed.

Each criterion was checked against its cited artifacts (all dated 2026-09-29T14-39) before check-off:

| AC | Evidence (task: artifact) |
| --- | --- |
| AC-1 | P1-T2 regression-testing/claude-routing-before-fix (47/47 failed); P2-T9 regression-testing/claude-routing-after-fix (47/47 passed) |
| AC-2 | P4-T2 regression-testing/codex-routing-before-fix (49/49 failed); P5-T5 regression-testing/codex-routing-after-fix (49/49 passed) |
| AC-3 | P2-T9, P5-T5 (case D4 in each suite) |
| AC-4 | P2-T9, P5-T5 (large-path cases); P2-T12 regression-testing/live-state-after-claude-fix; P9-T11 qa-gates/live-state-final (prod sum 1, test sum 1, unchanged after the large-path writes) |
| AC-5 | P2-T9, P5-T5 (route rows 9 to 13, case L3) |
| AC-6 | P2-T9, P5-T5 (route rows 4 to 8 and 14 to 21, cases D6, S1, S3) |
| AC-7 | P2-T9, P5-T5 (cases P1, P2); P2-T10 regression-testing/claude-existing-after-fix (36/36) |
| AC-8 | P2-T9, P5-T5 (override cases); P2-T1 (no CLAUDE_POWERSHELL_BUDGET in CHOOK, recorded in regression-testing/live-route-probe-inline) |
| AC-9 | P2-T10 (36/36); P2-T11 regression-testing/pretooluse-schema (15/15); P5-T6 regression-testing/codex-existing-after-fix (41/41); P5-T8 regression-testing/codex-contracts (106/106). The Codex hook has no containment filter, so the out-of-root clause applies to the Claude hook. |
| AC-10 | P5-T8 regression-testing/codex-contracts (legacy-codex-hook-contracts passes) |
| AC-11 | P9-T12 qa-gates/ac11-no-temp-files (exit 1, no output); seam cases of P2-T9 and P5-T5 |
| AC-12 | P2-T9 (47/47), P2-T10 (36/36), P5-T5 (49/49), P5-T6 (41/41) |
| AC-13 | P0-T22 baseline/ac13-sweep (non-vacuity); P7-T9 qa-gates/ac13-sweep (exit 1, no output) |
| AC-14 | P0-T23 baseline/ac14-threshold (non-vacuity); P6-T11 qa-gates/ac14-threshold |
| AC-15 | P0-T24 baseline/ac15-orchestrator-name (non-vacuity); P6-T12 qa-gates/ac15-orchestrator-name |
| AC-16 | P6-T13 qa-gates/ac16-budget-input |
| AC-17 | P7-T5 other/codex-variants-regenerated (met after the orchestrator-authorized manifest restore); P7-T6 qa-gates/codex-variants-check; P7-T7 regression-testing/codex-surface-contracts (23 passed) |
| AC-18 | P3-T5 regression-testing/claude-bundle-contracts; P5-T8 regression-testing/codex-contracts; P6-T14 regression-testing/text-surface-contracts; P7-T7; P10-T1 qa-gates/python-parity; P11-T3 qa-gates/mirror-hashes-final (16 pairs, unequal=0). test_bundled_claude_payload_contains_all_repo_runtime_contracts satisfies KL-510 case (b) (STATE-ONLY, pre-existing issue #510) in every run; all other nodes pass. |
| AC-19 | P11-T1 qa-gates/ac19-policy-unchanged |
| AC-20 | P2-T13 qa-gates/line-counts-p2; P5-T9 qa-gates/line-counts-p5; P9-T10 qa-gates/line-counts-final; P5-T8 (500-line contract passes) |
| AC-21 | P9-T1 qa-gates/powershell-format; P9-T2 qa-gates/powershell-analyze; P9-T4 qa-gates/claude-hook-coverage; P9-T5 qa-gates/codex-hook-coverage; P9-T6 qa-gates/changed-line-coverage; P11-T4 qa-gates/coverage-comparison (Disposition: PASS) |
| AC-22 | P11-T2 qa-gates/ac22-docstrings |
| AC-23 | P8-T4 other/follow-up-entries |
