# Python-floor erratum verification ([P1-T4])

Timestamp: 2026-11-07T22-45
Command: grep -n -F "3.10" <FEATURE>/spec.md; grep -n -F "3.11" <FEATURE>/spec.md; grep -c -F "3.10" <FEATURE>/plan.2026-10-30T18-59.md
EXIT_CODE: 0
Output Summary: spec `3.10` matches exactly one line, inside the new erratum entry; spec `3.11` matches four lines (the `### Onboarding documentation` bullet, the `## Cross-Child Contract Dependencies` row, the erratum entry and the SAC-12 item); the 2026-10-30 plan holds 0 `3.10` tokens and its [P2-T3] line reads `Python 3.11 or later`.

## grep -n -F "3.10" spec.md (1 line)

```text
370:  `.claude/lib/docs/python/run_docs_python_native.py`, which supersedes 3.10. Found at feature
```

Line 370 is the third line of the `- Python floor (erratum, 2026-11-07)` entry under `## Corrections to the Research`.

## grep -n -F "3.11" spec.md (4 lines)

```text
149:  - Optional python pack: installing the python pack, with Python 3.11 or later available, enables
324:| `-AnalysisMethod auto|native|scanner`; Python 3.11 floor; fallback rules; OQ-D statement | 1031 | end-to-end suite, onboarding |
368:- Python floor (erratum, 2026-11-07): the native-analyzer floor is Python 3.11, per the 1031 owner
397:- [ ] `consumer-onboarding.md` states that the optional python pack, with Python 3.11 or later, enables the native Python analyzer (D3), ...
```

(The SAC-12 line is truncated here after "enables the native Python analyzer (D3),"; the full line is unchanged apart from the floor token.)

## grep -c -F "3.10" plan.2026-10-30T18-59.md

```text
0
```

`grep -c -F "Python 3.11 or later"` on the same plan returns 1 (the [P2-T3] task line).
