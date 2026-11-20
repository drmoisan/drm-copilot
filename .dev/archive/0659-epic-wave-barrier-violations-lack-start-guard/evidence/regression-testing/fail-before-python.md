# Fail-Before: Python start-guard matrix

Timestamp: 2026-09-30T10-30

Plan task: [P1-T5] [expect-fail]

Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py -rf

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary: Run against the unchanged production code (before [P1-T7] and [P1-T8]). 15 items collected; 13 failed, 2 passed. The two passing items are `test_start_guard_matrix_has_fourteen_unique_cases` and `test_start_guard_matrix_case[dependencies-merged-before-start]`. The unguarded cases 1, 2, 13, 14 fail because an unguarded violation is emitted; cases 3 to 9, 11, 12 fail on the old message text. The observed result matches the [P1-T5] acceptance.

## Summary line (verbatim)

```text
======================== 13 failed, 2 passed in 0.12s =========================
```

## FAILED node IDs

```text
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[unstarted-dependent-unmerged-dependency]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[unstarted-dependent-null-timestamp]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[started-by-status-unmerged-dependency]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[merge-status-absent-treated-as-started]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[merge-status-null-treated-as-started]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[not-started-with-timestamp-treated-as-started]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[dependency-merge-status-absent]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[two-unmerged-dependencies-in-order]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[merged-dependency-confirmed-after-start]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[status-and-timing-on-one-edge]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[integer-issue-number-reference]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[epic-678-checkpoint-shape]
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py::test_start_guard_matrix_case[kickoff-all-not-started]
```

## Acceptance evaluation

| Condition | Observed | Met |
|---|---|---|
| EXIT_CODE 1 | 1 | yes |
| Summary contains `13 failed, 2 passed` | `13 failed, 2 passed in 0.12s` | yes |
| Failed IDs include `[unstarted-dependent-unmerged-dependency]`, `[unstarted-dependent-null-timestamp]`, `[epic-678-checkpoint-shape]`, `[kickoff-all-not-started]` | all four present | yes |
| `[dependencies-merged-before-start]` not failed | not in the FAILED list | yes |
| Collection yields 15 items ([P1-T3]) | `collected 15 items` | yes |
