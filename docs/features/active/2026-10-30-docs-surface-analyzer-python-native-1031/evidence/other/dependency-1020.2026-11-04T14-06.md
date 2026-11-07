# 1020 Upstream Preconditions ([P0-T2])

Timestamp: 2026-11-04T14-06
Command: sh SCRATCH/issue-1031-run.sh issue-1031-dep1020.ps1 issue-1031-dep1020.out (imports DocsJson, DocsFinding, DocsSurface, DocsSchema, DocsAnalyzerRegistry; dot-sources Invoke-DocsCommand.ps1; Get-Command parameter sets; inspects the registry text, the context InvokeProcess member and Docs.TestSupport.psm1 exports; no process is started)
EXIT_CODE: 0
Output Summary: every U-1 to U-4 item PASS; no MISMATCH; Pester gate 150 passed, 0 failed, 0 errors.

## MERGE_BASE derivation

- `git merge-base origin/epic/documentation-estate-tooling-integration HEAD` after `git fetch origin epic/documentation-estate-tooling-integration`; the result is the merge commit of PR #1072 (1022), which includes 1020 and 1022. Recorded by derivation, not by commit identifier.

## U-1 (DocsAnalyzerRegistry.psm1)

- PASS `Get-DocsAnalyzerRegistration` parameters `ScannerRow`, `NativeRow`.
- PASS `Test-DocsAnalyzerRegistration` parameter `Registration` (keyed on `Id` and `AnalysisMethod`, native-requires-scanner rule per module help).
- PASS `Select-DocsAnalyzerRegistration` parameters `Registration`, `ElementKind`, `AnalyzerId`, `NativeAvailable`.
- PASS `Invoke-DocsAnalyzer` parameters `Registration`, `CapturedInput`, `Selection`, `ImportModule` (plus `AnalyzerFunction`).
- PASS native table: anchor `# --- 1031: Python-native analyzers ---` present in `$script:DocsAnalyzerNativeRow`, zero rows; `Get-DocsAnalyzerRegistration` returns zero native rows.

## U-2 (DocsSurface.psm1)

- PASS `New-DocsSurfaceElement` parameters `Kind`, `Path`, `Declaration`, `Name`, `AnalyzerId`, `AnalysisMethod`, `SourceText`, `ParentId`, `LineRange`, `Property` (plus `Extension`).
- PASS `Get-DocsElementId` parameters `Kind`, `Path`, `Declaration`.
- PASS `Get-DocsAnalysisMethod` returns `native`, `scanner`.
- PASS `New-DocsDiagnostic` parameters `Code`, `Path`, `Message`, `AnalyzerId`, `Severity`, `Blocking`; `-Severity information` yields severity `information`, blocking false.

## U-3 (command context process member)

- PASS `New-DocsCommandContext` builds a context whose `InvokeProcess` member is a `[scriptblock]` with parameters `FilePath`, `ArgumentList`, `StdinText`, `TimeoutSeconds` (inspected, not invoked).
- PASS start-failure code: `DOCS_PROCESS_START_FAILED` (thrown by `ConvertTo-DocsProcessResult` when the process did not start).
- PASS `TESTS/Docs.TestSupport.psm1` exports `Get-DocsTestExampleText`, `Get-DocsTestRepositoryRoot`, `Get-DocsTestSchemaText`, `New-DocsTestContext`; `New-DocsTestContext` returns `Context`, `Files`, `ProcessCallLog`, `WriteLog`, and its context carries `RepositoryRoot`, `ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`, `UtcNow`, `InvokeProcess`.

## U-4 (DocsJson, DocsFinding, DocsSchema, manifest test)

- PASS `ConvertFrom-DocsJsonText` (`Text`, `ArtifactPath`, `MaxDepth`), `ConvertTo-DocsCanonicalJson` (`Value`).
- PASS `New-DocsFinding`, `New-DocsCommandResult` present.
- PASS `Test-DocsArtifactText` (`ArtifactKind`, `JsonText`, `ComposedSchemaSet`, `ArtifactPath`).
- PASS `TESTS/Docs.Manifest.Tests.ps1` contains the `.claude/lib/docs/python` exclusion.

## Recorded values

- SEAM_FAILURE_CODE: `DOCS_PROCESS_START_FAILED`
- TEST_CONTEXT: `New-DocsTestContext` of `TESTS/Docs.TestSupport.psm1` (returns `@{Context; Files; WriteLog; ProcessCallLog}`; the `InvokeProcess` fake records calls in `ProcessCallLog` and returns a caller-configured `ProcessResult`).

## Pester gate

Command: sh SCRATCH/issue-1031-run.sh issue-1031-poshqc-gate.ps1 issue-1031-gate-p0t2.out -NoCoverage -Paths TESTS/DocsAnalyzerRegistry.Tests.ps1,TESTS/DocsSurface.Tests.ps1,TESTS/Invoke-DocsCommand.Tests.ps1,TESTS/Docs.Manifest.Tests.ps1 (branch-current Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1, coverage disabled)
EXIT_CODE: 0
Counts from artifacts/pester/pester-junit.xml: tests=150 failures=0 errors=0

| Suite | Tests | Failures | Errors |
|---|---|---|---|
| TESTS/Docs.Manifest.Tests.ps1 | 7 | 0 | 0 |
| TESTS/DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 |
| TESTS/DocsSurface.Tests.ps1 | 66 | 0 | 0 |
| TESTS/Invoke-DocsCommand.Tests.ps1 | 47 | 0 | 0 |

## Observation for Phase 4 (not a 1020 mismatch)

- `New-DocsDiagnostic` rejects the lower-case code `python-native-unavailable` (`DOCS_IDENTITY_INPUT_INVALID: Code ... does not match ^[A-Z][A-Z0-9_]*$`). The delivered diagnostic code grammar is upper-case, contrary to the plan's deviation 4 wording; the Phase 4 diagnostic needs an upper-case code. Recorded for the Phase 4 delegation.
