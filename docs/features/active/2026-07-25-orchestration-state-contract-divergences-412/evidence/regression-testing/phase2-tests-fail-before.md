# Phase 2 — Fail-Before Evidence (Divergence 2, Python)

Timestamp: 2026-07-25T17-45

Command: `poetry run pytest tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py --no-cov -q --tb=no`

EXIT_CODE: 1

Output Summary:

`8 failed, 23 passed in 0.10s`. Executed from the repo root before the [P2-T4]
production change. Every failure is a new case added by [P2-T1] / [P2-T2]; no
pre-existing case failed.

Failing new tests (all 8):

- `test_compute_complexity_floor.py::test_each_non_floor_signal_yields_c1[single_file_localized_edit]`
- `test_compute_complexity_floor.py::test_each_non_floor_signal_yields_c1[mechanical_rename_or_move]`
- `test_compute_complexity_floor.py::test_each_non_floor_signal_yields_c1[docs_or_comment_only]`
- `test_compute_complexity_floor.py::test_unknown_signal_name_yields_c1`
- `test_compute_complexity_floor.py::test_non_floor_only_list_never_returns_c4`
- `test_compute_complexity_floor.py::test_floor_signal_names_match_config_floor_true_entries`
- `test_validate_orchestrator_state_complexity.py::test_non_floor_only_assessment_with_floor_c1_accepted`
- `test_validate_orchestrator_state_complexity.py::test_non_floor_only_assessment_with_floor_c3_rejected`

Representative pre-fix diagnostic for the static parity assertion (captured with
`--tb=line` on that single node):

```
E   AttributeError: module 'scripts.dev_tools.compute_complexity_floor' has no attribute 'FLOOR_SIGNAL_NAMES'
```

The remaining seven failures are assertion failures produced by the pre-fix
formula returning `C3` for every non-empty signal list.

One new case, `test_compute_complexity_floor.py::test_mixed_list_with_one_floor_signal_yields_c3`,
passes pre-fix. That is expected and not a defect in the case: the pre-fix
formula returns `C3` for any non-empty list, which coincides with the correct
post-fix answer for a list that does contain a floor signal. It is retained
because it pins the positive half of the truth table required by the spec.

### Deviation recorded

The [P2-T1] parity assertion was first written with a module-level
`from scripts.dev_tools.compute_complexity_floor import FLOOR_SIGNAL_NAMES`.
Pre-fix that raised `ImportError` at collection time, which aborted the entire
pytest session (`Exit code 2`, `Interrupted: 1 error during collection`) and
prevented every other new case — including the whole second test module — from
reporting. To satisfy this task's acceptance clause ("artifact shows only the
new cases failing"), the constant is now read as a module attribute
(`floor_module.FLOOR_SIGNAL_NAMES`) inside the parity test only. The assertion
is behaviorally identical post-fix; the change only localizes the pre-fix
failure to the one test that owns it.
