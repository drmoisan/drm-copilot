# Coverage Comparison

Timestamp: 2026-10-12T17-50

Command: compare `evidence/baseline/pytest-coverage-baseline.2026-10-11T10-38.md` with `evidence/qa-gates/final-pytest-coverage.2026-10-11T10-38.md`; `git diff --name-only origin/main...HEAD -- scripts src`; `git status --porcelain -- scripts src`

EXIT_CODE: 0

Output Summary:
- Baseline coverage (P0-T16) TOTAL: Stmts 79, Miss 48, Branch 16, BrPart 0, Cover 33%; derived line percentage 39.24%.
- Post-change coverage (P4-T4) TOTAL: Stmts 79, Miss 48, Branch 16, BrPart 0, Cover 33%; derived line percentage 39.24%.
- The four TOTAL values Stmts, Miss, Branch, and BrPart are identical; the derived line percentage is unchanged.
- `git diff --name-only origin/main...HEAD -- scripts src`: exit 0, no output.
- `git status --porcelain -- scripts src`: exit 0, no output.
- No file under `scripts/` or `src/` changed.
- Changed-line coverage: not applicable. The changed lines are Markdown prose with no executable lines, and the new module is under `tests/`, which `[tool.coverage.run]` `omit` excludes.
