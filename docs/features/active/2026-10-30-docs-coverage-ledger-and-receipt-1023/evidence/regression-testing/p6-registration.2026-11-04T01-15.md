# Suite Evidence: push-down registration ([P6-T2])

Timestamp: 2026-11-04T01-15
Command: sh SCRATCH/issue-1023-pester-run.sh tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1,tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1,tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders <the four suite files>, coverage enabled; counts from artifacts/pester/pester-junit.xml by SCRATCH/issue-1023-pester-summary.ps1 -SuiteFilter Tests.ps1)
EXIT_CODE: 0
Output Summary: JUnit root tests=91 failures=0 errors=0 disabled=0; the four named suites pass (Docs.Manifest 7, DocsNeutrality 45, ClaudeLibModuleConvention 6, enforcement-hooks-no-python-invocation 33). The four Docs.Manifest.Tests.ps1 cases that failed in Phases 1-5 (membership, bundled counterpart, byte identity) now pass, so the exit-4 convention of the earlier docs-folder runs ends here. Console: Tests Passed: 91, Failed: 0, Skipped: 0 in 23.23 s.

## Named suites (artifacts/pester/pester-junit.xml)

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | 7 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | 45 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 33 | 0 | 0 | 0 |

## Files

- Edited `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: ten `paths` entries appended directly after the existing `.claude/lib/docs/` entries (the last of which is `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json`), one per new `LIB` file, each exactly once: `DocsLedger.psm1`, `DocsLedgerRules.psm1`, `DocsEvidencePins.psm1`, `DocsStaleness.psm1`, `DocsParity.psm1`, `DocsReceipt.psm1`, `DocsLedgerMutation.psm1`, `DocsValidation.psm1`, `DocsCoverageReport.psm1`, `DocsLedgerCommands.psm1`. The only JSON edit of this feature.
- The bundle copies of [P6-T1] (`other/bundle-mirror`) are the counterparts the manifest suite hashes.

Note: the scratch launcher `SCRATCH/issue-1023-pester-run.ps1` now splits each argument on commas so several scan paths can be passed from one `sh` argument; the PoshQC call is otherwise unchanged.
