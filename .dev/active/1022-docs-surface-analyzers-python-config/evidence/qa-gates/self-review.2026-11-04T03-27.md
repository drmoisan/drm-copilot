# Self-Review: Docs Surface Analyzers for Python and Configuration (Issue #1022)

Timestamp: 2026-11-04T03-27
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff MERGE_BASE` plus the untracked files of `git status --porcelain --untracked-files=all` (the [P6-T8] union), and against every AC in `FEATURE/spec.md` and `FEATURE/user-story.md`; supporting probes `sh SCRATCH/issue-1022-p6t14-probe.sh` (module-rule markers and suite structure) and searches of the new modules for case-insensitive string operators, `catch` blocks and module-scope assignments
EXIT_CODE: 0

- Feature folder: `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022` (`FEATURE`)
- Base: `MERGE_BASE` = `git merge-base origin/epic/documentation-estate-tooling-integration HEAD` (the 1020 merge on the integration branch); head: branch `feature/docs-surface-analyzers-python-config-1022-r2`, 11 commits since `MERGE_BASE` plus the uncommitted Phase 6 evidence and check-offs.
- Work mode: `full-feature`; AC sources: `FEATURE/spec.md` (25) and `FEATURE/user-story.md` (14).
- Languages in scope: PowerShell (18 new modules, 2 edited 1020 files, their 20 mirror copies, 19 new Pester suites), JSON (`core.json` edit, two corpus fixtures), Markdown (feature folder). Python, TypeScript, C# and Bash: no file written.

Row counts: 170 rows; PASS 133, N/A 37, FAIL 0.

## A. Policy audit template

### A1. General unit test policy: core principles

| # | Item | Status | Evidence |
|---|---|---|---|
| 1 | Independence | PASS | Three seeded shuffled file-order runs (seeds 1022, 4711, 90210) of the 21 touched suites pass 383/383 each (`isolation-shuffled.2026-11-04T03-10.md`); fresh single-process run over `tests/scripts` shows no failure under `tests/scripts/claude-lib/docs` (`isolation-fresh-run.2026-11-04T03-21.md`). |
| 2 | Isolation | PASS | One suite per module; diagnostic rows have one `It` each (spec S5); analyzers are driven through captured in-memory inputs. |
| 3 | Fast execution | PASS | 383 tests in about 100 s in one process, dominated by the seeded property loops; no test waits or sleeps. |
| 4 | Determinism | PASS | Fixed seeds through `[System.Random]::new($seed)` with the seed in `-Because`; fixed clock through the 1020 in-memory context; ordinal sorting; culture restored in `AfterAll`. |
| 5 | Readability and maintainability | PASS | `It` names state scenario and outcome; property tests are named `property: <Function> ...` (`property-census.2026-11-04T03-24.md`). |

### A2. Coverage and scenarios

| # | Item | Status | Evidence |
|---|---|---|---|
| 6 | Baseline coverage documented | PASS | `baseline-pester-coverage.2026-11-03T22-17.md`: overall 92.66%; registry 100%, entry script 87.33%; no 1022 module at baseline. |
| 7 | No coverage regression | PASS | `coverage-delta.2026-11-04T03-04.md`: overall 93.33%; registry 100%; entry script 87.42%. |
| 8 | New code coverage (template 90%; repository 85%) | PASS | Eighteen new modules 99.22% to 100%; changed lines of the two edited files 6/6 covered. |
| 9 | Comprehensive coverage (every new function tested) | PASS | 49 exported functions; 48 pure functions each have a property test; `Invoke-DocsInventoryCommand` covered by `DocsInventory.Tests.ps1` (100% line coverage). |
| 10 | Positive flows | PASS | Corpus-driven element assertions for the nine input families (S1, S2, S3, S4). |
| 11 | Negative flows | PASS | One test per `## Precision Limit` diagnostic row (S5); exit 2 usage errors (S14). |
| 12 | Edge cases | PASS | 1,048,576 and 1,048,577 byte inputs (S6); case-only name differences (S21); CRLF, CR and trailing-newline digest variants (S12). |
| 13 | Error handling | PASS | Exit 3 for read failure and exceeded aggregate bound with `DOCS_CLI_RUNTIME` (S14); undecodable and over-bound capture rows (in-test rows). |
| 14 | Concurrency | N/A | Pure, single-threaded analyzers; no concurrent code path. |
| 15 | State transitions | PASS | `-Write` create versus overwrite mode (S16); otherwise stateless. |
| 16 | Per-language coverage comparison (PowerShell) | PASS | Rows 6 to 8. Python, TypeScript, C#, Bash: N/A, no file written. |

