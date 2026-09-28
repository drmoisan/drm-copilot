# Acceptance-criteria Check-off, Phase 17 (P17-T6)

Timestamp: 2026-09-27T18-13
Command: edit of FEATURE/spec.md (the AC-31 and AC-36 checkboxes changed from unchecked to a lowercase x; criterion text unchanged)
EXIT_CODE: 0
Output Summary: Two criteria checked off in FEATURE/spec.md: AC-31 (spec line 675) and AC-36 (spec line 696), the 31st and 36th checkbox lines of the Acceptance Criteria section, confirmed by counting checkbox lines in document order. This artifact also records a correction of evidence timestamps made in Phase 17 (section below).

## Checked-off criteria

| ID | Spec criterion (abbreviated) | Evidence cited by the traceability row | Evidence file |
| --- | --- | --- | --- |
| AC-31 | mirrors, runsettings, pack manifest | evidence/qa-gates/mirrors-final | FEATURE/evidence/qa-gates/mirrors-final.2026-09-27T17-58.md; FEATURE/evidence/qa-gates/registration-p10.2026-09-27T17-15.md; FEATURE/evidence/qa-gates/mirrors-p5.2026-09-27T15-48.md; FEATURE/evidence/regression-testing/mirror-contract-p13.2026-09-27T17-52.md; FEATURE/evidence/regression-testing/bundle-payload-p13.2026-09-27T17-52.md; FEATURE/evidence/qa-gates/final-ts-jest-coverage.2026-09-27T18-12.md |
| AC-36 | TypeScript toolchain and coverage | evidence/qa-gates/final-ts-jest-coverage | FEATURE/evidence/qa-gates/final-ts-jest-coverage.2026-09-27T18-12.md; FEATURE/evidence/qa-gates/final-ts-prettier.2026-09-27T18-11.md; FEATURE/evidence/qa-gates/final-ts-eslint.2026-09-27T18-11.md; FEATURE/evidence/qa-gates/final-ts-typecheck.2026-09-27T18-11.md; FEATURE/evidence/qa-gates/ts-coverage-delta.2026-09-27T18-13.md |

## Verification against the criterion text

- AC-31: every new or changed PowerShell module (BlastRadius, BlastRadiusScheduling, BlastRadiusWriteIntent, BlastRadiusValidation) has a bundled mirror with an equal SHA256 hash (mirrors-final); the new modules are registered in the self-hosted runsettings, whose bundled copy is hash-equal (mirrors-p5, registration-p10, mirrors-final), and are listed in the Claude pack manifest core.json (registration-p10). The pack-manifest completeness test passed (16 tests, P17-T4). The push-down resource-contract node test_bundled_claude_payload_contains_required_runtime_files passed at P13-T2; the second node's local result is the KL-510 state-only failure (case (b)), which the plan's Terms accept as the known local failure of issue #510 that does not occur in CI.
- AC-36: Prettier (status unchanged by the format run; check "All matched files use Prettier code style!"), ESLint (exit 0), tsc (exit 0), and Jest (230 suites, 3154 tests passed, exit 0) ran in a single pass; the derivation core is at 100 % Lines and 97.5 % Branch, equal to baseline, with changed-line coverage 100.00.

## Timestamp correction (Phases 14 to 16)

The Timestamp fields and file-name timestamps of 22 artifacts written by this executor for P14-T3
through P16-T6 had been estimated rather than read from the clock, and ran up to 20 minutes ahead of
real time. Each was corrected to the minute of its file modification time (the time the artifact was
written) by renaming the file, rewriting its Timestamp line, and updating the file-name references in
the check-off artifacts and in final-powershell-format. No command result, count, or verdict was
changed. The renames are carried by this phase's commit. main-sync (17-55) and 452-inventory-final
(17-56) already carried real-clock values and were not changed.

| Artifact | Recorded | Corrected |
| --- | --- | --- |
| qa-gates/452-gate-final | 17-58 | 17-57 |
| qa-gates/detection-unchanged-final | 17-59 | 17-57 |
| qa-gates/detection-verdicts-final | 18-01 | 17-58 |
| qa-gates/mirrors-final | 18-02 | 17-58 |
| qa-gates/bash-untouched | 18-03 | 17-59 |
| other/ac-checkoff-p14 | 18-04 | 17-59 |
| qa-gates/final-python-black | 18-06 | 18-00 |
| qa-gates/final-python-ruff | 18-07 | 18-00 |
| qa-gates/final-python-pyright | 18-08 | 18-01 |
| qa-gates/final-python-pytest-coverage | 18-12 | 18-03 |
| qa-gates/python-coverage-delta | 18-13 | 18-03 |
| other/ac-checkoff-p15 | 18-14 | 18-04 |
| qa-gates/final-powershell-format | 18-17 | 18-04 |
| qa-gates/final-powershell-format-check | 18-18 | 18-05 |
| qa-gates/final-powershell-analyze | 18-19 | 18-05 |
| qa-gates/final-powershell-pester-coverage | 18-23 | 18-09 |
| qa-gates/powershell-coverage-delta | 18-24 | 18-10 |
| other/ac-checkoff-p16 | 18-25 | 18-10 |
| qa-gates/final-ts-prettier | 18-28 | 18-11 |
| qa-gates/final-ts-eslint | 18-29 | 18-11 |
| qa-gates/final-ts-typecheck | 18-30 | 18-11 |
| qa-gates/final-ts-jest-coverage | 18-32 | 18-12 |
