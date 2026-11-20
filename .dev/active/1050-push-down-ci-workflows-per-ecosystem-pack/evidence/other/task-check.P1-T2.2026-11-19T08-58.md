# Task Check P1-T2

Timestamp: 2026-11-19T08-58
Command: sh SCRATCH/issue-1050-p1t2.sh (cp into place; node assert.deepStrictEqual of the data file against the spec object; key-order check; CR count; grep -c '^name: CI$' on the template)
EXIT_CODE: 0
Output Summary: Six files created. Data file parses and deep-equals the spec `## Data File Schema` object, keys are sorted, no CR byte (LF). Template carries `name: CI` at column 0 (count 1).

Changed files:
- `extensions/drm-copilot/resources/ci-workflows/caller/drm-copilot-ci.template.yml`
- `extensions/drm-copilot/resources/ci-workflows/caller/jobs/{python,powershell,typescript,dotnet}.yml`
- `extensions/drm-copilot/resources/ci-workflows/ci-required-checks.json`

Selection rule: contract tests that read the changed configuration paths. A search of `tests/` and `extensions/drm-copilot/test/` for enumerations of the `resources/` tree found none that reads `resources/ci-workflows/`; the contract test that reads these files (`push-down-ci-contract.test.ts`) is created in P2-T4. Selection is empty for this task.
