# Final QA pass 2: README recheck (P6-T12; AC-24, AC-35)

Timestamp: 2026-10-17T00-21
Command: sh SCRATCH/tools/run-cr.sh cr-readme
EXIT_CODE: 0
Output Summary: Against the new merge base b8fcd7790 (whose README carries the #952 Triggers change, 96 lines), the head README (141 lines) starts with the merge-base text in which exactly the two PD-17 lines are replaced (README-REPLACED-LINES: 1,1) and the `_npm-audit-gate.yml` row is inserted (README-ANCHOR-HITS: 1); README-PREFIX-IDENTICAL: True, so the Triggers section is identical to origin/main. The appended section carries every required token (README-TOKENS-MISSING: 0). EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-readme
README-ENCODING: non-ASCII runs folded to ? on both sides
README-LINES: base=96 | expected-prefix=97 | head=141
README-REPLACED-LINES: 1,1
README-ANCHOR-HITS: 1
README-PREFIX-IDENTICAL: True
README-TOKENS-MISSING: 0
EXIT_CODE_COMPUTED: 0
```
