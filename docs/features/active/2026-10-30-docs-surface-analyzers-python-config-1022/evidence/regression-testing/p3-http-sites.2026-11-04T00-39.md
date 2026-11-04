# [P3-T5] Pester gate: DocsPythonHttpSites (issue #1022)

Timestamp: 2026-11-04T00-39
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsPythonHttpSites.Tests.ps1 -CoverageFile .claude/lib/docs/DocsPythonHttpSites.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsPythonHttpSites.Tests.ps1: 15 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=15 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsPythonHttpSites.psm1 129 of 129 analyzed lines (100%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsPythonHttpSites.psm1` and `tests/scripts/claude-lib/docs/DocsPythonHttpSites.Tests.ps1`; 0 files rewritten on the final pass.
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings on the final pass. An earlier pass reported `PSUseOutputTypeCorrectly` (added `[object[]]`) and `PSProvideCommentHelp` for `Get-DocsFastApiRouteSite`, whose help block had a line beginning with `.get .post ...` that comment-based help reads as a section keyword; the line was reworded.
- Physical line counts: `DocsPythonHttpSites.psm1` 276; `DocsPythonHttpSites.Tests.ps1` 297.
- Defect found and fixed during this task: a one-item `methods=["HEAD"]` list reaches the module as a scalar through the `if`-expression unrolling of `Read-DocsPythonCall`'s `Items`; `Read-DocsHttpMethodList` wraps it with `@()`.

## Behavior covered

- FastAPI receivers (`FastAPI()`, `APIRouter(prefix=...)` literal, absent and dynamic, through an alias), every decorator form (`get` through `trace`, `api_route` with a deduplicated upper-cased literal method list, `websocket` with method `WEBSOCKET` and `protocol` `websocket`), multi-line decorators, header spans from the route decorator to the `:` line, `add_api_route` with literal methods and the default `GET`, named by the template with the statement span; no automatic `HEAD` or `OPTIONS`.
- Flask receivers (`Flask(__name__)`, `Blueprint(..., url_prefix=...)`), `route` with and without `methods`, the shortcuts, `add_url_rule` with literal methods, converters kept verbatim; `HTTP_METHOD_VIEW_UNRESOLVED` for `add_url_rule(..., view_func=X.as_view(...))` without literal methods (classified with literal methods).
- Mount sites: `include_router` and `register_blueprint` with literal, absent and dynamic prefixes, a dotted child expression kept for pass 2, `HTTP_MOUNT_UNRESOLVED` for `.mount(...)` and for a call-valued child; untracked parents ignored.
- `HTTP_DYNAMIC_ROUTE` (non-literal path, f-string path, non-literal method list, non-literal call path), `HTTP_ROUTE_IN_LOOP` (`for` and `while` bodies, decorator and call forms), `HTTP_UNBOUND_ROUTE` (only an untracked receiver with a literal path beginning `/`; receivers and import aliases of other frameworks ignored), each with code, severity `warning`, blocking `$false`, line and survival of the other sites.
- Property tests: `property: Get-DocsFastApiRouteSite yields one site per generated decorator with its method and path` (seed 102270), `property: Get-DocsFlaskRouteSite yields one site per generated route with its methods` (seed 102271), `property: Get-DocsHttpMountSite records every generated include with its prefix in order` (seed 102272).

CI: `poshqc / PowerShell QC` (windows-latest shards).
