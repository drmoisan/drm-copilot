# Baseline Gate — `npm run lint`, `extensions/drm-copilot` (#414, [P0-T18])

Timestamp: 2026-07-25T17-13

Command: `npm run lint` (working directory: `extensions/drm-copilot`, BEFORE any manifest edit)
EXIT_CODE: 0

```text
> drm-copilot@1.0.19 lint
> eslint --no-error-on-unmatched-pattern src test

(no diagnostics emitted)
```

## Diagnostic Counts

| Severity | Count |
|---|---|
| Errors | 0 |
| Warnings | 0 |

Output Summary: PASS at baseline. `npm run lint` exits 0 in `extensions/drm-copilot` before any #414 edit, with 0 errors and 0 warnings across the `src` and `test` trees. ESLint runs here against the pre-edit dependency tree installed by [P0-T12], which still contains the flagged `brace-expansion` nodes and the nested `minimatch@9.0.9` under `glob`. This establishes the green pre-edit state of the gate for comparison against [P5-T2].
