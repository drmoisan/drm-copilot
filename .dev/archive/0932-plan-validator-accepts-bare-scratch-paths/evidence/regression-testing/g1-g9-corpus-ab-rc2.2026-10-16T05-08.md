# G1-G9 Corpus A/B for the G6 Splitter (Remediation Cycle 2), rerun after the [P2-T6] remediation

Timestamp: 2026-10-16T05-08
Task: [P2-T4]
Method: the Appendix D helper at `SCRATCH/corpus/g1_g9_splitter_ab.py` (unchanged since the first pass) was run again at the repository root. The tool layer started it as a background command, because the first pass took about 22 minutes, which is longer than the 600000 ms tool timeout. It ran to completion, and the exit code and output below are from that completed run.
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

- No `DIFFERS:` line was printed. `PLANS_SCANNED` (508) is at least 100, and `FINDINGS_BEFORE` equals `FINDINGS_AFTER` (1175).
- This is the same result as the first pass (`g1-g9-corpus-ab-rc2.2026-10-16T04-46.md`). Black left both production files unchanged in [P2-T6], so the result was not expected to change.
