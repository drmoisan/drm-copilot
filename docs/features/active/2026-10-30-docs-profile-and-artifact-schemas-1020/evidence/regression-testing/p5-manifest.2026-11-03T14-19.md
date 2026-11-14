# Docs Manifest Suite ([P5-T3])

Timestamp: 2026-11-03T14-19
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p5-manifest.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `Docs.Manifest.Tests.ps1` tests=7 failures=0 errors=0 skipped=0. Whole run (12 suites): tests=383 failures=0 errors=0 skipped=0.

## Cases in `Docs.Manifest.Tests.ps1`

- `Select-DocsCoreManifestPath` drops `.claude/lib/docs/python/docs_native_analyzer.py` and `.claude/lib/docs/python/sub/data.json` and keeps `.claude/lib/docs/DocsJson.psm1`, `.claude/lib/docs/schemas/v1/common.schema.json`, `.claude/lib/docs/DocsAnalyzerPythonNative.psm1`, and `.claude/lib/docs/pythonic/a.psm1`.
- The filtered discovered set (17 files under `.claude/lib/docs/`) is non-empty.
- Each filtered path is listed exactly once in `core.json` `paths` (proves [P5-T2]).
- Positive control: an in-memory manifest without the first discovered path is reported as missing that path.
- `core.json` lists no path under `.claude/lib/docs/python/`.
- Each filtered path has a bundle counterpart and is SHA-256 identical to it (proves [P5-T1]).

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| Docs.Manifest.Tests.ps1 | 7 | 0 | 0 | 0 |
| DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsNeutrality.Tests.ps1 | 35 | 0 | 0 | 0 |
| DocsProfile.Tests.ps1 | 24 | 0 | 0 | 0 |
| DocsProfileCommands.Tests.ps1 | 22 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 37 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSchemaWalk.Tests.ps1 | 12 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |
| Invoke-DocsCommand.Tests.ps1 | 44 | 0 | 0 | 0 |

CI: `poshqc / PowerShell QC` (windows-latest).
