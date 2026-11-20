# QA Gate: Self-Review — Issue #1093

Timestamp: 2026-11-07T01-34
Command: walk of `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`, `code-review.yyyy-MM-ddTHH-mm.md` and `feature-audit.yyyy-MM-ddTHH-mm.md` against `git diff --find-renames --name-status <merge base of origin/main and HEAD>..HEAD` plus the uncommitted forwarder `.NOTES` edit of P6-T13
EXIT_CODE: 0
Output Summary: one PASS, FAIL or N/A row per checklist item; no FAIL row remains. The first walk found one FAIL (new directory-creation and state-write lines in `Write-EpicProgressState` uncovered); it was fixed with two mocked entry-suite cases and the QA loop was re-run (format, analyze, coverage, shuffles, single-process, concurrent shards, contract tests); this artifact is the rewritten self-review.

Scope: 52 changed paths (scope-diff `evidence/qa-gates/scope-diff.2026-11-07T00-59.md`; the P6-T13 edits change only `scripts/dev-tools/Get-EpicProgressReport.ps1` and `tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1`, both already in that list). Languages: PowerShell, Markdown, JSON. No Python, TypeScript, C#, or Bash file changed.

## Policy audit template

### Language summary and coverage evidence

| Item | Status | Evidence |
|---|---|---|
| Python row | N/A | no Python file changed |
| PowerShell row | PASS | 14 PowerShell files plus 5 bundle copies; touched suites 163 passed 0 failed; baseline entry 91.18% / Logic 100%; post-change entry 90.82%, Logic, State, Metrics, Render, forwarder 100% (`qa-gates/coverage-delta.2026-11-07T01-04.md`) |
| Bash row | N/A | no shell file changed |
| JSON row | PASS | `core.json` and `config/poshqc-coverage.json` parse (P5-T2, P5-T6) |
| Coverage evidence checklist | PASS | baseline `baseline/pester-coverage.2026-11-06T23-56.md`, post-change `qa-gates/pester-coverage.2026-11-07T01-04.md`, delta `qa-gates/coverage-delta.2026-11-07T01-04.md`, all numeric |

### 1. General unit test policy

| Item | Status | Evidence |
|---|---|---|
| Independence | PASS | seeded shuffled file order, seeds 7, 41, 1093, 0 failures (`regression-testing/pester-shuffled-order.2026-11-07T01-04.md`); per-test fixtures in `BeforeEach`; `$global:LASTEXITCODE` saved and restored in the forwarder suite |
| Isolation | PASS | one behavior per `It`; suites split by production file (State, Metrics, Render, Logic, entry, forwarder, skill contract) |
| Fast execution | PASS | the seven touched suites run in a few seconds in one process; the full single-process run (1286 s) is dominated by unrelated suites |
| Determinism | PASS | fixed epoch values, mocked clock seam, no network, no wall clock; child-process cases fail parameter validation before any I/O |
| Readability and maintainability | PASS | descriptive `It` names, comments on non-obvious mocks (dynamic scoping of mock filters) |
| Baseline coverage documented | PASS | `baseline/pester-coverage.2026-11-06T23-56.md` written before any edit |
| No coverage regression | PASS | entry 91.18% to 90.82% with the same kinds of uncovered lines (native wrappers, clock read, entry block); no line covered at the baseline is uncovered; moved Logic functions remain 100% |
| New code coverage at or above 90% | PASS | new files State 100%, Metrics 100%, Render 100%; changed entry 90.82%; forwarder 100% |
| Comprehensive coverage | PASS | every new function has named cases (`ConvertFrom-EpicProgressStateText`, `ConvertTo-EpicProgressStateJson`, `Resolve-EpicProgressBaseline`, `Merge-EpicProgressSamplePair`); uncovered entry lines are I/O wrappers and the entry block |
| Positive flows | PASS | version-1 read, stored start, reset, pairing, Full golden, normal forwarder run |
| Negative flows | PASS | unparseable and unknown-version state, missing start throws, combined switches throw, forwarder validation failures |
| Edge cases | PASS | 0, 1, 2, 13, 14 samples; exactly 2 intervals; zero-rate intervals; before first task |
| Error handling | PASS | throw messages asserted (`-StartUtc` and `-ResetBaseline`; `-ResetBaseline` and `-PairSamples`); forwarder exit codes 1, 3, 0 |
| Concurrency | N/A | no concurrent code; concurrent-shard run passes (`regression-testing/pester-parallel-shards.2026-11-07T01-33.md`) |
| State transitions | PASS | state document transitions covered: empty to first sample, legacy to version-1, reset, pairing, 90-second no-write |
| Clear failure messages | PASS | `-Because` texts on fragment, path and scan assertions |
| Arrange-Act-Assert | PASS | tests separate setup, call and assertions |
| Document intent | PASS | file header comments state scope and isolation approach |
| Avoid external dependencies | PASS | no network; git, gh, cswap reached only through mocked wrappers; the only child processes are the current PowerShell executable in the forwarder and fixture cases specified by P4-T2 |
| Use mocks or stubs | PASS | wrapper seams mocked; `Join-Path` mocked with a parameter filter for the forwarder target; `New-Item` and `Set-Content` mocked for the state-write cases |
| Environment stability | PASS | no temporary files; the `check-powershell-test-purity.ps1` hook admitted every test file write; nothing is written by any test |
| Pre-submission review | PASS | this artifact |

