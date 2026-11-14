# [P4-T2] Registry rows under the 1022 anchor (issue #1022)

Timestamp: 2026-11-04T01-18
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1,tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1,tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 -CoverageFile .claude/lib/docs/DocsAnalyzerRegistry.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the registry module; one process)
EXIT_CODE: 0
Output Summary: 70 passed, 0 failed, 0 errored, 0 skipped (result object Passed=70 Failed=0 Skipped=0; JUnit well-formed, counts read from it). Per suite: `DocsAnalyzerConfigFiles.Tests.ps1` 16 passed (15 from [P4-T1] plus the new `Context 'registration'`); `DocsAnalyzerRegistry.Tests.ps1` 30 passed, unchanged; `DocsProfile.Tests.ps1` 24 passed, unchanged. Line execution: `.claude/lib/docs/DocsAnalyzerRegistry.psm1` 124 of 124 analyzed lines (100%).

## Numstat against MERGE_BASE

- `MERGE_BASE` derivation: `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`.
- Command: `git diff --numstat MERGE_BASE -- .claude/lib/docs/DocsAnalyzerRegistry.psm1`
- EXIT_CODE: 0
- Output: `5	0	.claude/lib/docs/DocsAnalyzerRegistry.psm1` (5 added, 0 deleted; the five added lines are the five rows directly under `# --- 1022: Python and configuration analyzers ---`, one row per line, in identifier order `config-files`, `python-architecture`, `python-cli`, `python-http`, `python-public-api`, each with `Version` `1.0.0`, `AnalysisMethod` `scanner` (`METHOD_FIELD`), the `ElementKinds`, `Module` and `Function` of the spec `## Behavior` analyzer table). The `1033` and `1031` anchors are untouched.

## Toolchain

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsAnalyzerRegistry.psm1` and `tests/scripts/claude-lib/docs/DocsAnalyzerConfigFiles.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files.
- Physical line counts: `DocsAnalyzerRegistry.psm1` 365 (360 at `MERGE_BASE`); `DocsAnalyzerConfigFiles.Tests.ps1` 328.
- Defect found and fixed during this task: the new `It` counted `@(Test-DocsAnalyzerRegistration ...)`, which wraps the function's comma-returned empty array as one element; the assertion now reads `(Test-DocsAnalyzerRegistration ...).Count`.

## Existing-test dispositions (from [P0-T3])

- `DocsAnalyzerRegistry.Tests.ps1`: unchanged (membership, anchor order, validity and selection assertions); 30 passed with the five rows present.
- `DocsProfile.Tests.ps1`: unchanged (the starter profile omits `surface_selection.analyzers`); 24 passed.
- `Docs.Manifest.Tests.ps1`: unchanged; the file is mirrored by [P5-T1].

## Behavior covered by the new `Context 'registration'`

- `Test-DocsAnalyzerRegistration` over `Get-DocsAnalyzerRegistration` returns no finding; each of the five identifiers is present exactly once with `AnalysisMethod` `scanner`, `Version` `1.0.0`, the expected `Function`, and a `Module` path that exists; the `config-files` row carries `ElementKinds` `config-key`.

CI: `poshqc / PowerShell QC` (windows-latest shards).
