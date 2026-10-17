# G1-G9 Corpus A/B for the G6 Splitter (Remediation Cycle 2)

Timestamp: 2026-10-16T04-46
Task: [P2-T4]
Method: the Write tool wrote `SCRATCH/corpus/g1_g9_splitter_ab.py` with the exact content of Appendix D of the plan. The command below was run at the repository root with a 600000 ms tool timeout. The run took about 22 minutes, so it passed the tool timeout and the tool layer moved it to the background. It ran to completion there, and the exit code and output below are from that completed run.
Command: poetry run python SCRATCH/corpus/g1_g9_splitter_ab.py SCRATCH/corpus/g1-g9-splitter-ab.json
EXIT_CODE: 0
Output Summary:

```text
PROBE_DIFFERS: True
PLANS_SCANNED: 508
PLANS_DIFFERING: 0
FINDINGS_BEFORE: 1175
FINDINGS_AFTER: 1175
```

- No `DIFFERS:` line was printed.
- `PLANS_SCANNED` (508) is at least 100, and `FINDINGS_BEFORE` equals `FINDINGS_AFTER` (1175).
- The probe (a stub tracked file containing a form feed) differs between the production splitter and `str.splitlines`, which shows that the substitution took effect.
- Per-plan findings are written to `SCRATCH/corpus/g1-g9-splitter-ab.json`, which is not committed.
