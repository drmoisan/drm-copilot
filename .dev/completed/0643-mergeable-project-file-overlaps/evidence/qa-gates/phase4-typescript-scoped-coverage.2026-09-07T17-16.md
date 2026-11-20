# Phase 4 QA Gate — TypeScript scoped coverage (issue #643)

Timestamp: 2026-09-07T17-16

Command: `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npm run test:coverage -- --coverageReporters=text; $code = $LASTEXITCODE; Pop-Location; exit $code'` (run from the worktree root)

EXIT_CODE: 0

Output Summary:

Jest exits non-zero when any `coverageThreshold` entry is not met, so this exit
code carries the [P4-T3] gate for the new production file. The exit is 0 and no
`Jest: "..." coverage threshold ... not met` line appears, so every entry in the
map is satisfied, including the entry added for
`./src/lib/push-down/claude-blast-radius-derive-manifests.ts`
(`lines: 85`, `branches: 75`).

Verbatim rows for the two files the task names, with the header row for column
alignment:

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
All files                                                   |   96.73 |    90.19 |   89.86 |   96.73 |
  claude-blast-radius-derive-core.ts                        |     100 |     97.5 |   88.88 |     100 | 306
  claude-blast-radius-derive-manifests.ts                   |     100 |    95.65 |     100 |     100 | 122
```

Numeric coverage values:

- `claude-blast-radius-derive-manifests.ts`: `% Lines` 100 (at or above 85);
  `% Branch` 95.65 (at or above 75).
- `claude-blast-radius-derive-core.ts`: `% Lines` 100 (at or above 85);
  `% Branch` 97.5 (at or above 75).
- Whole-project `All files` row: `% Lines` 96.73, `% Branch` 90.19, both above
  the uniform thresholds in `.claude/rules/quality-tiers.md`.

Test totals for the same run:

```text
Test Suites: 205 passed, 205 total
Tests:       2749 passed, 2749 total
```