### 2. General code change policy

| Item | Status | Evidence |
|---|---|---|
| Clarify the objective | PASS | `spec.md` Overview and DEC-1 to DEC-11 |
| Read existing change plans | PASS | plan `plan.2026-11-06T17-53.md`, preflight fixes record |
| Document the plan | PASS | plan checked off task by task with one commit per task |
| Simplicity first | PASS | forwarder of five statements; pure functions for state, baseline and pairing |
| Reusability | PASS | existing `Select-EpicProgressSample`, interval and SD functions reused by the pairing example and the entry wiring |
| Extensibility | PASS | versioned state document (`version` 1) with tolerant reader |
| Separation of concerns | PASS | pure State, Metrics, Render, hub files; I/O only in the entry seams |
| Cohesive modules | PASS | split by concern per DEC-5 |
| At or below the 800-line hard limit | PASS | largest file 563 lines (entry suite); every file below 700 (`qa-gates/file-size.2026-11-07T01-05.md`) |
| Public vs internal | PASS | the skill invokes only the canonical entry; consumers dot-source the hub |
| No circular dependencies | PASS | entry dot-sources the hub; the hub dot-sources State, Metrics, Render; none dot-sources back |
| Descriptive names | PASS | approved verbs, `EpicProgress` noun prefix |
| Docs and docstrings | PASS | comment-based help on every function and on both scripts; 15 parameters documented |
| Comment why, not what | PASS | comments explain the reset sample discard, pairing timing, state read before git |
| 1. Formatting | PASS | `qa-gates/powershell-format.2026-11-07T01-02.md`, 14 `Already formatted:` lines |
| 2. Linting | PASS | `qa-gates/powershell-analyze.2026-11-07T01-02.md`, 0 findings over 19 files |
| 3. Type checking | N/A | PowerShell has no type-check stage |
| 4. Testing | PASS | `qa-gates/pester-coverage.2026-11-07T01-04.md` 0 failures |
| Full toolchain loop | PASS | two passes; pass 2 after the self-review fix completed with no failure and no file change by the formatter |
| Explicit reporting | PASS | every gate recorded under `evidence/` |
| Summarize changes | PASS | commit messages per task |
| Design choices explained | PASS | spec DEC-1 (settled forwarder), OQ-1 resolved |
| Update supporting documents | PASS | `spec.md` DEC-1, R1, AC-10, Test Inventory, OQ-1; `extensions/drm-copilot/CHANGELOG.md` |
| Provide next steps | PASS | pending-CI criteria listed in `qa-gates/ac-verification.2026-11-07T01-35.md` |

### 3B. PowerShell code change policy

| Item | Status | Evidence |
|---|---|---|
| Formatting with Invoke-Formatter | PASS | as 1. Formatting |
| Linting with PSScriptAnalyzer | PASS | as 2. Linting |
| Fix all findings | PASS | no findings |
| PowerShell 5.1 and 7.6+ compatible | PASS | repository requires PowerShell 7; the canonical scripts already used PowerShell 7 features (`Test-Json`, `-AdditionalChildPath`) at the merge base |
| Advanced functions | PASS | `[CmdletBinding()]` and typed parameters on every new function |
| Parameter validation | PASS | `ValidateRange` and `ValidateSet` kept; mandatory `State` and `NowUtc` on `Resolve-EpicProgressBaseline` |
| Avoid global state | PASS | the forwarder's `$global:LASTEXITCODE = 0` is the settled design (spec DEC-1); no other global |
| Error handling | PASS | `throw` with actionable messages; no catch-alls |
| Cohesive and at or below the 800-line hard limit | PASS | as above |
| Approved verbs | PASS | ConvertFrom, ConvertTo, Resolve, Merge, Get, Format, Invoke, Read, Write, Test |
| Comment why | PASS | as above |
| Step 1 Format | PASS | as above |
| Step 2 Analyze | PASS | as above |
| Step 3 Type check | N/A | not applicable for PowerShell |
| Step 4 Test | PASS | as above |
| Rerun loop if needed | PASS | rerun once after the self-review fix |

### 3A, 3C, 3D, 4A

| Item | Status | Evidence |
|---|---|---|
| Section 3A Python code change | N/A | no Python change |
| Section 3C Bash script policy | N/A | no shell script change |
| Section 3D JSON configuration policy (jq formatting, schema, `$schema`, strict JSON, key order) | N/A | `core.json` and `config/poshqc-coverage.json` are not governed JSON files under that section; both keep their existing formatting and order, and both parse |
| Section 4A Python unit test | N/A | no Python test change; contract modules run unchanged (106 passed) |

