# G1-G9 Corpus A/B for the G6 Whitespace Class (Remediation Cycle 3)

Timestamp: 2026-10-16T06-49
Task: [P2-T6]
Method: the Write tool wrote `SCRATCH/corpus/g6_whitespace_ab.py` with the exact content of Appendix D of the cycle-3 plan, with `SCRATCH` resolved for the tool call only. The command ran at the repository root. It outlived the tool timeout and was run in the background; the executor waited for completion and read the exit code from the run log.
Command: poetry run python SCRATCH/corpus/g6_whitespace_ab.py SCRATCH/corpus/g6-whitespace-ab.json
EXIT_CODE: 0
Output Summary:

```text
PROBE_PYTHON_DIFFERS: True
PROBE_TYPESCRIPT_DIFFERS: True
PLANS_SCANNED: 509
PLANS_DIFFERING_PYTHON: 0
PLANS_DIFFERING_TYPESCRIPT: 0
FINDINGS_AFTER: 1175
FINDINGS_PYTHON_BEFORE: 1175
FINDINGS_TYPESCRIPT_BEFORE: 1175
```

- Both built-in probes differ from production under their substitution, so each substitution took effect (NEL-only tracked line for the pre-change Python normalization; byte-order-mark-only tracked line for the emulated pre-change TypeScript normalization).
- 509 plan and remediation-plan files scanned (at least 100). No `DIFFERS_PYTHON:` or `DIFFERS_TYPESCRIPT:` line was printed.
- The three findings totals are equal (1175), matching the cycle-2 A/B total. G10 findings were dropped.
- Per-plan findings were written to `SCRATCH/corpus/g6-whitespace-ab.json` (not committed).
