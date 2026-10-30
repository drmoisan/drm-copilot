# P5-T1 repaired final handoff

Timestamp: 2026-10-20T05-24
Command: `poetry run python SCRATCH/issue-980-p5t1-repaired-handoff.py <complete-sequence>`
EXIT_CODE: 0
Output Summary: The released repaired final sequence passed; independent acceptance remains pending.

The nine-path candidate passed Black, Ruff, whole-repository Pyright and static checks. The unchanged native harness then passed all 14 assertions before 17 direct scope, 58 graph and 138 caller cases, coverage reconciliation and four contracts. Source and dependency hashes stayed fixed.

| Stage | Gate | Exit | Seconds |
| --- | --- | --- | --- |
| 1 | format | 0 | 1.009 |
| 2 | lint | 0 | 1.008 |
| 3 | types | 0 | 14.036 |
| 4 | architecture | 0 | 1.010 |
| 5 | native-precheck | 0 | 36.087 |
| 6 | scope-reverse | 0 | 3.015 |
| 6 | graph-reverse | 0 | 106.245 |
| 6 | callers-reverse | 0 | 924.051 |
| 6 | coverage-combine | 0 | 1.010 |
| 6 | coverage-json | 0 | 1.010 |
| 6 | coverage-check | 0 | 1.011 |
| 7 | contracts | 0 | 1.011 |

Current raw coverage is reported below. Exact unchanged scope bodies retain separately linked P2-T6 proof; those retained counters are never inserted into this current raw JSON.

| Module | Current statements | Current branches |
| --- | --- | --- |
| `coverage_population.py` | 113/115 | 46/50 |
| `coverage_report.py` | 111/111 | 26/26 |
| `coverage_scope_rules.py` | 130/142 | 67/78 |
| `validation.py` | 150/150 | 52/52 |

The changed inventory-accounting callable and changed executable lines have current proof with no loss of mapped previously covered statements or branches. The retained 114-case helper proof remains unchanged and was not replayed. Known population gaps and raw versus named callable denominators remain explicit in the paired ranges record.

Actual local capture/loading now verifies generated JSON and Markdown report outputs without changing semantic coverage results. All previously unexecuted native cases also passed, including stale/forged reports, uninventoried input, malformed scope and unchanged fixture/Git bytes.

Original failed native proof and historical 187-case results remain immutable. The new lossless archive preserves original stdout/stderr/progress, coverage and exact harness bytes. Readable views contain portable paths, LF line endings and one terminal newline.

No source/test, checkpoint, plan, acceptance-criteria or Git mutation was performed here. This result does not claim publication, installed-host execution, non-Windows execution or feature completion.
