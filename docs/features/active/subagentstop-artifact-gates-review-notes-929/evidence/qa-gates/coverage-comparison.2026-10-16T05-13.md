# Coverage Comparison (P9-T7)

Timestamp: 2026-10-16T05-13

Sources: baseline `evidence/baseline/coverage-counters-baseline.2026-10-16T01-06.md` (the greatest `coverage-counters-baseline.*.md`); final `evidence/qa-gates/coverage-counters-final.2026-10-16T05-12.md` (the greatest `coverage-counters-final.*.md`). File: `.claude/hooks/validate-task-researcher-output.ps1`.

Baseline LINE counter (verbatim):
```
<counter type="LINE" missed="2" covered="101" />
```

Final LINE counter (verbatim):
```
<counter type="LINE" missed="2" covered="100" />
```

Final changed-line elements (from P9-T6):
```
<line nr="244" mi="0" ci="1" mb="0" cb="0" />
<line nr="248" mi="0" ci="1" mb="0" cb="0" />
<line nr="265" mi="0" ci="1" mb="0" cb="0" />
```

Output Summary:
- Baseline missed 2, covered 101: 101 / 103 = 98.06%.
- Final missed 2, covered 100: 100 / 102 = 98.04%.
- Final `missed` (2) is not greater than baseline `missed` (2) (AC-23). The covered count is one lower because NB-5 deleted the covered alias assignment line; no line became uncovered.
- Final line coverage 98.04% is at least 85%.
- Each changed line (244, 248, 265) has `ci` greater than 0 (AC-18).