### A3. Test structure and diagnostics

| # | Item | Status | Evidence |
|---|---|---|---|
| 17 | Clear failure messages | PASS | `-Because` text names the case and, for property tests, the seed. |
| 18 | Arrange-Act-Assert pattern | PASS | Inputs built, one function or command call, assertions. |
| 19 | Document intent | PASS | Suite header comments state the module under test and the isolation rules. |

### A4. External dependencies and environment

| # | Item | Status | Evidence |
|---|---|---|---|
| 20 | Avoid external dependencies | PASS | No process, network or git call in the new suites; command tests use the 1020 in-memory context. |
| 21 | Use mocks/stubs (no blanket mocks) | PASS | No `Mock` in the nineteen new suites (probe); a recording `ReadBytes` wrapper over the in-memory context (S9). |
| 22 | Environment stability (no temporary files) | PASS | `qa-test-hygiene.2026-11-04T03-23.md`: no purity-hook decision, no `TestDrive`; corpus files read in place; CR bytes 0. |

### A5. Policy audit requirement

| # | Item | Status | Evidence |
|---|---|---|---|
| 23 | Pre-submission review | PASS | This self-review; the formal feature review follows. |

### A6. General code change policy

| # | Item | Status | Evidence |
|---|---|---|---|
| 24 | Clarify the objective | PASS | Issue #1022; `FEATURE/spec.md` v0.4 and `user-story.md`. |
| 25 | Read existing change plans | PASS | Phase 0 reads (`phase0-instructions-read.2026-11-03T21-41.md`) and the 1020 dependency verification (`dependency-1020.*.md`). |
| 26 | Document the plan | PASS | `FEATURE/plan.2026-10-30T16-46.md`, check-offs on disk. |
| 27 | Simplicity first | PASS | Shared lexer, binding and key scanners reused by every analyzer; no module above 370 lines. |
| 28 | Reusability | PASS | `DocsSourceText.psm1` shared helpers (line ranges, diagnostic aggregation, unique selection) used by all analyzers. |
| 29 | Extensibility | PASS | Analyzers registered as rows under the 1022 anchor; later children add rows under their own anchors. |
| 30 | Separation of concerns | PASS | Only `DocsInventory.psm1` references the command context (S16); every analyzer is pure over captured text. |
| 31 | Cohesive modules | PASS | One module per scanner, per framework family and per analyzer; `DocsPythonBindings.psm1` split from `DocsPythonSyntax.psm1` under the 500-line rule. |
| 32 | At or below the 800-line hard limit | PASS | `qa-file-size.2026-11-04T03-23.md`: production maximum 370, test maximum 369; repository gate passes. |
| 33 | Public vs internal | PASS | `Export-ModuleMember` lists only the 49 documented functions; helpers are private. |
| 34 | No circular dependencies | PASS | Sibling imports flow from scanners to analyzers to the snapshot and command modules; each module imports siblings by literal `Join-Path` with `-ErrorAction Stop`. |
| 35 | Descriptive names | PASS | For example `Get-DocsPythonImportTable`, `Resolve-DocsHttpTemplate`, `Get-DocsInventoryBoundFinding`. |
| 36 | Docs/docstrings | PASS | Comment-based help on every function; each module help carries the sibling-import token (probe: 18 of 18). |
| 37 | Comment why, not what | PASS | Help text states decisions (for example why `ItemNotFoundException` means absent). |
| 38 | Formatting | PASS | `qa-poshqc-format.2026-11-04T02-36.md`: 0 `Formatted:` lines, status unchanged. |
| 39 | Linting | PASS | `qa-poshqc-analyze.2026-11-04T02-39.md`: 0 findings over 640 files. |
| 40 | Type checking | N/A | Not applicable to PowerShell. |
| 41 | Testing | PASS | `qa-pester-coverage.2026-11-04T03-04.md`: no failure outside the baseline list; all docs suites pass. |
| 42 | Full toolchain loop in a single pass | PASS | [P6-T1] to [P6-T12] completed in one pass with no file changed by a gate and no restart. |
| 43 | Explicit reporting | PASS | One artifact per gate under `FEATURE/evidence/`. |
| 44 | Summarize changes | PASS | Section D and the [P6-T8] scope artifact. |
| 45 | Design choices explained | PASS | Spec `## Decisions`, plan version notes (D-1022-exec-1). |
| 46 | Update supporting documents | N/A | No brief, README or rule fact changes (plan Pre-Mortem `Mirror parity`). |
| 47 | Provide next steps | PASS | S22 and U14 pending-CI at S9 (`ac-status.2026-11-04T03-26.md`). |

