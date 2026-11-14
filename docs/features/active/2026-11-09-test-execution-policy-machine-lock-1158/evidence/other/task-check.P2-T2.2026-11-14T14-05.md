# Task Check: P2-T2 (remediation cycle 1, F1 Python QA gate)

Timestamp: 2026-11-14T14-05
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (red run before the surface edit); sh SCRATCH/issue-1158-ps-filestatic.sh; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <wording, cadence, and ledger suites>; sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <three push-down contract files>
EXIT_CODE: 0
Output Summary: the six new PGW-LAUNCHER rows (QA-PY-CLAUDE, QA-PY-AGENTS, QA-PY-CLAUDE-BUNDLE, QA-PY-AGENTS-BUNDLE, COPILOT-PY-EXEC, COPILOT-PY-EXEC-BUNDLE) failed on the pre-edit text (96 passed, 6 failed) and pass after it. The first post-edit run failed the existing rows PGW-COPILOT-PY-EXEC and PGW-COPILOT-PY-EXEC-BUNDLE, which require 'poetry run pytest -n auto'; the Copilot step 4 command now ends ", which runs `poetry run pytest -n auto`" (the same form as the executor bullet), so those rows pass unchanged. Final scoped Pester run: 258 tests, 0 failures (parallel-gate-wording 102, test-cadence-wording 136, ledger chain 5, ledger index 15); push-down contract pytest 85 passed; copy hashes equal; format 0 diffs and PSScriptAnalyzer 0 findings.

## Changed Files

- .claude/skills/python-qa-gate/SKILL.md and .agents/skills/python-qa-gate/SKILL.md (step 4: the launcher pytest suite with the coverage arguments, each with its own launcher path), with both bundle copies re-copied
- .github/agents/python-atomic-executor.agent.md (step 4 of 7.1 with the .claude launcher path), with its bundle copy re-copied
- tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 (six PGW-LAUNCHER rows)
- docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch (six + lines; the parallel-gate-wording creation hunk) and docs/engineering/process-reductions/0001-parallel-only-test-gates.md (Rebased over #1158 paragraph extended); the 0006 hunks needed no change, because the new rows sit outside them

## Selection and Rule

Contract tests that read the changed skill, agent, and ledger paths: parallel-gate-wording.Tests.ps1, test-cadence-wording.Tests.ps1 (QAGATE and EXECUTOR rows), the two ledger suites, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_issue_824_follow_ups.py.

| Command | EXIT_CODE |
|---|---|
| scoped pester, parallel-gate-wording only, before the surface edit (expected red) | 1 |
| scoped pester, four suites, first post-edit run (PGW-COPILOT-PY-EXEC rows) | 1 |
| scoped pester, four suites, after the step 4 wording fix | 0 |
| launcher pytest, three contract files | 0 |
