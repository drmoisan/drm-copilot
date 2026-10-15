# Pre-Existing Failure Register (issue #897, epic child E1)

Timestamp: 2026-10-11T12-45
Task: [P0-T13]

## Sources consulted

- `evidence/baseline/p0-pester-coverage.md` (R-JUNIT `FAILING:` lines): `FAILING_TESTCASES: none`
- `evidence/baseline/p0-pester-targeted.md` (`FAILED:` lines): none
- `evidence/baseline/p0-pytest-parity.md` (`FAILED` nodes): none (22 passed)
- `evidence/baseline/p0-jest-manifest.md` (failing tests): none (16 passed)

## Register

PRE_EXISTING_FAILURES: none

## Rule

A later gate tolerates only a failure whose tool, identifier, and message all match a row in this register. Because the register is empty, no failure in any later gate is tolerated. For `test_bundled_claude_payload_contains_all_repo_runtime_contracts` a row would have to name the path in its message, and a message naming `subagentstop-envelope.ps1` or `settings.json` is never tolerated.
