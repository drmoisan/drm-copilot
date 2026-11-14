# Task Check P1-T5

Timestamp: 2026-11-14T19-32
Changed files: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1 (433 lines), tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1 (197 lines)
Selection rule: the two changed test files themselves (test-only changes; their own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh <the two files> (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: both files formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectiveDecision.Tests.ps1
EXIT_CODE: 0
Output Summary: 123 passed, 0 failed, 0 skipped (2 shards). New rows present and passing: 'B5 digest of U+1F600 equals the SHA-256 of bytes F0 9F 98 80'; 'B5 accepts text containing <Name> with its UTF-8 digest' x3; 'B5 rejects text containing <Name> whose digest covers the substituted text' x3 (AC-11); 'parses a decision line whose reason contains <Name> and preserves it exactly' x3; 'accepts an honored decision whose reason contains <Name>' x3 (AC-8). The rows pass before any production change, as D-4 states. git status shows no change under .claude/lib/.
Note: an earlier invocation of the same selection at 2026-11-14T19-32 passed both paths as one comma-joined -TestPath value, found no test file, and started no shard; it was a command-form error, re-run with space-separated paths as above.

Correction (appended 2026-11-14T19-35): OrchestratorStateOwnerDirectives.Tests.ps1 has 423 lines (wc -l), not 433 as stated in the Changed files line above.
Clock note: the correction line above was written at 2026-11-14T19-35 (clock reading), not 19-35.
Resolution: the clock read 2026-11-14T19-34 in the call that appended the correction and 2026-11-14T19-35 in the next call, so the correction was written at the 19-34/19-35 minute boundary; the clock note above adds no other fact.
