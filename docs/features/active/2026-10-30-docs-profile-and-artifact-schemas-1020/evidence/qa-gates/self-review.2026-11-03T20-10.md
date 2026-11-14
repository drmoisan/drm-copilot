# Self-Review ([P6-T13])

Timestamp: 2026-11-03T20-10
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff MERGE_BASE HEAD` (MERGE_BASE 01706c697f3ad4a53b4a771d99d851afc7417ea9), every AC in spec.md and user-story.md, and `## Design Constraints From Existing Tests` of the plan
EXIT_CODE: 0
Output Summary: 0 FAIL rows. Template and design-constraint rows: 100 PASS, 0 FAIL, 12 N/A (several N/A rows group a whole out-of-scope language section). AC rows: 49 PASS, 0 FAIL, 2 N/A (the two CI-dependent ACs, pending [P6-T12]). Two items are recorded for the orchestrator under `## Gaps and Items for the Orchestrator`: the [P6-T6] acceptance as written is not met on the current host (pre-existing host-dependent failures; task left unchecked), and the governed-glob JSON formatter would reorder the keys of the seven docs examples (outside the plan's scope; not a CI gate).

Scope: 65 changed paths outside `docs/features/` (9 PowerShell production files, 8 runtime schema copies, 17 bundle copies, 8 canonical schemas, 7 examples, `core.json`, `quality-tiers.yml`, 14 test files), the feature folder, and the sibling feature and epic documents carried from the integration branch (present at [P0-T3]).

## 1. Policy audit template

### 1.1 Core principles (general unit test policy)

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | Three seeded shuffled file-order runs (seeds 1020, 20261030, 7), 389 of 389 each (`evidence/regression-testing/isolation-shuffled.2026-11-03T18-50.md`). |
| Isolation | PASS | One suite per production module (twelve suites plus the manifest and neutrality suites); each `It` names one behavior. |
| Fast execution | PASS | The twelve docs suites took about 44 s in total in the [P6-T3] run; the slowest file took 15.61 s for its whole suite. Per-test times were not extracted. |
| Determinism | PASS | Seeded `[System.Random]` property tests print the seed; no wall clock (`UtcNow` injected), no process, no timer; token searches 0 (`qa-hygiene-and-size.2026-11-03T20-08.md`). |
| Readability and maintainability | PASS | Describe/Context/It names state the scenario and outcome; shared builders in `Docs.TestSupport.psm1`. |

### 1.2 Coverage and scenarios

| Item | Status | Evidence |
|---|---|---|
| Baseline coverage documented | PASS | 93.62% overall at [P0-T6]; new-code baseline: not present (`evidence/baseline/baseline-pester-coverage.2026-11-03T12-09.md`). |
| No coverage regression | PASS | No existing production line changed (every PowerShell production file in the diff is new). Overall 93.62% to 92.65% is a cross-host comparison; the 268 lost lines are in pre-existing scripts whose tests fail on the current host on the unchanged merge base (`coverage-delta.2026-11-03T20-06.md`, `evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`). |
| New code coverage (repository floor 85% line; the template's 90% figure is superseded by `.claude/rules/general-unit-test.md`) | PASS | Nine files 85.91% to 100% (`qa-pester-coverage.2026-11-03T18-44.md`); every missed line of `Invoke-DocsCommand.ps1` is inside the two capped bodies (16 of 20, 5 of 6). |
| Comprehensive coverage | PASS | Seven of nine files at 100%; uncovered lines are the two bodies that no test may execute (process start, file write) and two lines of `DocsProfileCommands.psm1` (97.1%). |
| Positive flows | PASS | Example validation, `validate-profile` exit 0, init dry run and `-Write`, digest equality cases. |
| Negative flows | PASS | Required-field, unknown-kind, duplicate-key, unknown-audience, exit 2 argument cases, registry defects. |
| Edge cases | PASS | Empty file and BOM-only decode, digest range bounds, `architecture-component` without range, non-empty `extensions`, recursive `json-value`. |
| Error handling | PASS | Exit 3 runtime and version paths; `DOCS_PROCESS_ARGUMENT_INVALID` and `DOCS_PROCESS_START_FAILED` through the pure functions. |
| Concurrency | N/A | No concurrent code paths. |
| State transitions | N/A | No stateful component; init create/overwrite is covered as input combinations. |

### 1.2.1 Per-language coverage comparison

| Item | Status | Evidence |
|---|---|---|
| PowerShell | PASS | Baseline 93.62% (other host) to 92.65% (current host); new-code 85.91% minimum per file; `coverage-delta.2026-11-03T20-06.md`. |
| Python, TypeScript, C# | N/A | Out of scope; no file in those languages changed (`qa-no-python-typescript.2026-11-03T20-07.md`). |

### 1.3 Test structure and diagnostics

| Item | Status | Evidence |
|---|---|---|
| Clear failure messages | PASS | Assertions compare finding codes, pointers, and digests; seeded tests print the seed. |
| Arrange-Act-Assert | PASS | Builders arrange in-memory contexts; one call acts; `Should` asserts. |
| Document intent | PASS | Each suite carries a synopsis comment; `It` names describe the expected outcome. |

### 1.4 External dependencies and environment

| Item | Status | Evidence |
|---|---|---|
| Avoid external dependencies | PASS | No network, process, or timer; repository reads only through read-only real-context members against committed files. |
| Use mocks/stubs | PASS | `Invoke-DocsProcess` and `Write-DocsFileText` mocked; `Test-Json` mocked only in `DocsSchema` module scope. |
| Environment stability | PASS | No temporary files (0 matches for the five temp tokens); no `$env:` mutation in docs tests or modules. |

### 1.5 Policy audit requirement

| Item | Status | Evidence |
|---|---|---|
| Pre-submission review | PASS | This artifact; the formal review set is produced by `feature-review` after the PR opens. |

### 2.1 Before making changes

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | Issue #1020, epic child wave 0; spec version 0.7. |
| Read existing change plans | PASS | Phase 0 read record `evidence/baseline/phase0-instructions-read.2026-11-03T11-47.md`. |
| Document the plan | PASS | `plan.2026-10-30T16-08.md`, validator exit 0 at [P0-T2]. |

### 2.2 Design principles

| Item | Status | Evidence |
|---|---|---|
| Simplicity first | PASS | Pure modules plus one entry script; command and analyzer selection through table rows. |
| Reusability | PASS | Shared finding, JSON, and schema helpers; `Docs.TestSupport.psm1` for test contexts. |
| Extensibility | PASS | Owner anchors in the dispatch table and the two registry tables; optional `[scriptblock]` seams with committed defaults. |
| Separation of concerns | PASS | I/O only in the entry script's context members; validation and shaping in pure functions. |

### 2.3 Module and file structure

| Item | Status | Evidence |
|---|---|---|
| Cohesive modules | PASS | One concern per module (JSON, findings, schema, schema walk, surface, registry, profile, commands). |
| At or below the 800-line hard limit | PASS | Largest file 458 logical lines; no file at or above 700 (`qa-hygiene-and-size.2026-11-03T20-08.md`). |
| Public vs internal | PASS | Each module ends with an explicit `Export-ModuleMember -Function` list. |
| No circular dependencies | PASS | Import graph is acyclic: JSON and Finding at the base; Schema imports SchemaWalk; command modules import downward; the entry script imports four base modules and loads command modules by row. |

### 2.4 Naming, docs, and comments

| Item | Status | Evidence |
|---|---|---|
| Descriptive names | PASS | `Docs`-prefixed nouns; finding codes `DOCS_*`. |
| Docs/docstrings | PASS | Comment-based help on every function and module; entry script `.SYNOPSIS`, `.DESCRIPTION`, `.NOTES`. |
| Comment why, not what | PASS | Comments state rationale (for example the closure resolution note, the unexecuted-seam note). |

### 2.5 Toolchain execution

| Item | Status | Evidence |
|---|---|---|
| 1. Formatting | PASS | `qa-poshqc-format.2026-11-03T14-26.md`: digest listings identical. |
| 2. Linting | PASS | `qa-pssa.2026-11-03T14-27.md`: 0 findings. |
| 3. Type checking | N/A | PowerShell. |
| 4. Testing | PASS | `qa-pester-coverage.2026-11-03T18-44.md`: 3784 tests, 0 failures, 0 errors. |
| Full toolchain loop | PASS | Format, analyze, and test completed without a file change in this pass; contract gates `qa-existing-gates.2026-11-03T18-48.md`. The CI-shape full run is covered under Gaps. |
| Explicit reporting | PASS | One artifact per gate under `evidence/qa-gates/` and `evidence/regression-testing/`. |

### 2.6 Summarize and document

| Item | Status | Evidence |
|---|---|---|
| Summarize changes | PASS | Conventional commits per phase on the branch. |
| Design choices explained | PASS | Spec `## Decisions Later Children Must Honor`; implementation notes in `evidence/regression-testing/p4-entry.2026-11-03T14-00.md`. |
| Update supporting documents | PASS | Plan Artifact Classification includes the split module rows; spec and user-story AC check-offs. |
| Provide next steps | PASS | [P6-T12] CI read after PR creation; Gaps section below. |

### 3A Python code change policy

| Item | Status | Evidence |
|---|---|---|
| 3A.1 to 3A.3 (11 items) | N/A | No Python file added or modified. |

### 3B PowerShell code change policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | [P6-T1] artifact. |
| Linting with PSScriptAnalyzer | PASS | [P6-T2] artifact, 0 findings with the repository settings. |
| Fix all findings | PASS | No open finding; suppressions carry justifications (pure in-memory factories, case-sensitive key maps, spec-fixed export name). |
| PowerShell version compatibility | PASS | Spec sets a 7.4 floor (OQ-3), enforced with `DOCS_RUNTIME_UNSUPPORTED` exit 3 and tested through `-PowerShellVersion`; 5.1 is out of scope by owner decision. |
| Advanced functions | PASS | `[CmdletBinding()]` on every function. |
| Parameter validation | PASS | `Mandatory`, `ValidateSet`, `AllowNull`/`AllowEmptyString` used where contracts require. |
| Avoid global state | PASS | No `$global:`; script-scope tables are read-only data. |
| Error handling | PASS | `throw` with `DOCS_*` codes; no empty catch; the single catch in `Invoke-DocsProcess` returns a shaped start failure. |
| Cohesive and within the file-size limit | PASS | 458 lines maximum. |
| Approved verbs | PASS | Assert, ConvertFrom, ConvertTo, Get, Invoke, Join, New, Read, Resolve, Select, Test, Update, Write; PSSA reports no unapproved verb. |
| Comment why | PASS | See 2.4. |
| Step 1 Format | PASS | [P6-T1]. |
| Step 2 Analyze | PASS | [P6-T2]. |
| Step 3 Type check | N/A | PowerShell. |
| Step 4 Test | PASS | [P6-T3]. |
| Rerun loop if needed | PASS | No file changed in Phase 6, so no restart was needed. |
| ShouldProcess for state-changing actions (`.claude/rules/powershell.md`) | PASS | The only writes are `Write-DocsFileText` and the `WriteText` member, reached only from `init -Write` after the dry run lists every planned path (OQ-5); the forwarding function carries a justified suppression. Recorded as Info for the reviewer. |

### 3C Bash

| Item | Status | Evidence |
|---|---|---|
| 3C.1 and 3C.2 (6 items) | N/A | No shell script changed. |

### 3D JSON configuration

| Item | Status | Evidence |
|---|---|---|
| Formatting with jq (`scripts.dev_tools.format_json`) | N/A | Not a plan gate and not a CI gate. Observation: `--check` reports `would reformat` for the seven `examples/docs/v1/` files (governed glob `examples/**/*.json`) because their keys are in artifact-header order, not sorted; `schemas/` is not a governed glob (the discovery schemas report the same). Recorded under Gaps. |
| Schema validation (`validate_json`) | N/A | The plan's `## Open Questions / Notes` records that the manual tool may report the URN `$schema` of the examples, is not a CI gate, and is not run; examples are validated by `DocsSchemaContract.Tests.ps1` (49 of 49). |
| Required $schema | PASS | Every artifact example carries its URN `$schema`; the envelope example carries none by design (spec D5). |
| Strict JSON only | PASS | All files parse with `ConvertFrom-DocsJsonText` (duplicate-key and depth checks) in the contract suite. |
| Deterministic key order | N/A | Same observation as the formatting row; output JSON from the tools is canonical (ordinal key order), asserted in `DocsFinding.Tests.ps1`. |

### 4A Python unit tests

| Item | Status | Evidence |
|---|---|---|
| 4A.1 to 4A.4 (9 items) | N/A | No Python test. |

### 4B PowerShell unit tests

| Item | Status | Evidence |
|---|---|---|
| Use Pester v5.x | PASS | Pester 5.9.1; `BeforeAll`, `Describe`/`Context`/`It`, `Should -Be`. |
| Use PoshQC configuration | PASS | `Invoke-PoshQCTest` from `scripts/powershell/PoshQC/PoshQC.psd1`; no settings change. |
| Version compatibility | PASS | See 3B; 7.4 floor. |
| Focused unit tests | PASS | 383 tests across 12 suites. |
| Behavior over implementation | PASS | Assertions on codes, pointers, envelopes, and exit codes. |
| Mocking used sparingly | PASS | Three mocks: the process seam, the file-write primitive, and `Test-Json` in one module scope. |
| Organization (mirrors code location) | PASS | `.claude/lib/docs/<Module>` to `tests/scripts/claude-lib/docs/<Module>.Tests.ps1`. |
| File naming | PASS | `*.Tests.ps1`. |
| Describe/Context/It structure | PASS | 55 lines that begin with `Describe` across the twelve suites. |
| Logical grouping | PASS | One `Describe` per function or contract area. |
| Docstrings/comments | PASS | Suite synopsis blocks. |
| Use PoshQC test command | PASS | [P6-T3] and [P6-T6]. |
| No alternative test runners | PASS | The shuffled and comparison runs call `Invoke-Pester` (the same engine) only to control file order, as the isolation checks require. |

### 5 to 10 (detail, metrics, quality checks, gaps, summary, verdict)

| Item | Status | Evidence |
|---|---|---|
| Test coverage detail per module | PASS | Per-file table in `qa-pester-coverage.2026-11-03T18-44.md`. |
| Test execution metrics | PASS | 3784 tests in the claude-lib scope, 0 failures; 389 in each shuffled run. |
| Code quality checks | PASS | Format, PSSA, Pester artifacts above. |
| Gaps and exceptions | PASS | Listed below; no approved exception is claimed. |
| Summary of changes | PASS | Scope paragraph above; commits on the branch. |
| Compliance verdict | PASS | Ready for PR, with the CI read ([P6-T12]) and the two items below for the orchestrator. |

## 2. Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings table (no Blocker or Major) | PASS | Info: ShouldProcess handled by the init dry run (3B). Info: example key order versus the governed formatter (3D). |
| PowerShell implementation: what changed well | PASS | Thin process seam with pure request and result functions; scriptblock seams satisfy the dynamic-invocation guard. |
| PowerShell API and safety notes | PASS | No `Invoke-Expression`, no `&` of a member expression, no shell execution (`UseShellExecute = $false`, argument list, no command string). |
| PowerShell error handling and logging | PASS | Findings carry codes and pointers; exit 3 writes one stderr line. |
| Python, TypeScript, C# audits | N/A | Not in scope. |
| Test quality audit: determinism, isolation, speed, diagnostics | PASS | Section 1.1. |
| No secrets in code | PASS | Neutrality suite holds consumer identifiers only as SHA-256 digests; no credentials. |
| No unsafe subprocess or command construction | PASS | `ProcessStartInfo` with `ArgumentList`; no test starts a process. |
| Input validation at boundaries | PASS | Relative-path checks, argument parsing exit 2, `ConvertTo-DocsProcessRequest`. |
| Error handling remains explicit | PASS | See 3B. |
| Configuration and path handling is safe | PASS | Paths resolved under `RepositoryRoot`; non-relative paths rejected with `DOCS_CLI_ARGUMENTS`. |
| Research log | PASS | Research files under `research/`; the `Test-Json` recursion probe `evidence/other/testjson-recursive-ref-probe.2026-11-03T12-11.md`. |
| Verdict | PASS | Consistent with the findings above. |

## 3. Design constraints from existing tests

| Item | Status | Evidence |
|---|---|---|
| No dynamic invocation, `Invoke-Expression`, or Python interpreter | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 33 of 33; log has none of the four finding names (`qa-existing-gates.2026-11-03T18-48.md`). |
| Module convention (help sentence, strict-mode guard, `-ErrorAction Stop` imports) | PASS | `ClaudeLibModuleConvention.Tests.ps1` 6 of 6 for the `.psm1` files. |
| Entry-script help sentence and strict-mode guard | PASS | `Invoke-DocsCommand.ps1` `.NOTES` holds `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'` at script scope; each column-0 `Import-Module` carries `-ErrorAction Stop`. |
| No checkpoint reader | PASS | `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` 8 of 8. |
| File-size gate | PASS | `FileSizePolicy.RepoGate.Tests.ps1` 5 of 5; 500-line guidance held. |
| No solution-file reference | PASS | `test_push_down_issue_824_follow_ups.py` unchanged; push-down gates 60 of 60. |
| `-PowerShellVersion` seam | PASS | Exit 3 version path tested in `Invoke-DocsCommand.Tests.ps1`. |

## 4. Feature audit: acceptance criteria

### From spec.md (S1 to S32)

| AC | Status | Evidence |
|---|---|---|
| S1 examples validate | PASS | `DocsSchemaContract.Tests.ps1` 49 of 49. |
| S2 rejection per artifact schema and `extensions` walk | PASS | `DocsSchemaContract.Tests.ps1`. |
| S3 validate-profile exit 0 | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsProfileCommands.Tests.ps1`. |
| S4 exit 1 names the field | PASS | `DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`. |
| S5 duplicate key, unknown audience, missing profile | PASS | `DocsProfile.Tests.ps1`, `DocsProfileCommands.Tests.ps1`. |
| S6 init | PASS | `DocsProfileCommands.Tests.ps1`. |
| S7 identifier determinism and golden vectors | PASS | `DocsSurface.Tests.ps1`; `evidence/other/golden-identity-vectors.2026-11-03T11-51.md`. |
| S8 tamper and cli-option parent | PASS | `DocsSurface.Tests.ps1`. |
| S9 neutrality | PASS | `DocsNeutrality.Tests.ps1` 35 of 35. |
| S10 manifest and bundle identity | PASS | `Docs.Manifest.Tests.ps1` 7 of 7. |
| S11 existing push-down tests unmodified | PASS | `qa-existing-gates.2026-11-03T18-48.md`. |
| S12 runtime copies | PASS | `DocsSchemaContract.Tests.ps1`. |
| S13 common parity, no discovery refs | PASS | `DocsSchemaContract.Tests.ps1`. |
| S14 composition | PASS | `DocsSchema.Tests.ps1`. |
| S15 single `DOCS_SCHEMA_INVALID` | PASS | `DocsSchema.Tests.ps1`. |
| S16 exit codes | PASS | `Invoke-DocsCommand.Tests.ps1`. |
| S17 `-Json` envelope and summary line | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsFinding.Tests.ps1`. |
| S18 dispatch anchors | PASS | `Invoke-DocsCommand.Tests.ps1`. |
| S19 registry tables and anchors | PASS | `DocsAnalyzerRegistry.Tests.ps1`. |
| S20 module convention and 500 lines | PASS | `qa-existing-gates.2026-11-03T18-48.md`, `qa-hygiene-and-size.2026-11-03T20-08.md`. |
| S21 tier entry | PASS | `qa-existing-gates.2026-11-03T18-48.md`. |
| S22 no Python or TypeScript; classification | PASS | `qa-no-python-typescript.2026-11-03T20-07.md`. |
| S23 discovery unchanged | PASS | `qa-discovery-scope.2026-11-03T20-07.md`. |
| S24 no temporary files | PASS | `qa-hygiene-and-size.2026-11-03T20-08.md`. |
| S25 line coverage at least 85% per file | PASS | `qa-pester-coverage.2026-11-03T18-44.md` (location `evidence/qa-gates/` per the plan's override). |
| S26 CI checks | N/A | CI-dependent; pending [P6-T12]. |
| S27 analysis method | PASS | `DocsSchemaContract`, `DocsSurface`, `DocsAnalyzerRegistry` suites. |
| S28 declaration-lines digest | PASS | `DocsSurface.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`. |
| S29 envelope schema | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `Docs.Manifest.Tests.ps1`. |
| S30 audience identifiers | PASS | `DocsSchemaContract.Tests.ps1`, `DocsProfile.Tests.ps1`. |
| S31 diagnostic severity | PASS | `DocsSurface.Tests.ps1`. |
| S32 process member | PASS | `Invoke-DocsCommand.Tests.ps1` 44 of 44; token searches 0; enforcement suite 33 of 33. |

### From user-story.md (U1 to U19)

| AC | Status | Evidence |
|---|---|---|
| U1 examples validate and reject | PASS | `DocsSchemaContract.Tests.ps1`. |
| U2 validate-profile exit codes and field naming | PASS | `DocsProfileCommands.Tests.ps1`, `DocsSchema.Tests.ps1`. |
| U3 init | PASS | `DocsProfileCommands.Tests.ps1`. |
| U4 identifier determinism | PASS | `DocsSurface.Tests.ps1`. |
| U5 neutrality | PASS | `DocsNeutrality.Tests.ps1`. |
| U6 push-down copy and manifest | PASS | `Docs.Manifest.Tests.ps1`, push-down gates. |
| U7 runtime copies | PASS | `DocsSchemaContract.Tests.ps1`. |
| U8 exit codes and envelope | PASS | `Invoke-DocsCommand.Tests.ps1`. |
| U9 anchors and registry | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsAnalyzerRegistry.Tests.ps1`. |
| U10 tier entry | PASS | `qa-existing-gates.2026-11-03T18-48.md`. |
| U11 no Python or TypeScript | PASS | `qa-no-python-typescript.2026-11-03T20-07.md`. |
| U12 discovery unchanged | PASS | `qa-discovery-scope.2026-11-03T20-07.md`. |
| U13 coverage and no temporary files | PASS | `qa-pester-coverage.2026-11-03T18-44.md`, `qa-hygiene-and-size.2026-11-03T20-08.md`. |
| U14 CI check | N/A | CI-dependent; pending [P6-T12]. |
| U15 analysis method | PASS | Three suites as for S27. |
| U16 declaration digest | PASS | As for S28. |
| U17 envelope contract | PASS | As for S29. |
| U18 audience identifiers | PASS | As for S30. |
| U19 1031 preconditions | PASS | `Invoke-DocsCommand.Tests.ps1`, `DocsSurface.Tests.ps1`. |

## Gaps and Items for the Orchestrator

1. [P6-T6] acceptance not met as written on the current host; task left unchecked. The full single-process `tests/scripts` run reports 409 failures and 6 `BeforeAll` errors, and Pester then fails to write the JUnit file (character 0x1B in a failure message). [P0-T6] was recorded on a different host with 0 failures. On the current host, the unchanged merge base also fails (249 in its own directory order; the remaining 160 `Resolve-CodexRouting.Parity.Tests.ps1` cases fail on the merge base when `tests/scripts/dev-tools` runs first, as in this worktree's directory order). All 194 unique failing names are pre-existing on this host, none is under `tests/scripts/claude-lib/docs/`, and none is in this branch's change set (`evidence/regression-testing/isolation-single-process.2026-11-03T20-06.md`, `evidence/remediation-baseline/same-host-mergebase-pester.2026-11-03T20-06.md`). The CI-shape evidence is `poshqc / PowerShell QC` on windows-latest ([P6-T12]). Pre-existing defects to file separately: a `tests/scripts/dev-tools` suite leaves state that makes `Get-Command pwsh -CommandType Application` fail in later suites on Linux; Linux-only `C:` and `/repo` fixture failures; JUnit export failure on ANSI escape characters in failure messages.
2. The seven `examples/docs/v1/` files are in artifact-header key order, which `scripts.dev_tools.format_json --check` reports as `would reformat` (governed glob `examples/**/*.json`; not a CI gate; the discovery examples are sorted). Changing the key order is outside this plan; recorded for the owner with the plan's existing `validate_json` note.
