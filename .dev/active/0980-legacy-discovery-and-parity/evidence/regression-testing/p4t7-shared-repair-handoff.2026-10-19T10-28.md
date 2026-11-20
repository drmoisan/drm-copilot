# Shared repair handoff

Timestamp: 2026-10-19T10-28
Command: poetry run python SCRATCH/issue-980-p4t7-shared-repair-freeze.py
EXIT_CODE: 0
Output Summary: FROZEN_READY for bounded SR1-SR4 confirmation and checked WIP commit.

Scope: dependency_inputs.py, dependency_values.py, test_dependency_inputs.py and test_dependency_input_limits.py. No integration edits.

Baseline: original 152 cases, 221/221 statements, 108/108 branches; all original cases and behavioral ASTs retained. Plan: approved cohesive value split, forward-only grammar, allocation-free UTF-8 reservations, explicit typed contracts and boundary tests. Diffs are confined to these four paths; pure helpers are re-exported without signature/identity divergence.

QA: clean focused4 Black, Ruff, scoped Pyright and 191 tests; zero new lint/type/test failures. Coverage 275/275 statements and 142/142 branches across two production modules; every measured class/function is 100%. Earlier formatting/import/private-test-access diagnostics are retained. The freeze audit caught501 lines after import formatting; removing one blank line inside a docstring produced500 lines and was followed by focused4. Original191-case proof and normalized AST equivalence are retained; no unit assertion failed.

The frozen manifest contains exact sources, signatures, raw coverage and stream hashes, 191 ordered nodes, all executed script bytes, preserved predecessor/integration bindings and an explicit staging list. Full-repository/final task gates, parser composition, independent confirmation and task acceptance are pending. The parent owns commits, subsequent integration release and plan/AC changes.
