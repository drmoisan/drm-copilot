# Self-Review (P3-T4)

Timestamp: 2026-11-19T11-49
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against the branch diff from BASE (merge base of origin/epic/shared-agent-harness-layer-integration and HEAD; file list in final-scope-check.2026-11-19T11-47.md), plus a re-check of every `## Acceptance-Criteria Mapping` row against its test and evidence
EXIT_CODE: 0
Output Summary: No FAIL row. Every applicable checklist item is PASS; inapplicable items are N/A with the reason. S1-S16 and U1-U3, U5-U8 are PASS; S17 and U4 are N/A - CI-dependent, orchestrator-owned (P3-T5).

## A. Policy Audit Template

### 1. General Unit Test Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 1.1 Independence | PASS | Every Jest case builds its own in-memory `PushDownFileSystem` (`seed()`, `buildInMemoryFileSystem`); the contract test reads tracked files only; the Pester suite resets its mocks per `BeforeEach`. All suites passed in the parallel gates (Jest workers, 8 Pester shards). |
| 1.1 Isolation | PASS | One behavior per case (case names in task-check.P2-T2, jest-new-files, task-check.P1-T3). |
| 1.1 Fast execution | PASS | The five new Jest files run 65 tests in one selection; the Pester suite runs 25 tests in under 1s (shard log). |
| 1.1 Determinism | PASS | No clock, randomness, network, or process in the new tests; CRLF fixtures built in code; `gh` replaced by `Invoke-GhExe` mocks or a local test double. |
| 1.1 Readability | PASS | Descriptive case names matching the plan's mapping; AAA layout. |
| 1.2 Baseline coverage documented | PASS | baseline-jest, baseline-pytest, baseline-pester (2026-11-19T08-55). |
| 1.2 No coverage regression | PASS | coverage-delta.2026-11-19T11-46.md: no per-file drop; repo-wide Jest up, Pester 96.7712% vs 96.7698%, pytest equal at reported precision. |
| 1.2 Changed files meet thresholds | PASS | Every changed TypeScript file at or above 85/75 except the type-only contract file (0%, unchanged, policy-allowed); PowerShell 98.08%. |
| 1.2 New code coverage >= 90% | PASS | `push-down-ci-workflows.ts` 100% lines; `push-down-ci-layer.ts` 100% lines; `Set-CiRequiredChecks.ps1` 98.08%; added lines in edited files all covered (coverage-delta). |
| 1.2 Comprehensive coverage | PASS | Untested: one line, the `-DataFilePath` parameter default of `Set-CiRequiredChecks.ps1` (coverage does not trace parameter defaults). |
| 1.2 Positive / negative / edge / error flows | PASS | Positive: render, deliver, reuse, copy, reference; negative: invalid mode, both C# variants, malformed data text, missing fragments or markers, list/view/POST failures; edge: no language pack, collision quoting and nested files, CRLF; error: thrown before any write (write log empty). |
| 1.2 Concurrency | N/A | No concurrent code paths. |
| 1.2 State transitions | PASS | Mode transitions covered: off -> reference -> omitted (reuse), copy -> off (orphaned), payload_version change (update), edited caller (conflict). |
| 1.2.1 Per-language comparison | PASS | TypeScript, PowerShell, Python rows in coverage-delta.2026-11-19T11-46.md. |
| 1.3 Clear failure messages / AAA / intent | PASS | Jest `expect` and Pester `Should` with specific expected values; helper returns named violations. |
| 1.4 No external dependencies | PASS | No network, process, or temp file (final-scope-check token counts 0); tracked files read read-only. |
| 1.4 Mocks/stubs | PASS | `Invoke-GhExe` and `Get-CiRequiredChecksDataText` mocked with production parameter names; `-GhCommand` test double (no executable mocked). |
| 1.4 Environment stability | PASS | No global state; the direct-run test invokes the script in a child scope. |
| 1.5 Pre-submission review | PASS | This document. |

### 2. General Code Change Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 2.1 Objective / plan / documented | PASS | Issue #1050, spec.md, plan.2026-11-14T09-31.md executed task by task with task-check evidence. |
| 2.2 Simplicity | PASS | Text-template rendering with four markers; no YAML parser dependency (spec Non-Goals). |
| 2.2 Reusability | PASS | Reuses #1029's shared layer, pipeline classification, manifest writer, and `assertSingleCsharpToolchain`. |
| 2.2 Extensibility | PASS | Stems, fragments, and inputs are table-driven (`CI_STEMS`, `jobInputs`). |
| 2.2 Separation of concerns | PASS | Pure module `push-down-ci-workflows.ts` (no I/O); bundle and destination reads isolated in `push-down-ci-layer.ts`. |
| 2.3 Cohesive modules | PASS | One module for logic, one for the layer contribution, one opt-in command. |
| 2.3 At or below 800 lines | PASS | Maximum 637 (`jest.config.cjs`); no file at or above 700. |
| 2.3 Public vs internal / no circular dependencies | PASS | Helpers unexported (`packJob`, `jobInputs`, `replaceMarkerLine`, `renderJob`); ci-layer imports pipeline and ci-workflows; harness imports both; no cycle (typecheck clean). |
| 2.4 Names / docs / comments | PASS | TSDoc on every exported and internal function; PowerShell comment-based help; comments state why (e.g. protected paths, guard). |
| 2.5 Toolchain loop | PASS | final-ts-static, final-pwsh-static, final-yaml-static, final-jest, final-pytest, final-pester (loop pass 2 after remediation 1); phase gates P1 and P2 one clean pass each. |
| 2.6 Summarize / design choices / docs / next steps | PASS | Commit messages; README, CHANGELOG, workflows README; next step is P3-T5 (CI dispatch, orchestrator-owned). |

