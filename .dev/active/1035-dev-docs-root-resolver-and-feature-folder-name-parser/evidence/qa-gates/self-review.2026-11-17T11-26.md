# Self-Review (P9-T12)

Timestamp: 2026-11-17T11-26
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md and feature-audit.yyyy-MM-ddTHH-mm.md against the branch diff from the merge base of origin/main and HEAD (`git diff <merge base> HEAD`), the plan's Recorded Decisions D-P1 to D-P21, and the evidence under this feature folder; S-9 list from sh SCRATCH/issue-1035-p9t12-s9.sh (removed assertion lines in every modified existing test file)
EXIT_CODE: 0
Output Summary: Every checklist row is PASS or N/A; no row is FAIL. The S-9 row finds four modified existing test files with changed expectations plus one added expected entry, and every one is in the D-P20 enumeration.

## Policy audit — 1. General unit test policy

| Item | Status | Evidence |
| --- | --- | --- |
| Independence | PASS | All gates run parallel workers (pytest -n auto, Jest workers, eight Pester shards); the leak scan reports 0 failures (regression-testing/leak-scan.2026-11-17T11-22.md) |
| Isolation | PASS | New cases target one behavior each (rule IDs R-1 to R-8, F-1 to F-6, N-1 to N-5, BR-*, PA-DDR-*, EPIC-CROSS-ROOT-*, STR-ENTRY-*) |
| Fast execution | PASS | pytest 47.78 s, Jest suite run in seconds per file, Pester wall-clock 664.75 s for 27678 tests |
| Determinism | PASS | Resolver I/O is injected (`-ReadText`/`-TestDirectory`, `read_text`/`is_dir`, structural reader); in-memory fakes; no clock read in tests |
| Readability | PASS | Arrange/Act/Assert comments and spec rule IDs in test names |
| Baseline coverage documented | PASS | evidence/baseline/python-tests, typescript-tests, powershell-tests |
| No coverage regression | PASS | qa-gates/coverage-delta.2026-11-17T11-24.md: no per-file or repo-wide drop |
| Changed files meet thresholds | PASS | New files 97.09 to 100% line; pre-existing below-threshold files are each at or above baseline |
| New code coverage >= 90% | PASS | Changed lines: Python 100.00%, TypeScript 100.00%, PowerShell 97.49% (per-file shortfalls listed in coverage-delta) |
| Comprehensive coverage | PASS | Every resolver rule, parser rule, write-scope row and routed consumer has a named case (plan `## Spec Rule Traceability`) |
| Positive flows | PASS | `.dev` and `docs/features` acceptance cases in each routed consumer suite |
| Negative flows | PASS | R-3/R-4 errors, unknown root (BR-FEATURE-GLOB-REJECTS-UNKNOWN-ROOT, test_derivation_rejects_an_unknown_development_docs_root), one-root required-artifact pattern in the checker |
| Edge cases | PASS | Empty segment and folder-only paths, no closing front-matter delimiter, issue 42 padding (N-cases) |
| Error handling | PASS | Fail-closed reason naming the file and key (Pester), throws on failed resolution (STR-ENTRY-THROWS-ON-FAILED-RESOLUTION) |
| Concurrency | N/A | No concurrent code paths changed |
| State transitions | N/A | No stateful component added |
| Clear failure messages | PASS | `-Because` texts and assertion messages name the path or literal |
| Arrange-Act-Assert | PASS | New tests follow AAA |
| Document intent | PASS | Suite headers state issue #1035 and the spec rule |
| Avoid external dependencies | PASS | No network, process or temporary file in new tests (P1-T4 no-vscode check, in-memory readers) |
| Use mocks/stubs | PASS | Resolver mocked to `docs/features` as setup (D-P16); Test-Path/Import-Module mocks for the Codex probe |
| Environment stability | PASS | Tests read committed files only; no config mutation |
| Pre-submission review | PASS | This record |

## Policy audit — 2. General code change policy