### A7. Python code change policy (3A)

| # | Item | Status | Evidence |
|---|---|---|---|
| 48 | Formatting with Black | N/A | No Python file written (`qa-scope`: 0 `.py` paths). |
| 49 | Linting with Ruff | N/A | Same. |
| 50 | Type checking with Pyright | N/A | Same. |
| 51 | Testing with Pytest | N/A | No Python change; the existing push-down contract tests pass (`qa-push-down-contracts.2026-11-04T03-22.md`). |
| 52 | Strong typing | N/A | No Python file. |
| 53 | Dataclasses for value objects | N/A | No Python file. |
| 54 | Protocols/ABCs for interfaces | N/A | No Python file. |
| 55 | Avoid utility classes | N/A | No Python file. |
| 56 | Specific exceptions | N/A | No Python file. |
| 57 | Logging over print | N/A | No Python file. |
| 58 | Invariants at construction | N/A | No Python file. |

### A8. PowerShell code change policy (3B)

| # | Item | Status | Evidence |
|---|---|---|---|
| 59 | Formatting with Invoke-Formatter | PASS | Row 38. |
| 60 | Linting with PSScriptAnalyzer | PASS | Row 39. |
| 61 | Fix all findings | PASS | 0 findings at baseline and after. |
| 62 | PowerShell 7+ compatible (repository rule `.claude/rules/powershell.md` `## Compatibility`) | PASS | Compatibility rules in the PSSA settings report no finding; the spec targets PowerShell 7.4. |
| 63 | Advanced functions | PASS | `[CmdletBinding()]` count equals the function count in every module (probe). |
| 64 | Parameter validation | PASS | `Mandatory`, `AllowNull`, `AllowEmptyCollection` attributes on parameters. |
| 65 | Avoid global state | PASS | No `global:` reference; every top-level `$script:` assignment is a constant (identifiers, limits, patterns) and no function assigns or mutates a `$script:` variable (search returned no match). |
| 66 | Error handling | PASS | One typed catch (`ItemNotFoundException` means absent) in `Read-DocsInventoryText`; the `DocsSourceText.psm1` catch rethrows every error except `DOCS_IDENTITY_INPUT_INVALID`, which becomes a `DECLARATION_INVALID` diagnostic; the command-level catch in `Invoke-DocsInventoryCommand` converts a runtime error into the specified exit 3 with `DOCS_CLI_RUNTIME` and the exception message as context (spec S14), so no error is discarded. |
| 67 | Cohesive and at or below the 800-line hard limit | PASS | Row 32. |
| 68 | Approved verbs | PASS | Get, Select, ConvertTo, ConvertFrom, Find, New, Add, Read, Split, Resolve, Test, Invoke; analyzer rule `PSUseApprovedVerbs` reports none. |
| 69 | Comment why | PASS | Row 37. |
| 70 | Step 1: Format | PASS | Row 38. |
| 71 | Step 2: Analyze | PASS | Row 39. |
| 72 | Step 3: Type check | N/A | Not applicable to PowerShell. |
| 73 | Step 4: Test | PASS | Row 41. |
| 74 | Rerun loop if needed | PASS | No restart was needed. |
| 75 | Case-sensitive comparisons on Python names (plan module rule) | PASS | String comparisons use `-ceq`, `-cne`, `-clike`, `-cmatch`, `-ccontains` and ordinal APIs. The one `-notmatch` (`DocsPythonTokens.psm1`, encoding-cookie check against `utf-8`, `utf8`, `utf_8`) compares an encoding name, which Python matches case-insensitively, not a Python identifier; `-split` patterns contain no letters. Case property test passes (S21). |
| 76 | No `&` call through a variable, member or expression | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 33/33 with an empty allowlist; context members are called through the 1020 `Invoke-DocsContextMember`. |

