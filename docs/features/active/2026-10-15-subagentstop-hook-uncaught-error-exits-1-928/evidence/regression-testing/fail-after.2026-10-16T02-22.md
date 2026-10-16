# Fail-After Regression Run (issue #928)

Timestamp: 2026-10-16T02-11
Command: mcp__drm-copilot__run_poshqc_test (scan_folders ["tests/scripts/claude-hooks"], workspace_root WORKTREE_ROOT); then poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml subagentstop-uncaught-error.Tests.ps1
MCP_DISPOSITION: error (Command exited with code 6.)
EXIT_CODE: 0

Output Summary:
- MTIME_UTC 2026-10-16T02-22 (not earlier than Timestamp 2026-10-16T02-11)
- SUITE subagentstop-uncaught-error.Tests.ps1 MATCHED 10 FAILED 0
- TOTALS tests 4606 failures 6 errors 0. All six failures are outside the new suite and are recorded as findings (they block P6-T3):
  - `discovery guard (both hook surfaces).AC-6 tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1 calls the interception probe from inside an It` (enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1)
  - `E2 SubagentStop registrations and seams.REG-4 <Leaf> calls Exit-SubagentStopBlock once at script scope after the inline S1 tail` for validate-orchestrator-output.ps1, validate-executor-output.ps1, validate-planner-output.ps1, validate-required-artifact-output.ps1 (subagentstop-envelope-orchestrator-family.Registration.Tests.ps1:117; message `Expected 1, because <Leaf> must call Exit-SubagentStopBlock exactly once, but got 2.`)
  - `validate-required-artifact-output.ps1 SubagentStop envelope.E-RA-10 calls Exit-SubagentStopBlock exactly once, outside the missing-argument if block` (validate-required-artifact-output.Envelope.Tests.ps1:198; message `Expected 1 ... but got 2.`)

Per-test lines of the new suite (prefix `SubagentStop validator unhandled-error block (issue #928).` omitted):

- PASS U1: .claude/hooks/validate-discovery-artifact-gate.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-executor-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-feature-review-coverage.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-orchestrator-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-planner-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-pr-author-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-prd-feature-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-required-artifact-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-task-researcher-output.ps1 blocks with exit 2 when the validation call throws
- PASS U2: has a row for every hook that dot-sources subagentstop-envelope.ps1 and no other