### 4B. PowerShell unit test policy

| Item | Status | Evidence |
|---|---|---|
| Use Pester | PASS | Pester 6.2.0 through the branch PoshQC module |
| Use PoshQC configuration | PASS | `Invoke-PoshQCTest` with the module settings |
| PowerShell compatible | PASS | as 3B |
| Focused unit tests | PASS | as 1. Isolation |
| Test behavior over implementation | PASS | outputs, written documents and exit codes asserted; AST checks only where the spec requires (forwarder shape, constraints) |
| Mocking used sparingly | PASS | only I/O seams, `Join-Path` for the forwarder target, and file cmdlets in two cases |
| Organization | PASS | suites mirror production paths (`tests/scripts/claude-skills/epic-progress-report/` for `.claude/skills/epic-progress-report/scripts/`; `tests/scripts/dev-tools/` for the forwarder) |
| File naming | PASS | `*.Tests.ps1`; fixture `*.Fixture.ps1` under `tests/fixtures/` |
| Describe/Context/It structure | PASS | Describe per function group, Context for mocked state writes and non-finite values |
| Logical grouping | PASS | as above |
| Docstrings and comments | PASS | header comments per suite |
| Use PoshQCTest command | PASS | as above |
| No alternative test runners | PASS | Pester only; the scratch runners call `Invoke-Pester` for shuffles as the brief requires |

### 5 to 10

| Item | Status | Evidence |
|---|---|---|
| 5. Test coverage detail | PASS | per-function cases listed in `qa-gates/ac-verification.2026-11-07T01-35.md` |
| 6. Test execution metrics | PASS | 163 touched cases pass; largest test file 563 lines |
| 7. Code quality checks (PowerShell rows) | PASS | format, analyze, test recorded |
| 7. Code quality checks (Python rows) | N/A | no Python change |
| 8. Gaps and exceptions | PASS | gaps: AC-12, AC-30, AC-31, US-AC-11, US-AC-15 pending CI; no removed or skipped test |
| 9. Summary of changes | PASS | 52 paths in the scope diff |
| 10. Compliance verdict | PASS | compliant locally; CI-dependent criteria pending |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings table | PASS | one Blocker-level finding in the first walk (uncovered new state-write lines), fixed; no open finding |
| Python implementation audit | N/A | no Python change |
| TypeScript implementation audit | N/A | no TypeScript change |
| PowerShell implementation audit: what changed well | PASS | verbatim function moves (`R100` renames, unchanged golden strings); pure state functions |
| PowerShell implementation audit: API and safety notes | PASS | `-StartUtc` optional with explicit resolution order; switches documented; combined switches rejected before I/O |
| PowerShell implementation audit: error handling and logging | PASS | terminating errors with actionable text; forwarder maps failures to exit 1 |
| C# implementation audit | N/A | no C# change |
| Test quality audit: reviewed artifacts | PASS | coverage, shuffles, single-process, shards, contract tests |
| Determinism prompt | PASS | as 1. Determinism |
| Isolation prompt | PASS | as 1. Isolation |
| Speed prompt | PASS | as 1. Fast execution |
| Diagnostics prompt | PASS | as 1. Clear failure messages |
| No secrets in code | PASS | no token, account name or host path; hardcoded-value scan over seven paths |
| No unsafe subprocess or command construction | PASS | native calls only inside the three wrappers (`confines native commands to their wrappers`); the forwarder passes `@args` to a fixed path |
| Input validation at boundaries | PASS | parameter validation attributes; tolerant state reader |
| Error handling remains explicit | PASS | as above |
| Configuration and path handling is safe | PASS | `Join-Path` for every path; default state under the gitignored `.claude/state/` |
| Research log | PASS | `research/research.2026-11-06.md` |
| Verdict | PASS | approve locally; CI pending |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | merge base of `origin/main` and `HEAD`; feature folder `docs/features/active/2026-11-06-epic-progress-report-skill-1093`; work mode full-feature |
| Acceptance criteria inventory | PASS | `spec.md` AC-01 to AC-31, `user-story.md` US-AC-01 to US-AC-15 (46) |
| Acceptance criteria evaluation | PASS | 41 PASS, 5 UNVERIFIED pending CI, 0 FAIL (`qa-gates/ac-verification.2026-11-07T01-35.md`) |
| Summary | PASS | as above |
| Acceptance criteria check-off | PASS | 28 checked and 3 unchecked in `spec.md`; 13 checked and 2 unchecked in `user-story.md` |
| AC status summary | PASS | recorded in the AC verification artifact |

Final-head check (performed after the commit that carries this artifact): `git diff --name-only HEAD~1 HEAD` lists `scripts/dev-tools/Get-EpicProgressReport.ps1`, and `git status --porcelain` is empty.
