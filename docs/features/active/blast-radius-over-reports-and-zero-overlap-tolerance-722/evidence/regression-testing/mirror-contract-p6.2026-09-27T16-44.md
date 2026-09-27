# Mirror-consumer Contracts and Rule-file Tokens, Phase 6 (P6-T9)

Timestamp: 2026-09-27T16-44
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files
EXIT_CODE: 0
Output Summary: PASS. The first B27 node exited 0 with one PASSED line. The B43 Python run (eight files) exited 0 with 92 passed and no FAILED node (P0-T18 baseline failure set is empty). The B43 TypeScript run (three files) exited 0 with "Test Suites: 3 passed, 3 total" and "Tests: 57 passed, 57 total" and no line beginning "FAIL " (P0-T31 baseline failure set is empty). For each of the nine Part A tokens of block B26 the worktree count of .claude/rules/parallel-orchestration.md is greater than its BASE_SHA count. This artifact's EXIT_CODE refers to the first B27 node run; the exit code of every other command is recorded below.

## Run 1: first B27 node

Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files
EXIT_CODE: 0

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files PASSED [100%]
============================== 1 passed in 0.06s ==============================
```

## Run 2: B43 Python files

Command: poetry run pytest -v tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
EXIT_CODE: 0

```text
============================= 92 passed in 0.38s ==============================
```

No line contains FAILED or ERROR. The planner-surface contract literals ("conflicts(a, b, config)",
"compute_cohorts(item_keys, conflict_edges)", the absence of "conflicts(a, b)" and of "pinned", the
derive_blast_radius signature line, "It does not take file paths", and the three
recomputation-parity sentences) are asserted by test_parallel_planner_surface_contracts_landed.py,
which passed in this run.

## Run 3: B43 TypeScript files

Command: npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts test/lib/validate/parallel-kickoff-template-seam.test.ts test/lib/validate/parallel-cohort-barrier-parity.test.ts
EXIT_CODE: 0

```text
Test Suites: 3 passed, 3 total
Tests:       57 passed, 57 total
```

No line begins "FAIL ".

## Runs 4-21: B26 Part A token counts against .claude/rules/parallel-orchestration.md

Worktree command form: git grep -c -F -e "<token>" -- .claude/rules/parallel-orchestration.md
BASE_SHA command form: git grep -c -F -e "<token>" beae3f021674e64fa6662097fe48a332d8da62b8 -- .claude/rules/parallel-orchestration.md
(A BASE_SHA run that exits 1 with no output is a count of zero.)

| Token | Worktree count (exit) | BASE_SHA count (exit) | Worktree > BASE_SHA |
| --- | --- | --- | --- |
| Integration-cost scheduling | 2 (0) | 0 (1, no output) | yes |
| tolerance_percent | 6 (0) | 0 (1, no output) | yes |
| append_only_paths | 3 (0) | 0 (1, no output) | yes |
| tolerated_overlaps | 2 (0) | 0 (1, no output) | yes |
| Get-BlastRadiusConflictEdge | 1 (0) | 0 (1, no output) | yes |
| operator-directed | 1 (0) | 0 (1, no output) | yes |
| hand-narrow | 1 (0) | 0 (1, no output) | yes |
| tolerated-not-validated | 2 (0) | 1 (0) | yes |
| re-passes | 1 (0) | 0 (1, no output) | yes |

## Separate runs

- Second B27 node (KL-510): FEATURE/evidence/regression-testing/bundle-payload-p6.2026-09-27T16-44.md (KL-510: STATE-ONLY).
- A5 over the four Phase 6 mirror pairs: FEATURE/evidence/regression-testing/mirror-hashes-p6.2026-09-27T16-44.md (all four pairs equal).

FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
SCRATCH denotes the executor session scratchpad directory (outside the repository).
