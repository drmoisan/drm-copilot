# RED-NODE Before Edit (P1-T1, expect-fail, remediation cycle 2)

Timestamp: 2026-10-12T17-59

Command: poetry run pytest "tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant" -q

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- Summary line (verbatim): `1 failed in 0.09s`
- Assertion line (verbatim): `E       assert not ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported')`
- AssertionError message contains (verbatim): `covers: ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported')`
- Interpretation: before any edit, the persona grants cover neither the CI gate parser invocation nor the backticked `no checks reported` span, so the node discriminates the current tree.
