# [P3-T6] Pester gate: DocsAnalyzerPythonHttp (issue #1022)

Timestamp: 2026-11-04T00-45
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsAnalyzerPythonHttp.Tests.ps1 -CoverageFile .claude/lib/docs/DocsAnalyzerPythonHttp.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsAnalyzerPythonHttp.Tests.ps1: 11 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=11 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsAnalyzerPythonHttp.psm1 136 of 136 analyzed lines (100%). The JUnit file is well-formed; counts were read from it. The analyzer output over the corpus inputs equals the `python-http` subset of `tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json` (23 elements, 14 diagnostics) on every element field and every diagnostic.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsAnalyzerPythonHttp.psm1` and `tests/scripts/claude-lib/docs/DocsAnalyzerPythonHttp.Tests.ps1`; 0 files rewritten.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files.
- Physical line counts: `DocsAnalyzerPythonHttp.psm1` 254; `DocsAnalyzerPythonHttp.Tests.ps1` 193.
- Defect found and fixed during this task: `Resolve-DocsHttpTemplate -Prefix` rejected an empty segment (a router constructed without a prefix contributes `''`); the parameter now carries `[AllowEmptyString()]` and the suite covers an included prefix-less router. An `It` name carrying `<dynamic>` was reworded because Pester strips angle brackets from the reported name.

## Design facts

- Pass 1 runs the shared front-end (diagnostics under `python-http`; a blocking one removes the file) and the `DocsPythonHttpSites.psm1` recognizers per input in ordinal path order. Pass 2 resolves each mount child to a receiver key: a receiver of the same input, a name bound by `from pkg.mod import router`, or `mod.router` through `from . import mod` (relative modules resolved against the input's package through `Get-DocsModuleDottedName`); an unresolved child, or a child that is an application, is `HTTP_MOUNT_UNRESOLVED` at the mount line.
- Include chains are composed upward from a route's receiver through every includer to an application (a depth above 16 or a repeated receiver on the stack is `HTTP_INCLUDE_UNRESOLVED`, reported at the route; the route keeps its own prefix with `mounted: false`); a router with no includer keeps its own prefix with `mounted: false`; `n` chains yield `n` elements. FastAPI segments are the include prefix (when given) then the router prefix; a Flask `url_prefix` on `register_blueprint` replaces the blueprint's own. A dynamic segment renders `<dynamic>`, sets `prefix_resolved: false` and reports `HTTP_PREFIX_DYNAMIC` at the receiver or mount that declared it.
- `Resolve-DocsHttpTemplate`: FastAPI verbatim concatenation; Flask `prefix.TrimEnd('/') + '/' + rule.TrimStart('/')` (the rule verbatim when no prefix applies). One element per distinct method, methods sorted ordinally, through `Select-DocsUniqueElement` with `LineRange` from `ConvertTo-DocsLineRange`; the module computes no digest.

## Behavior covered

- Corpus comparison; `GET <dynamic>/items/{item_id}` with `prefix_resolved` `false`, `mounted` `true` and one `HTTP_PREFIX_DYNAMIC` at `src/pkg/_http_fastapi.py`; `GET /ping` and `POST /ping` with the same line range; `analysis_method` `scanner` and `parent_id` `null` on every element; captured inputs not mutated; nested FastAPI includes outermost first across two inputs (`/top/mid/in/leaf/item`), a never-included router with `mounted` `false`, an included prefix-less router; Flask `url_prefix` replacement and joining without a double slash (`/bp/`, `/bp/x/`, `/v2/`, `/v2/x/`); `HTTP_INCLUDE_UNRESOLVED` for a cycle and for a 19-router chain with both routes keeping their own prefix and `mounted` `false` while a 2-deep route resolves; `HTTP_MOUNT_UNRESOLVED` for a missing module, a module without the member and an application child (3 occurrences in one diagnostic).
- Property tests: `property: Invoke-DocsAnalyzerPythonHttp output is byte-identical under permuted input order` (seed 102280); `property: Resolve-DocsHttpTemplate FastAPI templates equal the joined prefixes plus the path and Flask templates carry no double slash` (seed 102281).

## Acceptance criteria checked off

- spec S3 (`python-http` tests: FastAPI `include_router` and router prefix composition, Flask `url_prefix` joining and replacement, one element per method, the `<dynamic>` route with `prefix_resolved: false` and `HTTP_PREFIX_DYNAMIC`) in `spec.md`. User story U3 stays open: its second clause covers every `## Precision Limit` construct, including the `config-files` rows of Phase 4.

CI: `poshqc / PowerShell QC` (windows-latest shards).
