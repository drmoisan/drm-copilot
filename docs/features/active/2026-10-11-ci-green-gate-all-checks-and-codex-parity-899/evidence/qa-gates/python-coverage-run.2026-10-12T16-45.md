# Python Coverage Run (P1-T1)

Timestamp: 2026-10-12T17-14

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov.info --cov-report=json:artifacts/python/issue-899-coverage.json

EXIT_CODE: 1

Output Summary:
- Pytest summary line (verbatim): `============ 1 failed, 7003 passed, 6 skipped in 73.58s (0:01:13) =============`
- Passed 7003, failed 1, skipped 6.
- Table header: `Name    Stmts   Miss Branch BrPart  Cover   Missing`
- TOTAL row (verbatim): `TOTAL                                                                 17633   1094   6364    505    92%`
- Report lines (verbatim): `Coverage JSON written to file artifacts/python/issue-899-coverage.json` and `Coverage LCOV written to file artifacts/python/lcov.info`
- KL-510 was NOT the failure. KL-510 does not apply, so no `ExpectedExitCode` is declared and the exit code 1 is an unexpected failure. Per PD3 this is recorded as a non-KL-510 failure and the plan continued to P1-T2 so the coverage figures are still recorded.

Failed node (verbatim):
`FAILED tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant`

Assertion message (verbatim, from `tests\scripts\dev_tools\test_parallel_orchestrator_permission_contracts.py:106`; the trailing parsed-invocation list is omitted here for length):
`AssertionError: the parallel-orchestrate procedure prescribes a command invocation no parallel-orchestrator Bash grant covers: ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported'). Declared Bash grants are ('git *', 'gh *', 'poetry run python -c *', 'bash .claude/lib/bash/compute-cohorts.sh*', 'bash .claude/lib/bash/compute-concurrency-batches.sh*', 'bash .claude/lib/bash/validate-parallel-manifest.sh*', 'bash .claude/lib/bash/abandon-parallel-item.sh*', 'bash .claude/lib/bash/remove-parallel-item.sh*', 'pwsh -NoProfile -File .claude/lib/project-file-merge/Resolve-MergeableConflict.ps1*', 'pwsh -NoProfile -NonInteractive -File .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1*', 'dotnet tool restore*', 'dotnet csharpier check *', 'dotnet build *'). Every parsed invocation was (...)`
Secondary assertion line: `assert not ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported')`
