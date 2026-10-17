# Workflow README verification (P5-T1, P5-T2; AC-24, AC-35)

Timestamp: 2026-10-17T00-00
Command: sh SCRATCH/tools/run-cr.sh cr-readme
EXIT_CODE: 0
Output Summary: The three PD-17 corrections were applied (line 4 eight -> nine; the `_npm-audit-gate.yml` row inserted after the `_root-typescript-tests.yml` row; line 79 "All seven jobs in" -> "The seven jobs it extracted from") and the section 10 text was appended after the last line. README-REPLACED-LINES: 1,1; README-ANCHOR-HITS: 1; README-PREFIX-IDENTICAL: True (every other pre-existing line, including Triggers, unchanged); README-TOKENS-MISSING: 0; EXIT_CODE_COMPUTED: 0. Supplementary byte check: the last 44 README lines equal the section 10 block extracted from the plan (diff printed nothing).

## Output

```
RUN-CR: cr-readme
README-ENCODING: non-ASCII runs folded to ? on both sides
README-LINES: base=95 | expected-prefix=96 | head=140
README-REPLACED-LINES: 1,1
README-ANCHOR-HITS: 1
README-PREFIX-IDENTICAL: True
README-TOKENS-MISSING: 0
EXIT_CODE_COMPUTED: 0
```

## Supplementary: appended-section byte check (EXIT_CODE: 0)

`tail -n 44 .github/workflows/README.md | diff - SCRATCH/verify/readme-appended.txt` (the section 10 block extracted from the plan with awk) printed no difference.
