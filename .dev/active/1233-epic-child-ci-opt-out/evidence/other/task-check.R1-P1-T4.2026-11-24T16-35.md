# Task check R1 P1-T4 (completion-helper ordinal pins)

Timestamp: 2026-11-24T16-35
Changed files: tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1 (created). No hook file changed: git status --porcelain lists no change to .claude/hooks/enforce-completion-helpers.ps1, .codex/hooks/enforce-completion-helpers.ps1, or their bundle copies, so the four helper copies keep their identity.
Selection rule: the new file and tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1, per the P1-T4 acceptance.

Command: sh SCRATCH/issue-1233-ps-files.sh check tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1
EXIT_CODE: 0
Output Summary: already formatted, drift 0, 0 PSSA findings.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/codex-hooks/enforce-completion-helpers.OrdinalKeys.Tests.ps1 tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1 (through SCRATCH/issue-1233-r1-pester.sh)
EXIT_CODE: 0
Output Summary: workers=2, wall-clock 116.66s; merged JUnit tests=57, failures=0, errors=0. New rows passing: CH-ORD-PREDICATE (Child_CI, Epic_Mode), CH-ORD-PREDICATE-CONTROL, CH-ORD-GATE (Local_QC_Gate, gate Conclusion, gate Head_Sha, gate Evidence_Path), CH-ORD-GATE-CONTROL. Attempt 1 exited 75 (queue timeout). Selection coverage of .codex/hooks/enforce-completion-helpers.ps1 90/90 (100%).
Note: these rows pin behavior that was already ordinal (P1-T1 rows 30 to 35), so no fail-before run applies; a row would fail if either function compared key names case-insensitively.
