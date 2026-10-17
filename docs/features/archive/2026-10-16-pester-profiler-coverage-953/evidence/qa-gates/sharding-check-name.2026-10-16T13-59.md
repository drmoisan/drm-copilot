# Sharding: Check Name Preserved (P8-T18)

Timestamp: 2026-10-16T13-59
Command: grep -n -E "^  poshqc:|^    name: PowerShell QC$" .github/workflows/_poshqc.yml; git diff --name-only origin/main...HEAD -- .github/workflows/ci.yml; git status --porcelain
EXIT_CODE: 0

Output Summary:
- `.github/workflows/_poshqc.yml` line 75 `  poshqc:` and line 76 `    name: PowerShell QC`: the job id `poshqc` with name `PowerShell QC` is kept, so the check name stays `poshqc / PowerShell QC`. The P8-T15 workflow test ("keeps the poshqc job as the PowerShell QC merge job ...") asserts the same and passed (sharding-workflow-tests.2026-10-16T13-33.md), as did the P8-T16 full run (final-poshqc-test-coverage.2026-10-16T13-57.md).
- `git diff --name-only origin/main...HEAD -- .github/workflows/ci.yml`: empty. The full base-diff listing (final-scope-ac13.2026-10-16T13-57.md) does not contain `ci.yml`.
- `git status --porcelain`: lists only the feature-folder plan and evidence files; `.github/workflows/ci.yml` is not listed.
- Both conditions hold. Result: PASS.
