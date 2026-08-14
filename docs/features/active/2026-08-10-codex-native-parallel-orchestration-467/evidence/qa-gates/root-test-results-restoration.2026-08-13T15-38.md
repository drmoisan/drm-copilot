# Root Test Results Restoration

Timestamp: `2026-08-13T15-38`

## Root artifact

- Restore command: `git restore --source=fe0413d4aca1e76b2d02d05701fba79a887d5405 --worktree -- testResults.xml`.
- Verification command: `git diff --exit-code fe0413d4aca1e76b2d02d05701fba79a887d5405 -- testResults.xml`.
- Restore exit code: `0`.
- Verification exit code: `0`; output empty.
- Restored byte count: 55,716.
- Restored SHA-256: `02628E73BB8A090824E5E97ADEB385AF1068AD905E7DA636A40AB64FD5F0E96A`.
- No local test command wrote to `testResults.xml` after restoration.

## Authoritative PowerShell full-run evidence retained outside the root file

The JaCoCo-compatible `artifacts/pester/powershell-coverage.xml` is a coverage-only document and does not encode Pester discovery/result counts. Its current remediation-run SHA-256 is `72E8E6FA41B6C62CF020FA97D7EC9B877FA0C7FE5FEFC361D4EB8FF355782BF3`; its repository `LINE` counter is 6,529/7,035. The required pre-remediation authoritative test counts remain in the associated feature-scoped QA receipts:

- `evidence/qa-gates/powershell-tests-coverage.txt:36`: 2,430 discovered, 2,421 passed, 9 skipped/disabled, 0 failed, 0 errors, 0 inconclusive, and 0 not run.
- `evidence/qa-gates/index.md:36`: 2,430 discovered across 126 files, 2,421 passed, 9 skipped/disabled, and 0 failed.
- `evidence/qa-gates/remediation-traceability.md:49`: 2,430 discovered across 126 files, 2,421 passed, 9 skipped/disabled, and 0 failed.
- `powershell-tests-coverage.txt` SHA-256: `D01DA095893904CD4C8E88528302600EE22FF86ADF03043A46C0A1141FBBA71A`.
- `index.md` SHA-256: `759EE4291A533C612B14888E0CC54DD57F75A7B317497113E594AC8FC2368129`.

Phase 2 subsequently added focused tests and produced a separate current remediation run. That later run is recorded in `powershell-owner-comparison.2026-08-13T15-38.md` and is not substituted for the preserved 2,430-test receipt required by P5-T2.

- Root delta empty: `PASS`.
- Required 2,430/2,421/9/0 counts present outside `testResults.xml`: `PASS`.
- Acceptance result: `PASS`.
