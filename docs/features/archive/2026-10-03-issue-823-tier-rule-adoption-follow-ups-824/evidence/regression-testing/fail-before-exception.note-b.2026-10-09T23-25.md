# P2-T5 Fail-Before Exception Dossier: Review Note B (PD7)

Timestamp: 2026-10-09T23-25
Command: poetry run python -c "t = 'Throttle new work at 80% of the quota window.'; print('OLD_SCAN_FLAGS', [x for x in ('80%', '90%') if x in t])"
EXIT_CODE: 0
Output Summary:
- EXIT 0; printed `OLD_SCAN_FLAGS ['80%']`.
- Supporting check (micro-action): `grep -c -F "def test_retired_threshold_scan_reads_coverage_context_only" tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py` printed 1 (the test added by P1-T2 is present).
- Result: alternative proof recorded; fail-before requirement satisfied by this dossier.

WhyFailingRunImpossible: Note B changes only the assertion inside the test module `tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py`; no production file is involved. No production state can therefore make the narrowed test fail first, so a fail-before run cannot be produced.

## Alternative Proof

- The command applies the BASE_SHA whole-text expression (a substring check for `80%` and `90%` over the entire text) to the sentence "Throttle new work at 80% of the quota window." and prints `OLD_SCAN_FLAGS ['80%']`. The old expression flags a figure that is unrelated to coverage, which is the defect note B addresses.
- `test_retired_threshold_scan_reads_coverage_context_only` (added by P1-T2) asserts that the same sentence is not flagged after narrowing and that a coverage sentence still is.
