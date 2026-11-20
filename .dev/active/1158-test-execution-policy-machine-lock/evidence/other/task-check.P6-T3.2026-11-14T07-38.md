# Task Check: P6-T3

Timestamp: 2026-11-14T07-38
Command: sh SCRATCH/issue-1158-pycheck.sh (black --check, ruff check --no-fix, pyright on `test_execution_environment_brief_contracts.py`, then `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest -q <selection>`); sh SCRATCH/issue-1158-pester-files.sh (selection below, Run.Exit $true); sha256sum over the six brief copies
EXIT_CODE: 1
Output Summary: black, ruff, and pyright clean; pytest selection 123 passed, 6 failed; the 6 failures are the six rows of the new `test_brief_copy_states_test_execution_policy`, each missing only `CI integration and golden lanes are evidence` and `non-blocking deviation`, which P6-T7 writes (the plan states these lane-token assertions pass after P6-T7). Pester selection 458 passed, 0 failed, including both ledger test files. The six brief copies share one SHA-256.

## Changed Files

- `.claude/skills/execution-environment/SKILL.md` and its five byte-identical copies (`.agents`, `.github`, and the three bundle copies): a `Test suites (#1158)` bullet at the end of `## Tool Routes by Agent`; a `Test-execution hook (#1158)` bullet at the end of `## Command-Text Restrictions` (deny prefix and the D25 statement that prefixes do not hide a runner); a launcher and MCP-gap bullet at the end of `## PowerShell Route and PoshQC MCP Limits` (names the extension release and states that an MCP Pester run is not gate evidence); a launcher bullet in `## Test Runtime` before `Fix repeated production work first`; a queue re-run and exit-2 bullet at the end of `## Test Isolation Checks`; a contract-test line before the `test_push_down_issue_824_follow_ups.py` line; and a new final `## Test Execution Policy` section stating that the test-execution launcher governs.
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: `## Test Execution Policy` added to `_REQUIRED_HEADINGS`; new `test_brief_copy_states_test_execution_policy`, one row per copy.
- `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch`: the first brief hunk (`@@ -39,8 +39,9 @@`), which covers all of `## PowerShell Route and PoshQC MCP Limits`, regenerated in all six brief sections to carry the new bullet as a context line (`@@ -39,9 +39,10 @@`).
- `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`: `Rebased over #1158 (execution-environment brief)` paragraph.

Ledger placement: a first placement put the contract-test line inside the trailing context of the `0006` hunk at +111 and the Test Runtime line inside the `0001` hunk at +151; the chain test failed, and both lines were moved before the hunks. Entries `0002`, `0003`, and `0011` record single blocks in the brief; no addition splits one.

## Selection and Rule

Rule: for a changed Markdown path, the contract tests that read it; for the changed test file, the file itself (`## Test Cadence (Mandatory)`); for the ledger rule, the ledger tests.

- pytest: `test_execution_environment_brief_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_typescript_toolchain_instruction_contracts.py`, `test_push_down_issue_824_follow_ups.py`.
- Pester: `ProcessReductionChain.Ledger.Tests.ps1`, `ProcessReductionLedger.Index.Tests.ps1`, `test-cadence-wording.Tests.ps1`, `parallel-gate-wording.Tests.ps1`, `planning-contract-wording.Tests.ps1`, `concurrent-review-skill-contract.Tests.ps1`, `light-remediation-skill-contract.Tests.ps1`.

## Commands and Exit Codes

| Step | Command | EXIT_CODE |
|---|---|---|
| format | `poetry run black --check` (test file) | 0 |
| lint | `poetry run ruff check --no-fix` (test file) | 0 |
| type check | `poetry run pyright` (test file) | 0 |
| contract tests | launcher `pytest` suite with the selection | 1 (6 lane-token rows, pass after P6-T7) |
| Pester | the seven suites above | 0 |
