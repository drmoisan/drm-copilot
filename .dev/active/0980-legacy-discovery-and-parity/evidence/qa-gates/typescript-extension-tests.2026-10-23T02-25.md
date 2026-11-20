# P11-T3 TypeScript extension test gate with coverage

Timestamp: 2026-10-23T02-25
Command: node run-jest.cjs --coverage --runInBand --coverageDirectory=SCRATCH/issue-980-jest-extension-final --coverageReporters=json-summary --coverageReporters=json --coverageReporters=text-summary --json --outputFile=SCRATCH/issue-980-jest-extension-final-results.json (run in extensions/drm-copilot so the extension configuration and its per-file `coverageThreshold` map apply)
EXIT_CODE: 0
Output Summary: 312 suites passed, 4996 tests passed, 0 failed, 0 pending. Coverage over src: statements and lines 97.15% (59741/61491), branches 93.53% (9051/9677), functions 91.65% (1802/1966); every per-file threshold in the map (the `jest.discovery-coverage.json` entries spread into `jest.config.cjs`, plus the pre-existing pr-context, executable-resolver, string-ordering and orchestrator-state entries) passed, since Jest exits non-zero on any breach. Baseline was 281 suites, 4105 tests, 97.41% lines and 92.65% branches.

## Per-file thresholds for the changed production files

- 45 TypeScript production files changed since the merge base of origin/main and HEAD (25 added, 20 modified); every one is present in the coverage summary. Of the 25 added files, 23 carry their own entry in the extension threshold map and are measured by this run. The two without an entry, `src/discovery-service-types.ts` and `src/repo-automation-service-discovery-types.ts`, declare interfaces and type aliases only (no `const`, `function`, `class` or `enum` at any level), so they have no executable behavior; they report 0% by the v8 convention for type-only modules, which `.claude/rules/general-unit-test.md` permits to be omitted from measurement, and a threshold entry would fail on a file with nothing to execute. The modified `src/repo-automation-service-contract.ts` is the same class of file and reported 0% (213 lines, 0 covered) at the baseline as well.
- Every other changed production file is at or above 85% lines and 75% branches in this run (the complete per-file listing is in the SCRATCH summary and is carried into the P11-T5 delta table).
- Blanket-mock check: no extension test calls `jest.mock` on any `src/discovery-*` module, so the discovery thresholds are measured against the real modules.
