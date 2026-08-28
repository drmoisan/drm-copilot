# Phase 5 — TypeScript Per-File Coverage Thresholds

Timestamp: 2026-08-28T12-47

Task: [P5-T5]

Command: `npm run test:coverage -- --coverageReporters=text` (working directory
`extensions/drm-copilot`)

EXIT_CODE: 0

The recorded exit code is the exit code of the coverage command itself, captured directly and not
from a pipeline tail.

## Configuration change

Three entries were added to the existing `coverageThreshold` map in
`extensions/drm-copilot/jest.config.cjs`, each specifying 85 lines and 75 branches, matching every
existing entry in that map. No `global` key was added.

- `./src/lib/pr-context/pr-context-service-call.ts`
- `./src/lib/pr-context/collector-output.ts`
- `./src/lib/pr-context/summary-helpers.ts`

`extensions/drm-copilot/jest.config.cjs` is the sole Jest configuration in this repository that
carries a `coverageThreshold` map, and `test:coverage` in `extensions/drm-copilot/package.json` is
the only script that loads it. The repository-root `jest.config.cjs` declares no
`coverageThreshold` map at all, so a root-level coverage run could never fail on these per-file
entries. That is why the command is the extension-scoped one and is run from that directory.

## Output Summary

The Jest text reporter prints separate `% Stmts`, `% Branch`, `% Funcs`, and `% Lines` columns, so
every value below is read directly from the printed table.

### Per-file rows, verbatim

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
  collector-output.ts                                       |   97.73 |    82.27 |     100 |   97.73 | 112,255-258,302-305,405-406
  pr-context-service-call.ts                                |     100 |     87.5 |     100 |     100 | 56
  summary-helpers.ts                                        |   93.54 |    87.83 |   88.88 |   93.54 | 72-73,76-77,103-104,107-108,178-180,182-184,236-246
```

| File | % Lines | Threshold | % Branch | Threshold | Meets both |
| --- | --- | --- | --- | --- | --- |
| `src/lib/pr-context/pr-context-service-call.ts` | 100 | 85 | 87.5 | 75 | yes |
| `src/lib/pr-context/collector-output.ts` | 97.73 | 85 | 82.27 | 75 | yes |
| `src/lib/pr-context/summary-helpers.ts` | 93.54 | 85 | 87.83 | 75 | yes |

Overall run totals: statements 96.71, branch 90.15, functions 89.88, lines 96.71.

### The run reported no coverage threshold failure

A search of the run output for the string `threshold`, case-insensitively, returned nothing, and
the run exited 0 with `Test Suites: 201 passed, 201 total` and `Tests: 2722 passed, 2722 total`.

## Proof that the gate is live rather than inert

An exit code of 0 alone does not distinguish a threshold that passed from a threshold Jest never
loaded. A negative probe was therefore run and is recorded here.

The `branches` value of the `./src/lib/pr-context/pr-context-service-call.ts` entry was
temporarily raised from 75 to 100 and the identical command re-run. It exited **1** and printed:

```
Jest: Coverage for branches (87.5%) does not meet "./src/lib/pr-context/pr-context-service-call.ts" threshold (100%)
```

The message names the added entry by its exact key, which proves Jest loaded the new entries and
evaluates them. The threshold was then restored to 75 and the command re-run, producing the exit
code 0 and the table recorded above. The probe left no residue: the committed configuration
carries 75.

No placeholder value appears in this artifact.
