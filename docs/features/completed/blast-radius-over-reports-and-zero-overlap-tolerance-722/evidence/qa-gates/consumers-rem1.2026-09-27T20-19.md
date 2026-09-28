# Python and TypeScript Unaffected; Consumer Check (Remediation Cycle 1, P2-T10)

Timestamp: 2026-09-27T20-19
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py ; npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/validate/parallel-kickoff-template-seam.test.ts test/lib/validate/parallel-cohort-barrier-parity.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1

(EXIT_CODE refers to the pytest run. The Jest exit code is recorded below.)

## Rationale

- P2-T9 (FEATURE/evidence/qa-gates/scope-rem1.2026-09-27T20-18.md) shows that no Python or TypeScript file changed in this cycle.
- The Python scheduling module calls conflicts directly and does not consume the PowerShell modules.
- No TypeScript source or test names Get-BlastRadiusPairDecision or Get-BlastRadiusConflictEdge.
- The consumer tests below read the bundled mirrors and the documentation files this cycle changed, so they are run to confirm the mirrored content still satisfies them.

## pytest (main plan blocks B27 and B43), exit 1

```text
collecting ... collected 94 items
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts FAILED [  2%]
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
======================== 1 failed, 93 passed in 0.47s =========================
```

Every collected node other than the KL-510 node printed PASSED (93 PASSED lines; the first B27 node, test_bundled_claude_payload_contains_required_runtime_files, passed).

KL-510: STATE-ONLY

The failing node is test_bundled_claude_payload_contains_all_repo_runtime_contracts (the second B27 node). Its assertion message, quoted verbatim, is:

```text
Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
```

The path's first two components are .claude and state. The fixed string "Bundle content differs from repo for:" occurs 0 times in the output (grep -c -F). This satisfies KL-510 case (b): the gitignored batch-budget state file written by the hooks during execution is the only reported difference, and CI has no such file.

## Jest (main plan block B43, TypeScript), exit 0

```text
Test Suites: 3 passed, 3 total
Tests:       57 passed, 57 total
```

Output Summary: PASS. pytest: 93 passed, 1 failed, and the single failure is the KL-510 node in case (b) (KL-510: STATE-ONLY; ExpectedExitCode: 1). Jest: exit 0, "Tests: 57 passed, 57 total" (contains "passed", not "failed").
