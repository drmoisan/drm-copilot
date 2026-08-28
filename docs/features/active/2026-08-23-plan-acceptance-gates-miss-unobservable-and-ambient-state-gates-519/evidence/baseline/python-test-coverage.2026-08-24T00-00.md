# Python Test and Coverage Baseline — [P0-T7]

Timestamp: 2026-08-26T07-55
Task: [P0-T7]
Command: `poetry run pytest --cov-branch --cov-report=term-missing --cov`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8`
EXIT_CODE: 0

## Run header

```
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6b0c3b38073271d8
plugins: anyio-4.12.1, cov-7.0.0
```

## Result line, quoted verbatim

```
====================== 4151 passed, 5 skipped in 16.55s =======================
```

**Passed: 4151. Failed: 0. Skipped: 5.**

The failed count is 0, established two ways rather than inferred from the exit code: the result line names no failed count, and a search of the whole captured output for `FAILED` or `failed` returned 0 matches.

The five skips are all in one file and each carries its own reason, reproduced from the short test summary:

```
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

These are parametrized parity cases that declare no accessor expectation, skipped by design in the parallel-manifest bash parity suite. They are unrelated to the plan-gate modules this change touches.

## Numeric coverage

Read from the printed `term-missing` terminal table. The plan's standing rules record that this reporter prints one combined `Cover` column plus a `TOTAL` row, not separate line and branch columns, so the value below is that combined `Cover` figure with branch data collected in the same run under `--cov-branch`.

```
Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
TOTAL                                                               15014   1104   5506    560    91%
```

**Baseline TOTAL coverage: 91%.** Supporting columns from the same row: 15014 statements, 1104 missed, 5506 branches, 560 partial branches.

This is a real value read from a printed table, not a placeholder. `UNVERIFIED` is not recorded anywhere in this artifact.

The explicit `--cov-report=term-missing` is what produced that table. The project `addopts` value is `-ra --cov-report=lcov:artifacts/python/lcov.info`, which supplies exactly one non-terminal reporter; without the explicit terminal reporter this command would have printed no coverage table at all and the percentage above would have had no source. That is precisely the defect class rule G9 is being built to report, and the plan's standing rules require every coverage command in it to pass the terminal reporter explicitly for this reason. The LCOV reporter also ran, as its confirmation line shows:

```
Coverage LCOV written to file artifacts/python/lcov.info
```

## Coverage rows for the three modules this change touches

Recorded here so the Phase 8 no-regression comparison at [P8-T10] has a per-module baseline as well as a total:

```
scripts\dev_tools\plan_gate_commands.py                                77      0     28      0   100%
scripts\dev_tools\plan_gate_coverage.py                                48      0     22      0   100%
scripts\dev_tools\plan_gate_discrimination.py                         129      3     52      7    94%   82->exit, 84->exit, 86->exit, 88->exit, 208, 247, 276
```

`plan_gate_commands.py` is at 100% and gains a field in Phase 1; `plan_gate_discrimination.py` is at 94% and gains a rule-group call in Phase 2. `plan_gate_observability.py` does not yet exist and therefore has no baseline row.

The five existing plan-gate test files all passed:

```
tests\scripts\dev_tools\test_plan_gate_commands.py ..........            [ 68%]
tests\scripts\dev_tools\test_plan_gate_discrimination_context.py ....... [ 68%]
tests\scripts\dev_tools\test_plan_gate_discrimination_cov.py ........... [ 68%]
tests\scripts\dev_tools\test_plan_gate_discrimination_literals.py ...... [ 68%]
tests\scripts\dev_tools\test_plan_gate_parity.py ....                    [ 69%]
tests\scripts\dev_tools\test_validate_orchestration_artifacts_plan_gates.py . [ 86%]
```

`test_plan_gate_commands.py` shows ten passing cases, which is the pre-existing count [P1-T5] and [P1-T3] extend.

## Known pre-existing failure, searched for and not observed

The delegation brief noted that a baseline run of the full Python suite may show a pre-existing failure in `test_bundled_claude_payload_contains_all_repo_runtime_contracts`, caused by gitignored state counters (open issue #510).

SearchScope: the complete captured output of this run.
SearchPatterns: `test_bundled_claude_payload`, and separately `FAILED` and `failed`.
SearchResult: `none` for all three.

That test did not fail in this run and the suite reported zero failures. This is recorded as observed baseline state. It does not contradict the note — the failure is conditional on gitignored state that is evidently not present in this worktree — and it means the Phase 8 comparison at [P8-T4] starts from a clean zero-failure baseline. If that test fails later in this plan, the failure is attributable to issue #510 rather than to this change, and [P7-T6] invokes it directly.

## Exit-code capture method

Output redirected to a file; exit code read from `$?` with no pipe in the chain. A piped form such as `pytest | tail` would have reported `tail`'s status and a failing suite would have read as a pass.

## Output Summary

`poetry run pytest --cov-branch --cov-report=term-missing --cov` exited 0. **4151 passed, 0 failed, 5 skipped** (all five skips are declared-no-expectation parametrized cases in the parallel-manifest bash parity suite). **Baseline TOTAL coverage: 91%**, read from the printed `term-missing` table, over 15014 statements and 5506 branches. Per-module baselines for the files this change touches: `plan_gate_commands.py` 100%, `plan_gate_coverage.py` 100%, `plan_gate_discrimination.py` 94%. The pre-existing issue-#510 failure in `test_bundled_claude_payload_contains_all_repo_runtime_contracts` was searched for and did not occur.
