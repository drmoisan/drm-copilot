# TypeScript PR-Context Evidence Suite (After Comment Edits)

Timestamp: 2026-10-02T01-29
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: npm --prefix extensions/drm-copilot run test -- test/lib/pr-context/verification-evidence.test.ts
EXIT_CODE: 0
Output Summary:
- `Test Suites: 1 passed, 1 total`
- `Tests:       28 passed, 28 total` (equals N_ts_ve = 28 from P0-T27); no `failed`.
- Named cases confirmed passed through a companion run `npm --prefix extensions/drm-copilot run test -- test/lib/pr-context/verification-evidence.test.ts --json --outputFile=<session scratchpad>/ts-ve.json` (exit 0), because the repository Jest configuration prints no per-test lines even with `--verbose`:
  - `parseVerificationEvidenceMarkdown keeps the first occurrence for a duplicated required key` -> `passed`
  - `parseVerificationEvidenceMarkdown parses shape-06 to its specified record` -> `passed`
- Substitution (deviation D-TOOLS): `node run-jest.cjs <path>` from `extensions/drm-copilot` run through the `test` script with `npm --prefix`.
