# Final corpus regression (plan [P12-T13], rule 16, issue #905)

Timestamp: 2026-10-12T00-13
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/corpus-task-researcher.ps1 -Mode After -Sha 2ef8d361e978ca8b7733a545d76a87e8418005ce; the same for corpus-prd-feature.ps1, corpus-discovery.ps1, and corpus-pr-author.ps1
EXIT_CODE: 0
Output Summary: each of the four scripts exited 0 on the final tree (loop pass 2). `origin/main` re-fetched: tip 2ef8d361e978ca8b7733a545d76a87e8418005ce, equal to CORPUS_SHA. Compared with the `## After` section of each W-CORPUS-EVIDENCE file by `<SCRATCHPAD>/e905-corpuscmp.ps1`: task-researcher BLOCK set equal (27) and FALSE-POSITIVES: 0; discovery BLOCK set equal (0) and FALSE-POSITIVES: 0; pr-author BLOCK DECISION set equal (124, all CONTROL_REFS_ONLY) and FALSE-POSITIVES: 0; prd-feature TRIGGER (280), EVIDENCE-FAIL (56), and EVIDENCE-CLASS (56) sets equal and CHECKER-DEFECTS: 0. CORPUS-DIFFERENCES is 0 for all four, so no CORPUS RESULT CHANGED halt applies.

```text
COMPARE: task-researcher | ^BLOCK:  | after=27 | final=27 | EQUAL
COMPARE: task-researcher | ^FALSE-POSITIVES:  | after=1 | final=1 | EQUAL
FINAL-VALUE: task-researcher | FALSE-POSITIVES: 0
CORPUS-DIFFERENCES: task-researcher | 0
```

```text
COMPARE: prd-feature | ^TRIGGER:  | after=280 | final=280 | EQUAL
COMPARE: prd-feature | ^EVIDENCE-FAIL:  | after=56 | final=56 | EQUAL
COMPARE: prd-feature | ^EVIDENCE-CLASS:  | after=56 | final=56 | EQUAL
COMPARE: prd-feature | ^CHECKER-DEFECTS:  | after=1 | final=1 | EQUAL
FINAL-VALUE: prd-feature | CHECKER-DEFECTS: 0
CORPUS-DIFFERENCES: prd-feature | 0
```

```text
COMPARE: discovery | ^BLOCK:  | after=0 | final=0 | EQUAL
COMPARE: discovery | ^FALSE-POSITIVES:  | after=1 | final=1 | EQUAL
FINAL-VALUE: discovery | FALSE-POSITIVES: 0
CORPUS-DIFFERENCES: discovery | 0
```

```text
COMPARE: pr-author | ^DECISION: [A-Z_]+ \| #\d+ \| BLOCK \|  | after=124 | final=124 | EQUAL
COMPARE: pr-author | ^FALSE-POSITIVES:  | after=1 | final=1 | EQUAL
FINAL-VALUE: pr-author | FALSE-POSITIVES: 0
CORPUS-DIFFERENCES: pr-author | 0
```
