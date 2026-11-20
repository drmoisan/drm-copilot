Timestamp: 2026-07-21T21-11

Command: git rev-parse HEAD && git status --porcelain -- scripts tests extensions
EXIT_CODE: 0

Output Summary:
- Resolved HEAD SHA: 92bf1f29659da829e4cbf4d0bcc4af2182d87b06
- Untracked/modified CODE paths (scoped to scripts, tests, extensions):
  - ` M tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1` (modified — revision-1 extension)
  - `?? tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1` (untracked — new in revision 1)
  - `?? tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1` (untracked — new in revision 1)
- CODE-path set matches exactly the three files named in the P0-T3 disposition decision, and no others.
- Scope note: `git status --porcelain` was scoped with `-- scripts tests extensions` by design. The feature folder's own untracked docs/evidence artifacts under `docs/features/active/2026-07-21-poshqc-bundled-mock-scope-failure-392/**` (this plan file, prior-run evidence, code-review/feature-audit/policy-audit/remediation-inputs) are expected, legitimate, and were excluded from the scan by design.