| Item | Status | Evidence |
| --- | --- | --- |
| Clarify the objective | PASS | spec.md Phase 1 of #1016, issue #1035 |
| Read existing change plans | PASS | plan.2026-10-30T17-11.md with Recorded Decisions D-P1 to D-P21 |
| Document the plan | PASS | Plan check-offs and per-task evidence (62 task checks, 8 phase gates) |
| Simplicity first | PASS | One resolver per runtime plus known-root helpers; consumers call them rather than holding literals |
| Reusability | PASS | Shared `DevelopmentDocsRoot.psm1`, `json_config.py` helpers, `root.ts`, `write-scopes.ts` |
| Extensibility | PASS | Closed root set in one constant per runtime; the write-scope rule table is the generator interface for epic child 3 |
| Separation of concerns | PASS | Resolvers take injected readers; derivations (blast radius) stay pure per OD-P4 |
| Cohesive modules | PASS | New modules hold one concern each |
| At or below the 800-line hard limit | PASS | qa-gates/file-size.2026-11-17T11-25.md: none above 800; six advisory files listed |
| Public vs internal | PASS | `Get-FeatureFolderGlob` stays unexported; TS exports match spec signatures |
| No circular dependencies | PASS | `json_config.py` imports no `scripts.dev_tools` module (AST test); the PowerShell module imports nothing |
| Descriptive names | PASS | `Resolve-DevelopmentDocsRoot`, `knownRootPrefixes`, `expandWriteScopeLiterals` |
| Docs/docstrings | PASS | Module and function docstrings, `.PARAMETER` help updated |
| Comment why | PASS | Comments state the issue and the reason (D-P16 call-time import, OD-P4 purity) |
| Toolchain: formatting | PASS | Black, Prettier, PoshQC format: 0 changes in the final loops |
| Toolchain: linting | PASS | Ruff 0, ESLint 0, PSScriptAnalyzer 0 |
| Toolchain: type checking | PASS | Pyright 0, tsc 0 (N/A for PowerShell) |
| Toolchain: testing | PASS | pytest 0 failed, Jest 0 failed, Pester 0 failed |
| Full toolchain loop | PASS | Each language loop restarted from formatting after its coverage fixes and ended with one clean pass |
| Explicit reporting | PASS | qa-gates and other evidence records |
| Summarize changes | PASS | Commit messages per task group |
| Design choices explained | PASS | Recorded Decisions and evidence decision notes (residual-search, coverage-delta, task-check.P7-T5) |
| Update supporting documents | PASS | Execution-environment brief (six copies) and .github/workflows/README.md (P8-T2) |
| Provide next steps | PASS | CI-dependent acceptance items listed as pending CI in the final report |

## Policy audit — 3. Language-specific code change

| Item | Status | Evidence |
| --- | --- | --- |
| Python: Black, Ruff, Pyright, Pytest | PASS | qa-gates/python-static.2026-11-17T10-18.md, python-tests.2026-11-17T10-18.md |
| Python: strong typing | PASS | Full annotations; Pyright 0 |
| Python: dataclasses, protocols, utility classes | N/A | No new class; functions extend `json_config.py` in place |
| Python: specific exceptions | PASS | `ValueError` naming the root or value |
| Python: logging over print | N/A | No logging path changed |
| Python: invariants at construction | N/A | No new class |
| PowerShell: Invoke-Formatter, PSScriptAnalyzer, fix all findings | PASS | qa-gates/powershell-static.2026-11-17T11-20.md |
| PowerShell: 7 compatible | PASS | Analyzer compatibility rules 0 findings |
| PowerShell: advanced functions, parameter validation | PASS | `[CmdletBinding()]`, `ValidateSet('docs/features', '.dev')`, argument errors for unknown roots |
| PowerShell: avoid global state | PASS | Script-scope constants only; no global variable |
| PowerShell: error handling | PASS | Guarded imports with `Add-HookDependencyFailure`; fail-closed reasons |
| PowerShell: cohesive and within 800 lines | PASS | file-size record |
| PowerShell: approved verbs, comment why | PASS | Analyzer 0; comments state reasons |
| PowerShell: format, analyze, test, rerun loop | PASS | P9-T7/P9-T8 restart recorded |
| Bash scripts | N/A | No production bash script changed |
| JSON: structure, strict JSON, key order | PASS | config/ci-docs-only-paths.json and routing configs parse in their suites; Prettier clean |
| JSON: schema validation, `$schema` | N/A | The changed JSON files have no schema |

## Policy audit — 4. Language-specific unit test

| Item | Status | Evidence |
| --- | --- | --- |
| Python: Pytest, focused tests, sparing mocks, organization, naming, docstrings | PASS | New tests in existing modules (AD-3); docstrings on each |
| Python: no alternative runner | PASS | Launcher pytest only |
| PowerShell: Pester 6, PoshQC configuration, launcher route | PASS | `Invoke-PoshQCParallelTest` through the launcher |
| PowerShell: focused tests, behavior over implementation, sparing mocks | PASS | Mocks limited to the resolver setup and the probe seams |
| PowerShell: `*.Tests.ps1`, Describe/Context/It, grouping, comments | PASS | New suites under tests/scripts mirror the source tree |
| PowerShell: no alternative runner | PASS | No direct Invoke-Pester gate |

