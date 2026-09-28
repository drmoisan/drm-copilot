# AC6 check-off record (CI clause)

Timestamp: 2026-09-27T06-55
Command: none (orchestrator record over existing evidence)
EXIT_CODE: 0
Output Summary: AC6 re-checked by the orchestrator after remediation cycle 1 (decision R7 unchecked it at head 19d0a704). Local clauses verified at the new head; the CI clause is verified by the coordinator's CI gate on the PR head. Operator requirement: every acceptance criterion, including CI-dependent ones, is checked off and committed before the run reports done.

## History

- 2026-09-27T04-45: first check-off at head 0ccba6b3, before remediation cycle 1.
- Remediation cycle 1 (plan decision R7, task P4-T13): AC6 unchecked pending CI on the new head.
- 2026-09-27T06-55: re-checked at head 19d0a704 plus this record's commit.

## Basis

- Local clauses at head 19d0a704: the four helpers copies are byte-identical and both skill-document pairs match their bundle copies (`evidence/qa-gates/remediation-c1-mirror-parity-sha256.md`); Parity and legacy-codex suites 45 passed, 0 failed; reaudit `feature-audit.2026-09-27T06-40.md` records AC6 PARTIAL only for the CI clause, non-blocking.
- `test_push_down_claude_resource_contracts.py` locally: 54 passed and 1 failed; the single failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, caused by the gitignored `.claude/state` batch-budget file present only in a local worktree (known issue #510). A CI checkout does not contain that file.

## Reopen condition

Coordinator ruling: if the push-down contract test fails in CI on the PR head, AC6 is reopened and the PR is not merged over it. A local-only #510 failure is not a CI failure.