### A9. Bash script policy (3C)

| # | Item | Status | Evidence |
|---|---|---|---|
| 77 | Formatting with shfmt | N/A | No Bash file written. |
| 78 | Linting with shellcheck | N/A | Same. |
| 79 | Testing with bats | N/A | Same. |
| 80 | Portable shebang | N/A | Same. |
| 81 | Error handling | N/A | Same. |
| 82 | At or below the 800-line hard limit | N/A | Same. |

### A10. JSON configuration policy (3D)

| # | Item | Status | Evidence |
|---|---|---|---|
| 83 | Formatting with jq | N/A | `core.json` and `tests/**` fixtures are outside `GOVERNED_GLOBS` of `scripts/dev_tools/json_config.py`; `core.json` keeps its existing layout. |
| 84 | Schema validation | PASS | `core.json` is read by the manifest contract tests (pass); both corpus files parse through `ConvertFrom-DocsJsonText` with no finding ([P2-T1], [P2-T2]). |
| 85 | Required `$schema` | N/A | Not governed files. |
| 86 | Strict JSON only | PASS | Parsed by the 1020 strict JSON reader and by Python `json` in the contract tests. |
| 87 | Deterministic key order | PASS | New `core.json` entries appended in one block after the 1020 entries; corpus keys written in a fixed order; no CR byte. |

### A11. Python unit test policy (4A)

| # | Item | Status | Evidence |
|---|---|---|---|
| 88 | Use Pytest | N/A | No Python test added. |
| 89 | Coverage expectation | N/A | Same. |
| 90 | Focused unit tests | N/A | Same. |
| 91 | Mocking sparingly | N/A | Same. |
| 92 | Organization | N/A | Same. |
| 93 | Naming conventions | N/A | Same. |
| 94 | Docstrings/comments | N/A | Same. |
| 95 | Use Pytest (toolchain) | N/A | Same. |
| 96 | No alternative test runners (Python) | N/A | Same. |

### A12. PowerShell unit test policy (4B)

