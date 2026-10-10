# Execution Amendment — Operator Verification Route (Issue #847)

- Timestamp: 2026-10-09T23-50
- Plan: `docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md` (revision 1.1, preflight-cleared)
- Authority: binding operator constraints in the parallel-orchestration kickoff for `bug-burndown-2026-10-08` (cohort 0)

## Operator constraint

"PowerShell and bats verification inside the worktree: use the PoshQC MCP tools (run_poshqc_format, run_poshqc_analyze, run_poshqc_test) plus CI job logs as evidence. Do not use sh/bash/pwsh wrapper scripts."

The plan's Fail-Closed rule "No MCP PoshQC evidence" and its `pwsh`-based FULL_RUN, targeted `Invoke-Pester`, `Invoke-ScriptAnalyzer`, and AST commands cannot be run in the isolated agent worktree under this constraint (the worktree isolation guard also refuses command text containing `pwsh`). The operator constraint takes precedence. The plan's acceptance thresholds, derivations (CRP, JRP), file sets, and design contract are unchanged; only the command route that produces the observed values is substituted, as mapped below.

## Substitution map

| Plan step | Plan route | Substituted route | Where the numbers come from |
|---|---|---|---|
| FULL_RUN (P0-T5 baseline) | local `pwsh` `Invoke-PoshQCTest` | CI `poshqc / PowerShell QC` job on `main` at BASE_SHA (run 38005028184, job 114071725598), which runs `Invoke-PoshQCTest -Root` with no `-ScanFolders` and no settings override | uploaded `poshqc-test-results` artifact (`pester-junit.xml`, `powershell-coverage.xml`) downloaded with `gh run download` to `artifacts/ci/run-<id>/`; population line from the job log |
| FULL_RUN (P7-T3 final) | local `pwsh` | `gh workflow run _poshqc.yml --ref bug/powershell-aggregate-line-coverage-below-floor-847` on the final branch head, confirmed again by the PR CI `poshqc` job | same artifact and job-log sources |
| CRP / JRP reductions | PowerShell `[xml]` | equivalent Python reduction over the same XML (same selection rules: report-level LINE counter, package equal to ROOT + `scripts/dev-tools`, exact sourcefile name, integer threshold `100*covered >= 85*total`; JRP status `Passed`). ROOT is inferred from the `.claude/hooks` package name. | reduction output saved beside the downloaded artifact |
| Targeted runs (P1-T3, P2-T6, P3-T4, P4-T4, P5-T8) | in-process `Invoke-Pester` with targeted coverage | pass/fail: `mcp__drm-copilot__run_poshqc_test` with `scan_folders: ["tests/scripts/dev-tools"]`, which writes `artifacts/pester/pester-junit.xml` in the worktree (JRP read from that file); per-file coverage: CI `_poshqc.yml` dispatch on the pushed phase head (the MCP runner uses the installed extension's 127-file allow-list, which omits the new modules) | junit from the MCP run; coverage from the CI artifact |
| P0-T3 / P7-T1 format | `Invoke-Formatter` / `Invoke-PoshQCFormat` | `mcp__drm-copilot__run_poshqc_format` (P7-T1) plus the CI `Format PowerShell` step, which fails when any file is reformatted; before/after observation through `git status --porcelain` and `git hash-object` of the CPFS files | CI step conclusion and job log; git observations |
| P0-T4 / P7-T2 analyze | per-file `Invoke-ScriptAnalyzer` | `mcp__drm-copilot__run_poshqc_analyze` (call disposition) plus the CI `Analyze PowerShell` step, which throws on any finding and logs `PSScriptAnalyzer passed: no findings under <root>` otherwise | CI job log line |
| P7-T9 AST check | `Parser::ParseFile` | line-anchored `git grep` for `^Set-StrictMode -Version Latest`, `^\$ErrorActionPreference = 'Stop'`, `exit` statements, and `Import-Module` / `-Force` in the entry scripts | git grep output |
| P7-T11 line counts | `Get-Content` count | `git grep -c ''` over the CPFS files (after staging) or Read-tool line counts | git output |
| P7-T13 param-block parity | AST comparison | `git diff --unified=0 BASE_SHA -- <entry>` hunk headers proving no hunk starts within lines 1..N, plus a manual param-block comparison of `git show BASE_SHA:<entry>` against the worktree file | git output |

MCP calls are recorded with `EXIT_CODE:` as the call disposition (0 when the tool returned `ok: true`), per the known limitation that the MCP PoshQC tools return no captured output.