## Code review

| Item | Status | Evidence |
| --- | --- | --- |
| Python implementation | PASS | Resolver R-1 to R-8, parser F/N rules, blast-radius root parameter without resolver call |
| TypeScript implementation | PASS | No `vscode` import (P1-T4 negative observation), threshold entries per file, write-scope contract matches spec signatures |
| PowerShell implementation | PASS | Hooks import with the guarded pattern; Codex importers probe the bundle sibling first (D-P16), now tested |
| C# implementation | N/A | No C# |
| Test quality: reviewed artifacts | PASS | Task checks, phase gates P1 to P8, final gates |
| Test quality: discriminating cases | PASS | Negative observations for P1-T4 and P7-T5; BR-* and PA-DDR-* cases fail when the passed root is ignored |
| Security / correctness | PASS | Fail-closed behavior for malformed configuration; no new permission broader than the contracted literals; checker reverse coverage rejects unproduced literals |
| Mirror and bundle parity | PASS | Resource and Codex parity contracts pass in every gate; generator check no drift |
| Process-reduction ledger | PASS | Only the 0010 hunk changed, in a `reduction: 0010` commit (other/scope-boundary.2026-11-17T10-13.md) |

## Feature audit

| Item | Status | Evidence |
| --- | --- | --- |
| Scope and baseline | PASS | Phase 0 baseline artifacts; scope boundary all PASS |
| Acceptance criteria inventory | PASS | spec.md and user-story.md acceptance criteria |
| Acceptance criteria evaluation | PASS | Every non-CI criterion checked off with task evidence; CI-dependent criteria (full suites in CI and the seven-stage toolchain including integration tests in CI) are pending CI |
| AC check-off | PASS | See the AC status in the final report |

## Recorded Decisions and changed-behavior dispositions

| Decision | Status | Evidence |
| --- | --- | --- |
| D-P1 to D-P6, D-P9, D-P10, D-P14 | PASS | Phases 1 to 4 task checks |
| D-P7 | PASS | quality-tiers.yml carries `.claude/lib/development-docs` |
| D-P8 | PASS | .codex/hooks/hook-docs-only-diff.ps1 accepts `.dev/` |
| D-P11 | PASS | Message texts keep `docs/features/active` (residual-search prose class) |
| D-P12 | PASS | Merge-base handling per the plan |
| D-P13 | PASS | Ten Stay rows on the residual allowlist |
| D-P15 | PASS | P8-T1 |
| D-P16 | PASS | Call-time imports; guarded hook imports; Codex probe tested (powershell-tests) |
| D-P17 | PASS | One 0010 hunk regenerated in the `reduction: 0010` commit |
| D-P18, D-P19 | PASS | Residual-search allowlist rows |
| D-P20 | PASS | S-9 row below |
| D-P21 | PASS | Threshold block placement, epic-orchestrator literal placement and the other recorded placements (task checks P1-T2, P7-T1, P7-T2) |

## S-9: existing tests whose expectation changed

| Test file | Changed expectation | D-P20 item |
| --- | --- | --- |
| extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts | two `buildFolderSlug` expectations for a supplied issue number | (1) P2-T1/P2-T2 folder naming |
| tests/scripts/dev_tools/test_new_active_feature_folder.py | one slug expectation for a supplied issue number | (1) P2-T1/P2-T2 folder naming |
| tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py | `test_feature_review_agent_grants_mcp_artifact_validator` tuple gains `Write(/.dev/active/**)` (added entry, no removed line) | (2) P7-T2 |
| tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | `.claude/agents/epic-orchestrator.md` digest with its dated comment | (3) P7-T2 |
| tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | `starts every include prefix with docs/` (now docs/ or .dev/), `configures exactly the D3 include prefixes and extensions`, the `-Because` text of `lists <Prefix> as an include prefix (#973)`, and added rows of the cover, exclude and include tables | (4) P8-T1 |

No changed expectation lies outside D-P20. The P2-T3/P2-T4 status-line expectations were added as new cases. Tests added during the final gates (coverage fixes in P9-T4, P9-T6 and P9-T8) are new cases and change no existing expectation.
