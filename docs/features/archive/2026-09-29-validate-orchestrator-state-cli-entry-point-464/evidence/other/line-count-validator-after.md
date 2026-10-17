# Validator Line Count After (Issue #464)

Timestamp: 2026-09-30T08-53
Command: poetry run python -c "print(len(open('scripts/dev_tools/validate_orchestrator_state.py', encoding='utf-8').read().splitlines()))"
EXIT_CODE: 0
Output Summary:
- After the extraction and the guard: 434 lines (below 500).
- Baseline (`evidence/baseline/line-count-validator-before.md`): 492 lines. The validator is 58 lines shorter.
- Headroom for issue #523: 500 - 434 = 66 lines (it was 8 before).
- Equivalence note: the planned `wc -l` is not on the Bash allowlist; the single-line Python `splitlines` count was used instead.
