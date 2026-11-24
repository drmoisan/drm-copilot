# Fail-before: F2 (TypeScript missingObjectKeys treats JSON null as present) (RC2 P1-T3)

Timestamp: 2026-11-24T18-39
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=test/lib/validate/(orchestrator-state-child-ci|orchestrator-state-core[.]completion)[.]test[.]ts$" --json --outputFile=SCRATCH/issue-1233-rc2-fb-f2.json (through SCRATCH/issue-1233-rc2-jestsel.sh and SCRATCH/issue-1233-retry.sh)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- State: P1-T1 fixtures and P1-T2 rows present; extensions/drm-copilot/src unchanged (git diff --stat of extensions/drm-copilot/src empty), so missingObjectKeys still counts only undefined and whitespace-only strings as missing.
- First attempt, no queue timeout. Suites total=2, failed=2; tests total=42, passed=38, failed=4.
- Failing rows (exactly four, by name):
  - orchestrator-state child CI opt-out > matches the corpus for local-qc-gate-null-fields.json
  - orchestrator-state child CI opt-out > matches the corpus for local-qc-gate-null-heads.json
  - validateOrchestratorStateText completion gates > rejects a ci_gate whose required fields are null
  - validateOrchestratorStateText completion gates > rejects a pr_gate whose required fields are null
- Every other row of both files passes.
- Python and PowerShell pass the same two fixtures: see the P1-T1 task check (evidence/other/task-check.RC2-P1-T1.2026-11-24T18-38.md): test_child_ci_corpus_matches_expected_errors[local-qc-gate-null-fields] and [local-qc-gate-null-heads] PASSED; OCC-CORPUS-local-qc-gate-null-fields and OCC-CORPUS-local-qc-gate-null-heads passed.
