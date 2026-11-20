# Phase 6 existing Pester suites with the mirror and manifest in place ([P6-T7])

Timestamp: 2026-11-04T02-17
Command: pwsh -NoProfile -File SCRATCH/issue-1033-pester-files-junit.ps1 -Root <worktree> -Path tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1,tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1,tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1,tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1,tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1,tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1 (one Pester 5 process over the six named files with `TestResult.OutputFormat` JUnitXml written to artifacts/pester/pester-junit.xml; counts read from that file)
EXIT_CODE: 0
Output Summary: tests=111, failures=0, errors=0, skipped=0. Per suite: `Docs.Manifest.Tests.ps1` 7/0 (every file under `.claude/lib/docs` outside `python/` is listed exactly once in `core.json` and ships a byte-identical bundled copy), `DocsNeutrality.Tests.ps1` 52/0, `ClaudeLibModuleConvention.Tests.ps1` 6/0, `enforcement-hooks-no-python-invocation.Tests.ps1` 33/0, `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` 8/0, `FileSizePolicy.RepoGate.Tests.ps1` 5/0. The JUnit file contains no `DynamicInvocation` and no `InvokeExpression` finding text for any `.claude/lib/docs` file (0 matches). None of the six suites is modified (`git status --short` lists no test file; the tracked changes are the registry, its bundle copy, `core.json`, the plan, `spec.md` and `user-story.md`).

## [P6-T6] record

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`: the 17 new `.claude/lib/docs/` module paths were appended to `paths` as one contiguous block directly after the existing `.claude/lib/docs/schemas/v1/docs-command-envelope.schema.json` entry (the last existing entry), each exactly once, with no existing entry reordered or removed: DocsScannerCommon, DocsTypeScriptTokens, DocsCSharpTokens, DocsTypeScriptSyntax, DocsTypeScriptCliSupport, DocsAnalyzerTypeScriptCli, DocsTypeScriptHttpDeclaration, DocsTypeScriptHttpSupport, DocsAnalyzerTypeScriptHttp, DocsAnalyzerTypeScriptExports, DocsCSharpSyntax, DocsAnalyzerDotnetHttp, DocsAnalyzerDotnetConfig, DocsCSharpMember, DocsAnalyzerDotnetApi, DocsExtensionShape, DocsAnalyzerExtensionImport. The registry entry already existed. Proven by this artifact (`Docs.Manifest.Tests.ps1` 7/0) and `p6-pushdown-contracts.2026-11-04T02-17.md`.

## Counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | 7 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | 52 | 0 | 0 | 0 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 33 | 0 | 0 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | 8 | 0 | 0 | 0 |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | 5 | 0 | 0 | 0 |
| total | 111 | 0 | 0 | 0 |
