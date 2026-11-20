# DocsSurface Suite ([P2-T3])

Timestamp: 2026-11-03T12-48
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree root> -ScanFolders 'tests/scripts/claude-lib/docs'; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
Output Summary: tests=123, failures=0, errors=0, skipped=0 over the three suites in tests/scripts/claude-lib/docs (DocsSurface.Tests.ps1 66, DocsFinding.Tests.ps1 30, DocsJson.Tests.ps1 27). Line coverage 100% for each of DocsSurface.psm1 (130/130), DocsFinding.psm1 (88/88) and DocsJson.psm1 (102/102). Seeds: identifier set 1020, digest property 20261030.

## Counts (artifacts/pester/pester-junit.xml)

- tests: 123 (DocsSurface.Tests.ps1 66, DocsFinding.Tests.ps1 30, DocsJson.Tests.ps1 27)
- failures: 0
- errors: 0
- skipped: 0

## Seeds

- Identifier determinism (`Get-DocsElementId` is deterministic and collision-free over a seeded input set): `[System.Random]` seed 1020, 200 generated (kind, path, declaration) inputs; the seed is printed in every failure message through `-Because`.
- Declaration-lines digest property (outside mutation never changes the digest, inside append always changes it): `[System.Random]` seed 20261030, 150 iterations; the seed, iteration, line count and range are printed in every failure message.

## Line coverage (artifacts/pester/powershell-coverage.xml)

- `.claude/lib/docs/DocsSurface.psm1`: 100% (covered 130, missed 0)
- `.claude/lib/docs/DocsFinding.psm1`: 100% (covered 88, missed 0)
- `.claude/lib/docs/DocsJson.psm1`: 100% (covered 102, missed 0)

## Golden vectors asserted

- V1..V4: `ConvertTo-DocsCanonicalJson` output equals the recorded canonical string plus LF and `Get-DocsElementId` equals `<kind>-<digest>` (evidence/other/golden-identity-vectors.2026-11-03T11-51.md).
- D1: `ConvertTo-DocsDeclarationText` returns `def handler():<LF>    return 1<LF>` and `Get-DocsDeclarationSha256` returns `4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea`.

## Early toolchain pass over the Phase 2 files (recorded for traceability; the plan's gated loop is Phase 6)

- PSScriptAnalyzer (direct, settings `scripts/powershell/PoshQC/settings/pssa.settings.psd1`) over `.claude/lib/docs` and `tests/scripts/claude-lib/docs` first reported 27 findings (0 Error, 20 Warning, 7 Information). They were fixed: the relative-path regex literals had been written with the raw U+2028 and U+2029 characters and are now built from code points so the sources are ASCII (this removed both `PSUseBOMForUnicodeEncodedFile` warnings); `OutputType` was declared on the two private helpers; `SuppressMessageAttribute` with a justification was added for the pure `New-*` factories (`PSUseShouldProcessForStateChangingFunctions`), the spec-fixed name `ConvertFrom-DocsUtf8Bytes` (`PSUseSingularNouns`) and the ordinal-hashtable test input (`PSUseLiteralInitializerForHashtable`), following the existing `.claude/lib` convention; unused `param()` blocks were removed from data-driven tests. The re-run reported 0 findings over 6 files.
- `Invoke-PoshQCFormat` over the same two folders: file digests identical before and after (no change).
- The suites above were re-run after those edits, which is the run recorded here.
- Direct sanity run of `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: 39 passed, 0 failed (the recorded run of these suites belongs to [P5-T6]).
- Logical line counts: DocsSurface.psm1 447, DocsJson.psm1 323, DocsFinding.psm1 282 (each below the 500-line guidance, so no split into `DocsDeclarationDigest.psm1` was made).

## Fixes made while bringing the suite to green

- `Get-DocsElementKind` and `Get-DocsAnalysisMethod` returned their arrays wrapped in a one-element pipeline object; they now return the arrays unrolled.
- `ConvertTo-DocsDeclarationText` assigned the empty result of an `if` expression to `$lines`, which yields `$null` under strict mode; the empty-text case now starts from an explicit empty array.

CI: `poshqc / PowerShell QC` (windows-latest).