### 3. Language-Specific Code Change Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 3A Python | N/A | No Python file added or changed (S16). |
| 3B.1 Formatting / linting / all findings fixed | PASS | final-pwsh-static: 0 drift, 0 findings; two localized `SuppressMessageAttribute` entries for plan-fixed names, following `scripts/ci/CiChangeScope.psm1` and `NpmAuditGate.psm1`. |
| 3B.1 PowerShell 5.1 and 7.6+ compatible | PASS | Repository rule targets PowerShell 7+; the script uses no 7-only syntax; the workflow steps run on runner pwsh 7. |
| 3B.2 Advanced functions / validation / no global state / errors | PASS | `[CmdletBinding()]` on all four functions; `SupportsShouldProcess` on the command and `Invoke-SetCiRequiredChecks`; mandatory parameters; `throw` on every failure path; no global state. |
| 3B.3 Size / approved verbs / comments | PASS | 193 lines; verbs Invoke, Get, New (approved). |
| 3C Bash | N/A | No bash file. |
| 3D JSON | PASS | `ci-required-checks.json` sorted keys, LF, deep-equals the spec object (task-check.P1-T2). |
| TypeScript (rule file) | PASS | Prettier, ESLint, tsc clean; no `any`, no suppression (grep count 0); ES modules; strong types (`CiWorkflowsMode`, `CiStem`, `CiPackJob`). |
| GitHub Actions (rule file) | PASS | actionlint 1.7.12 clean; `workflow_call` only; pinned action majors as used in this repository; no `pwsh` step deliberately invokes a failing nested command (`.claude/rules/ci-workflows.md` pattern not triggered); caller lists `"epic/**"` (epic trigger rule). |

