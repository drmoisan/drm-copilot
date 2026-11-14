# Task Check P1-T6

Timestamp: 2026-11-14T19-35
Changed files: tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1 (362 lines)
Selection rule: the changed test file itself (a test-only change; its own rows are the selection).

Command: sh SCRATCH/issue-1187-st.sh tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1 (check-only Invoke-Formatter, Invoke-ScriptAnalyzer with the repo settings, count of lines holding a character above U+007F)
EXIT_CODE: 0
Output Summary: formatter-unchanged=True, pssa-findings=0, non-ASCII lines=0.

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectivePassDown.Tests.ps1
EXIT_CODE: 0
Output Summary: merged JUnit of this run: tests=55, failures=0, errors=0. The four new rows of Describe 'non-ASCII directive text (issue #1187)' are present and pass: 'allows an item checkpoint that holds every selected non-ASCII entry', 'blocks an item checkpoint missing a non-ASCII entry selected from the item ledger' (OWNER_DIRECTIVE_RELAY_MISSING, lacks OD-3) (AC-9); 'accepts non-ASCII item ledger lines with matching digests', 'reports a non-ASCII ledger line with a mismatched digest as OWNER_DIRECTIVE_LEDGER_INVALID' (AC-10). git status shows no change under .claude/, so no stop-hook file changed.
