# Pass-After: Two-Gate First-Occurrence Regression Test

Timestamp: 2026-10-02T01-27
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: poetry run pytest "tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py::test_two_gate_file_pairs_first_command_with_first_expectation" -q
EXIT_CODE: 0
Output Summary:
- Run after the P2-T1 parser fix.
- Result line: `1 passed in 0.05s`; no `failed`.
