# Task check: P1-T2

Timestamp: 2026-11-24T06-58
Command: see the command list below (each run from the item worktree root)
EXIT_CODE: 0
Output Summary: Black check, Ruff, and Pyright clean on the two changed Python files; the pytest selection passed (349 passed); Set L passed (89 tests, 0 failures, including PRC-LEDGER-CHAIN-HOLDS, PRC-LEDGER-SUBCHAIN-HOLDS, and PRL-REAL-LEDGER-AGREES); the in-memory revert of every 0014 block restores the merge-base bytes of both files.

Changed files:
- scripts/dev_tools/validate_orchestrator_state.py: `LOCAL_QC_GATE_KEYS`, `CHILD_CI_INTEGRATION_ONLY`, private `_child_ci_integration_only`, `_last_review_head_sha`, `_validate_completion_local_qc_gate`, public `validate_completion_gate_evidence`; the `route_requires_ci_gate` block calls the dispatch. The `_orchestrator_state_concurrent_review` import line and the `errors.extend(validate_concurrent_review_completion(state_map))` line are untouched.
- tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py: parametrized corpus test (17 cases), corpus floor test (>= 13), and two `validate_orchestrator_state_text(..., require_complete=True)` rows (accepted opt-out: no ci_gate, local_qc_gate, or child_ci error; opt-out removed: exactly the existing ci_gate object-shape error). Existing tests unchanged.
- .dev/engineering/process-reductions/0014-epic-child-ci-opt-out.md: created (reduction 0014, six revert blocks for the two files above).
- .dev/engineering/process-reductions/README.md: index row 0014 (Status Active).

Selection and rule: the mirrored test file of the changed production file and every test file that imports `scripts.dev_tools.validate_orchestrator_state` by the plan's named set (test_orchestrator_state_concurrent_review.py and every tests/scripts/dev_tools/test_validate_orchestrator_state*.py), plus Set L because the task edits a file carrying a recorded region (entry 0002) and the ledger.

Commands and exit codes:
- env -u VIRTUAL_ENV poetry -C <worktree> run black <2 files> (write mode; 1 file reformatted before the check) -> 0
- SCRATCH/issue-1233-py-static.sh: black --check -> 0 ("2 files would be left unchanged."); ruff check -> 0 ("All checks passed!"); pyright -> 0 ("0 errors, 0 warnings, 0 informations"). An earlier pyright pass reported one reportUnknownArgumentType error, fixed by passing the cast map to `_missing_object_keys`.
- env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest <20 test files> -> 0 (349 passed in 6.72 s; one launcher exit 75 queue timeout first)
- sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1 tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 -> 0 (89 passed, 0 failed; launcher exit 75 queue timeouts before the run)
- sh SCRATCH/issue-1233-ledger-verify.sh -> 0 (blocks=6 files=2 problems=0)
