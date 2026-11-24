# Final QC - pytest Gate (P3-T4)

Timestamp: 2026-11-24T07-02
Command: env -u VIRTUAL_ENV sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -rf --junitxml=SCRATCH/issue-1221-final-pytest.xml (one pytest -n auto run through the launcher, run by SCRATCH/issue-1221-final-py.sh)
EXIT_CODE: 0
Output Summary: 17104 passed, 6 skipped, 0 failed, 0 errors (17110 test cases in the JUnit file), 80.09 s. The four push-down contract files all passed: test_push_down_claude_resource_contracts.py 14 passed, test_push_down_codex_and_agents_resource_contracts.py 9 passed, test_push_down_claude_pack_manifest_completeness.py 2 passed, test_push_down_pack_manifest_dependency_closure.py 18 passed (43 total, 0 failures, counted per classname in the JUnit file).

## Queue Timeouts

One launcher exit 75 (machine test-suite lock held by another worktree) preceded the recorded run; it is a queue timeout, re-run, not a failure.

## Notes

No Python file is changed by this item; the gate proves that the bundle copies, the new module's `core.json` entry, and its `$PSScriptRoot` dependencies satisfy the push-down contracts (AC-23).