| # | Item | Status | Evidence |
|---|---|---|---|
| 97 | Use Pester v5.x | PASS | `Describe`/`Context`/`It`, `BeforeAll`/`AfterAll`, `-ForEach`. |
| 98 | Use PoshQC configuration | PASS | Runs use `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| 99 | PowerShell 7+ compatible | PASS | Row 62. |
| 100 | Focused unit tests | PASS | Row 2. |
| 101 | Test behavior over implementation | PASS | Assertions on emitted elements, diagnostics, exit codes and envelope validity. |
| 102 | Mocking used sparingly | PASS | No `Mock` in the new suites. |
| 103 | Organization mirrors code location | PASS | `tests/scripts/claude-lib/docs/<Module>.Tests.ps1` for `.claude/lib/docs/<Module>.psm1`. |
| 104 | File naming `*.Tests.ps1` | PASS | All nineteen new suites. |
| 105 | Describe/Context/It structure | PASS | Every new suite has at least one `Describe` (probe). |
| 106 | Logical grouping | PASS | Grouped by function and by diagnostic table. |
| 107 | Docstrings/comments | PASS | Row 19. |
| 108 | Use PoshQC test command | PASS | Full runs through `Invoke-PoshQCTest` ([P6-T3], [P6-T6]). |
| 109 | No alternative test runners | PASS | Only Pester. The suite-level and shuffled runs call `Invoke-Pester` with the PoshQC runsettings, because `Invoke-PoshQCTest` sorts its scan folders and would undo the seeded file order. |
| 110 | Module cleanup and culture restoration | PASS | Every new suite has `AfterAll` with `Remove-Module` (probe); seeded shuffles find no order dependence. |

### A13. Test coverage detail, execution metrics, quality checks, gaps

| # | Item | Status | Evidence |
|---|---|---|---|
| 111 | Test coverage detail per function | PASS | `property-census.2026-11-04T03-24.md`, `coverage-delta.2026-11-04T03-04.md`. |
| 112 | Total tests / passed / failed | PASS | Touched suites 383/383/0; `tests/scripts` 14433 discovered, 14014 passed, 409 failed (all in the baseline list), 10 skipped. |
| 113 | Execution time | PASS | Touched suites about 100 s; full run 1360.7 s with coverage and 594.3 s without. |
| 114 | Test file size | PASS | All test files at most 369 lines. |
| 115 | Code quality checks table | PASS | Format, analyze and test rows above. |
| 116 | Pre-existing failures documented | PASS | 97-line failing list in the [P0-T6] baseline, identical after the change; owned by #1066/#1067. |
| 117 | Identified gaps | PASS | None locally; S22 and U14 wait for the CI shard jobs. |
| 118 | Approved exceptions | N/A | No exception taken. |
| 119 | Removed or skipped tests | N/A | None removed or skipped; the 10 skips are pre-existing. |
| 120 | Temporary artifacts cleanup | PASS | Helper scripts exist only under `SCRATCH`; none added to the repository. |

## B. Code review template

| # | Item | Status | Evidence |
|---|---|---|---|
| 121 | Findings table: Blocker or Major findings | PASS | None found. |
| 122 | PowerShell: what changed well | PASS | The 1020 files change only by the six anchored lines (numstat 5/0 and 1/0); every 1020 test is unedited and passes. |
| 123 | PowerShell: API and safety notes | PASS | Every element is built through 1020 `New-DocsSurfaceElement`; no 1022 module computes a digest; every diagnostic code follows `^[A-Z][A-Z0-9_]*$`. |
| 124 | PowerShell: error handling and logging | PASS | Row 66; findings carry code, message and next action through 1020 builders. |
| 125 | Test quality: determinism, isolation, speed, diagnostics | PASS | Rows 1 to 4 and 17. |
| 126 | Security: no secrets in code | PASS | No token or credential; configuration values never reach the snapshot (S8 marker property). |
| 127 | Security: no unsafe command construction | PASS | No interpreter invocation or `Invoke-Expression`; row 76. |
| 128 | Security: input validation at boundaries | PASS | Relative `-Profile`, full-object-id `-Revision`, registered `-Analyzer` checked before any read; per-file and aggregate byte bounds. |
| 129 | Security: error handling explicit | PASS | Row 66. |
| 130 | Security: configuration and path handling | PASS | Plain `.env` files are never read (S9); only the four template names produce `config-key` elements. |
| 131 | Research log | N/A | No external source fetched in this execution; planning notes record the framework-rule comparison. |

## C. Feature audit template: spec.md acceptance criteria

| # | AC | Status | Evidence |
|---|---|---|---|
| 132 | S1 Five analyzers emit the expected elements for the nine input families from both corpora | PASS | Analyzer suites read both corpora in place; pass in [P6-T3], [P6-T5], [P6-T6]. |
| 133 | S2 `python-cli` argparse, Click, Typer and console-script forms | PASS | `DocsPythonCliArgparse`, `DocsPythonCliClick`, `DocsPythonCliTyper`, `DocsAnalyzerPythonCli` suites pass. |
| 134 | S3 `python-http` prefixes and the `<dynamic>` segment | PASS | `DocsPythonHttpSites` and `DocsAnalyzerPythonHttp` suites pass. |
| 135 | S4 `python-public-api` and `python-architecture` forms | PASS | `DocsAnalyzerPythonApi` and `DocsAnalyzerArchitecture` suites pass. |
| 136 | S5 Every `## Precision Limit` diagnostic row has its test | PASS | Per-row tests pass; `python-corpus-census.2026-11-03T23-49.md` (32 codes, four in-test rows). |
| 137 | S6 Size bound and unclassifiable input | PASS | Bound and `PYTHON_LEXER_UNCLASSIFIED` tests pass. |
| 138 | S7 Byte-identical rerun under permuted `ListFile` | PASS | `DocsInventoryProperties.Tests.ps1` seeded property passes under three shuffles. |
| 139 | S8 No configuration value exported | PASS | Marker-value property passes. |
| 140 | S9 Non-template env files never read | PASS | Recording `ReadBytes` wrapper test passes. |
| 141 | S10 Snapshot validates; input digests and sizes | PASS | `Test-DocsArtifactText` and input digest tests pass. |
| 142 | S11 `analysis_method: scanner` and the registry method field | PASS | Registration and property tests pass. |
| 143 | S12 Digest contract and digest properties | PASS | Digest properties against `Get-DocsDeclarationSha256` pass. |
| 144 | S13 Independent golden values and corpus coverage | PASS | `golden-vectors.2026-11-03T23-55.md` (D1 self-check); corpus census. |
| 145 | S14 Command exit codes 0 to 3 | PASS | `DocsInventory.Tests.ps1` and `Invoke-DocsCommand.Tests.ps1` pass. |
| 146 | S15 `-Json` envelope validation on every exit path | PASS | Envelope tests through `ENVELOPE_ROUTE` pass. |
| 147 | S16 Write behavior and the single context-referencing module | PASS | Write and context-reference tests pass. |
| 148 | S17 Anchored rows only; registration checks return no finding | PASS | `qa-scope.2026-11-04T03-22.md`; `p4-registry-rows.2026-11-04T01-18.md`; `p4-dispatch-row.2026-11-04T01-45.md`. |
| 149 | S18 Mirror, manifests and contract tests | PASS | `bundle-mirror.2026-11-04T01-53.md`; `qa-push-down-contracts.2026-11-04T03-22.md`. |
| 150 | S19 No interpreter invocation or `&` through a variable | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` 33/33 with an empty allowlist. |
| 151 | S20 Property test per pure exported function | PASS | `property-census.2026-11-04T03-24.md` (48 of 48). |
| 152 | S21 Case-distinct names and ordinal ordering across cultures | PASS | Case and culture property passes. |
| 153 | S22 Per-file coverage at least 85% from the CI shard jobs | N/A | Pending-CI; local values 99.22% to 100% (`coverage-delta.2026-11-04T03-04.md`); left unchecked for S9. |
| 154 | S23 No temporary files; CR only as escapes; production files below 500 lines | PASS | `qa-test-hygiene.2026-11-04T03-23.md`; `qa-file-size.2026-11-04T03-23.md`. |
| 155 | S24 Classification table and no forbidden file classes | PASS | `qa-scope.2026-11-04T03-22.md`. |
| 156 | S25 Phase 0 dependency evidence | PASS | `dependency-1020.2026-11-03T21-45.md` and its addendum `dependency-1020.2026-11-03T22-40.md`. |

## D. Feature audit template: user-story.md acceptance criteria

| # | AC | Status | Evidence |
|---|---|---|---|
| 157 | U1 Expected elements for the nine input families | PASS | As row 132. |
| 158 | U2 Typer default and explicit names; console-script root | PASS | As row 133. |
| 159 | U3 `<dynamic>` prefix and named diagnostics | PASS | As rows 134 and 136. |
| 160 | U4 Size bound and unclassifiable input | PASS | As row 137. |
| 161 | U5 Byte-identical rerun | PASS | As row 138. |
| 162 | U6 No configuration value; plain `.env` not read | PASS | As rows 139 and 140. |
| 163 | U7 Snapshot validates with input digests and sizes | PASS | As row 141. |
| 164 | U8 `analysis_method: scanner` | PASS | As row 142. |
| 165 | U9 Digest changes only for in-range edits | PASS | As row 143. |
| 166 | U10 Exit codes and envelope validation | PASS | As rows 145 and 146. |
| 167 | U11 Write behavior | PASS | As row 147. |
| 168 | U12 Anchored registration, mirror copies and `core.json` | PASS | As rows 148 and 149. |
| 169 | U13 No interpreter invocation; no forbidden file classes | PASS | As rows 150 and 155. |
| 170 | U14 Per-file coverage measured by the CI shard jobs | N/A | Pending-CI, as row 153; left unchecked for S9. |

Output Summary: 170 rows; PASS 133, N/A 37, FAIL 0. No Blocker or Major finding. 24 of 25 spec ACs and 13 of 14 user-story ACs verified and checked; S22 and U14 pending CI at S9.
