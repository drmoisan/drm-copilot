# Evidence

Timestamp: 2026-10-09T08-14
Command: git -C WT rev-parse --abbrev-ref HEAD; rev-parse HEAD; merge-base HEAD origin/main; log --oneline origin/main..HEAD
EXIT_CODE: 0
Output Summary: Branch bug/npm-audit-handlebars; merge-base e7d3779b; origin/main..HEAD lists 4 docs(864) commits only.

## Printed output

```text
## git -C WT rev-parse --abbrev-ref HEAD
bug/npm-audit-handlebars
## git -C WT rev-parse HEAD
0574e2df280a5e5de99efb3d465a66ee41e8bee0
## git -C WT merge-base HEAD origin/main
e7d3779b398604af919678c16c877c8539a86cc0
## git -C WT log --oneline origin/main..HEAD
0574e2df docs(864): apply preflight revisions to plan (PREFLIGHT: ALL CLEAR)
22a7188f docs(864): add minimal-audit atomic plan
c7ee995c docs(864): add acceptance criteria to issue.md
9fa37092 docs(864): add promoted record and active feature folder
```
