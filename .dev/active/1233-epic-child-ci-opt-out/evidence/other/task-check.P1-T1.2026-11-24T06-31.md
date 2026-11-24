# Task check: P1-T1

Timestamp: 2026-11-24T06-31
Command: sh SCRATCH/issue-1233-make-corpus.sh tests/fixtures/orchestrator_state_child_ci ; sh SCRATCH/issue-1233-jsoncheck.sh tests/fixtures/orchestrator_state_child_ci
EXIT_CODE: 0
Output Summary: files=17 problems=0. Every file parses as JSON, has LF line endings, carries a `name` equal to its file stem, and every `expected_errors` value is one of the five strings of spec `## Validator Error Strings` (string 2 with its key list in the order conclusion, head_sha, evidence_path, verified_at) or the existing `ci_gate` object-shape string of `_validate_completion_ci_gate`.

Changed files:
- tests/fixtures/orchestrator_state_child_ci/ (17 created files): opt-out-accepted, local-qc-gate-absent, local-qc-gate-non-object (also without review_mode), missing-fields, conclusion-not-success, conclusion-case-variant, review-mode-absent-head-mismatch, review-mode-sequential, head-mismatch, review-outcomes-empty, combined-missing-failure-no-review-mode (strings 2, 3, 4), combined-failure-head-mismatch (strings 3, 5), default-key-absent, default-per-child, default-case-variant, default-non-string, default-epic-mode-string.

Selection and rule: the task text names the selection "none beyond JSON parse of each file"; no test reads the corpus until P1-T2.
Format, lint, type check: not applicable (JSON fixtures only; no formatter is configured for tests/fixtures).