### 4. Language-Specific Unit Test Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 4A Python tests | N/A | No Python test added or changed. |
| 4B.1 Framework and scope | PASS | Pester 6 suite at `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1`, mirroring `scripts/ci/`. |
| 4B.2 Style / mocking rules | PASS | Wrapper mocked (not `gh`); mock signature parity; functions loaded by dot-source guard (deviation from the plan's AST wording recorded in task-check.P1-T3). |
| 4B.3 Naming | PASS | `Describe`/`It` names state the behavior. |
| 4B.4 Toolchain | PASS | Launcher pester selection and gate runs, 25 tests 0 failures. |
| TypeScript tests (rule file) | PASS | Jest, `*.test.ts`, under `test/` mirroring `src/`; no host runtime; no temp files. |

### 6-8. Metrics, Quality Checks, Gaps

| Item | Status | Evidence |
| --- | --- | --- |
| Test execution metrics | PASS | Jest 374 suites / 6184 tests; pytest 17122 passed / 6 skipped; Pester 29237 tests / 0 failures. |
| CI cross-check | N/A | CI-dependent; S17 and the branch CI run are orchestrator-owned (P3-T5). |
| Identified gaps | PASS | Recorded, none blocking: (1) one uncovered PowerShell line (parameter default); (2) one-branch run-to-run variance in the untouched `cli_copilot_runtime.py` (final-pytest.2026-11-19T11-34.md); (3) recurring PSScriptAnalyzer engine exception on untouched `scripts/ci/*.psm1` files (baseline and every run). |

## B. Code Review Template

| Severity | File | Location | Finding | Recommendation | Evidence |
| --- | --- | --- | --- | --- | --- |
| Info | `.github/workflows/harness-dotnet.yml` | job `dotnet-legacy` | The legacy job (msbuild restore, `*Tests.dll` discovery under `bin/Release`, vstest Cobertura collection) is validated only by actionlint locally; its behavior on a real legacy solution is proven only by a dispatched run. | Covered by P3-T5 (per-pack dispatch, orchestrator-owned). | final-yaml-static |
| Info | `.github/workflows/harness-python.yml` | steps Black, Ruff, Pyright | The workflow assumes the destination's Poetry project provides Black, Ruff, and Pyright, as the Python pack's rules require. | None for this item; #1051 owns destination validation. | spec Non-Goals |
| Info | `src/lib/push-down/push-down-harness.ts` | `pushDownHarness` | After an explicit `off`, a later call that omits `ci_workflows` re-infers the mode from the orphaned entries (plan `## Open Questions / Notes`). | Implemented as the spec states; no change. | harness case `explicit off after a delivery leaves the CI files in place as orphaned` |

No Blocker, Major, Minor, or Warning finding.

| Check | Status | Evidence |
| --- | --- | --- |
| Implementation audit: TypeScript | PASS | Pure logic separated; marker replacement fails with a named error on a missing marker or fragment; collision lines use `PUSH_DOWN_CONFLICT_LINE_PREFIX`. |
| Implementation audit: PowerShell | PASS | ShouldProcess around the single POST; existing ruleset reported without a write; no PUT, PATCH, or DELETE (tested). |
| Test quality audit | PASS | Determinism, isolation, speed, diagnostics as in section A 1.1. |
| No secrets in code | PASS | No token or credential; no `NPM_TOKEN` (contract test). |
| No unsafe subprocess or command construction | PASS | `gh` called with an argument array; body passed on standard input; no `Invoke-Expression`. |
| Input validation at boundaries | PASS | `ci_workflows` validated in the resolvers and `parseCiWorkflowsMode`; data text validated before any `gh` call. |
| Error handling explicit | PASS | Every failure throws with context; fail before any write (write log empty in the C# case). |
| Configuration / path handling safe | PASS | No path other than the caller and selected copies written under `.github/workflows/` (harness case); CI paths protected from `overwrite_unmanaged`. |
| Research log | N/A | No external research beyond the feature's research file. |

## C. Feature Audit Template (Acceptance-Criteria Mapping Re-check)

| AC | Status | Test / evidence re-checked |
| --- | --- | --- |
| S1 | PASS | `mcp-tool-inputs.push-down-ci-workflows.test.ts` (12 tests); harness case `plans no CI path when ci_workflows is omitted and no data-file entry exists`. |
| S2 | PASS | Inference cases in `push-down-ci-workflows.test.ts`; harness cases `reuses recorded reference mode`, `reuses recorded copy mode`, `explicit off plans no CI file`, `explicit off after a delivery leaves the CI files in place as orphaned`. |
| S3 | PASS | Pack-job and render cases in `push-down-ci-workflows.test.ts` (21 tests). |
| S4 | PASS | `rejects a selection union holding both C# variants` (unit and harness, write log empty). |
| S5 | PASS | Render cases `reference mode pins harness workflows at the payload version`, `reference mode passes no poshqc input`, `reference mode passes harness_repository and harness_ref to the PowerShell job only`; harness `reference mode plans no drm-copilot copy`. |
| S6 | PASS | `copy mode uses local copies and passes poshqc false to the PowerShell job only`; harness `copy mode writes selected copies with shared-layer manifest entries`, `delivers Set-CiRequiredChecks.ps1 byte-equal ...` (both modes). |
| S7 | PASS | Harness `writes the data file exactly in reference, copy, and withheld-caller runs`. |
| S8 | PASS | Harness `second identical apply reports every CI file unchanged`, `dry run writes no file and no manifest`, `a payload_version change reports an unedited caller update and rewrites it`. |
| S9 | PASS | Harness `reports unmanaged-conflict at a CI path even with overwriteUnmanaged true` (data file and caller), `keeps an edited managed caller as conflict`, `writes no workflows path other than the caller and selected copies`. |
| S10 | PASS | `push-down-ci-layer.test.ts` collision cases; harness `withholds the caller when another workflow is named CI, including in a dry run`. |
| S11 | PASS | Contract `harness workflows are destination-generic`, `rendered PowerShell job inputs match harness-powershell.yml declarations`; actionlint rows of phase-gate.P1 and final-yaml-static.2026-11-19T11-02. |
| S12 | PASS | Contract `caller, data file and consumers agree`, `reports a diverging in-memory template` (inversion evidence in task-check.P2-T4). |
| S13 | PASS | Contract `every brief copy names the CI data file after the refresh rule`; `test_brief_copies_are_byte_identical`, `test_brief_ci_section_names_jobs_and_required_contexts`, `ProcessReductionChain.Ledger.Tests.ps1` in phase-gate.P2. |
| S14 | PASS | `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` (25 tests); contract `new push-down CI modules invoke no gh`; coverage row 98.08% in coverage-delta. |
| S15 | PASS | docs-check.2026-11-19T10-05 (all tokens 0 before, 1 after). |
| S16 | PASS | final-scope-check.2026-11-19T11-47. |
| S17 | N/A - CI-dependent, orchestrator-owned (P3-T5) | Not executed by the executor. |
| U1 | PASS | S1, S2, S4. |
| U2 | PASS | S3, S5, S6, S11. |
| U3 | PASS | S7, S13. |
| U4 | N/A - depends on S17 (CI-dependent, orchestrator-owned) | S11 and S12 PASS; the dispatched-run part is P3-T5. |
| U5 | PASS | S8, S9, S10. |
| U6 | PASS | S14. |
| U7 | PASS | S15. |
| U8 | PASS | S16. |

### AC Status Summary

- Source: `spec.md` and `user-story.md` of the feature folder
- Total AC items: 25 (S1-S17, U1-U8)
- Checked off (delivered): 23
- Remaining (unchecked): 2
- Items remaining: S17 (CI-dependent, orchestrator-owned), U4 (depends on S17)
