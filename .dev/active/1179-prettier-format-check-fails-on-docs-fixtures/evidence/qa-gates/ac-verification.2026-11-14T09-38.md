# Acceptance verification (P2-T4)

Timestamp: 2026-11-14T09-38
Command: manual mapping of spec.md `## Acceptance Criteria` to evidence files under FEATURE/evidence/
EXIT_CODE: 0
Output Summary: 7 of 9 criteria verified and checked off; 2 CI-dependent criteria pending-CI and left unchecked.

| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | Root format:check succeeds after; fails before and lists the fixtures | PASS | baseline/format-check.2026-11-14T08-55.md (exit 1, three fixtures); regression-testing/format-check.2026-11-14T09-10.md and qa-gates/final-qc-static.2026-11-14T09-27.md (exit 0) |
| 2 | Decoded JSON value identical before and after | PASS | baseline/fixture-json-hash.2026-11-14T08-55.md; regression-testing/fixture-json-equality.2026-11-14T09-09.md (three equal hashes) |
| 3 | Additional flagged files formatted | PASS | regression-testing/format-check.2026-11-14T09-10.md; baseline recorded no additional file, so none to format |
| 4 | Docs Pester suites pass | PASS | baseline/pester-docs-consumers.2026-11-14T09-08.md and qa-gates/final-pester-docs-consumers.2026-11-14T09-37.md (2360 passed, 0 failed). One scoped single-process run, not Invoke-PoshQCParallelTest, because five orchestrations share the machine; the CI shards are the full-suite gate |
| 5 | test_docs_python_native_corpus.py passes in a parallel run | PASS | baseline/pytest-docs-native-corpus.2026-11-14T09-09.md; qa-gates/final-pytest-docs-native-corpus.2026-11-14T09-27.md (4 passed, pytest -n auto) |
| 6 | Workflow has "Check root formatting" step after "Install root dependencies", all matrix legs | PASS | other/task-check.P1-T4.2026-11-14T09-10.md; step has no if: or matrix condition |
| 7 | .prettierignore, Prettier config, ci.yml, needs list unchanged; no new job or Python file | PASS | qa-gates/scope-check.2026-11-14T09-38.md; other/task-check.P1-T6.2026-11-14T09-11.md (needs-set tests pass) |
| 8 | CI-dependent: green CI run on final head exercises the step on each OS leg | pending-CI | stays unchecked until S9 |
| 9 | CI-dependent: contract tests pass in that CI run | pending-CI | stays unchecked until S9 (local task checks P1-T5 and P1-T6 passed) |
