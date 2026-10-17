# Spec Decision Records (P6-T4)

Timestamp: 2026-10-16T04-07

Command: sh SCRATCH/929/P6-T4-1.sh
Script: `Select-String -Path docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md -SimpleMatch -Pattern 'Candidate rule','NB-7 resolution','NB-8 resolution','NB-10 resolution','NB-11: no production change','NB-2: no R3 production rule change' | ForEach-Object { '{0} | {1}' -f $_.LineNumber, $_.Pattern }`
EXIT_CODE: 0
Output:
```
69 | NB-2: no R3 production rule change
71 | Candidate rule
79 | NB-11: no production change
140 | NB-7 resolution
141 | NB-8 resolution
142 | NB-10 resolution
```

Output Summary: Each of the six patterns is reported once, at lines 69, 71, 79, 140, 141, and 142 (matching the authoring-time lines). The spec records the NB-2 decision with its candidate-rule table and the NB-7, NB-8, NB-10, and NB-11 resolutions (AC-04 spec record, AC-15 spec record).
