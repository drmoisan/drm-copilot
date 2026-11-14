# Self-Review - Issue #1096 (pester-static-leak-scan)

Timestamp: 2026-11-07T15-47
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff --name-status from the merge base of origin/main and HEAD and the evidence under this feature folder
EXIT_CODE: 0
Output Summary: Every checklist item is PASS or N/A. The first walk found two items that did not hold: the Python commenting rule (nested test fakes without docstrings and one loop without an intent comment) and Windows PowerShell 5.1 compatibility of the allowlist version check (ConvertFrom-Json yields Int32 on 5.1). Both were fixed, and the QA loop re-ran from P6-T1 twice; the third pass is the evidence of record.

## Owner Report Items

- Decision 1 (policy files are not edited): `.claude/rules/`, `.github/instructions/`, their bundle copies, `.agents/skills/powershell`, and `.agents/skills/python` are unchanged (scope-check). Those files still name a command that runs in one process; removing it needs a separate owner-authorized change.
- Decision 2 (`$global:LASTEXITCODE` exemption): `config/poshqc-leak-allowlist.json` holds one `exemptGlobalVariables` entry, `LASTEXITCODE`, with the Decision 2 reason. EXEMPT-COUNT: 67 (raw findings exempted by it in the first scan, across the files listed in evidence/baseline/leak-scan-raw.2026-11-07T14-35.md).
- Decision 3 (proof by construction): the three named tests keep their titles, read and change no process directory, and pass in the parallel gate; no before-and-after reproduction is claimed.
- Leak-scan counts: raw findings 71; fixed 2 (class T); allowlisted 2 (class C2); exempt 67 (class C1).

## Self-Review History

- First walk: Python `Docs/docstrings` and `Docstrings/comments` did not hold for nested fakes added in `test_qc_runner.py`, `test_cli_part3.py`, and `test_cli_part2_part2.py`, and for one loop in `test_plan_discovery.py`. Fixed in two commits; the `test_qc_runner.py` and `test_cli_part3.py` edits sit inside ledger Current fences, so those fences were corrected in the same `reduction: 0001` commit and the fence replay was repeated (evidence/other/ledger-fence-replay.2026-11-07T15-26.md, 27 of 27 OK).
- Second walk: `PowerShell 5.1 & 7.6+ compatible` did not hold for `ConvertFrom-PoshQCLeakAllowlist`, which required an Int64 version. Fixed to accept Int32 or Int64; verified under Windows PowerShell 5.1 (Int32 version accepted, repository scan result identical to PowerShell 7).

## Policy Audit Template

| Item | Status | Evidence |
|---|---|---|
| Coverage Evidence Checklist: PowerShell post-change coverage artifact | PASS | qa-gates/pester-parallel (third pass), qa-gates/coverage-thresholds (third pass) |
| Coverage Evidence Checklist: TypeScript post-change coverage artifact | N/A | No TypeScript source changes; Jest ran as a gate because bundled resources changed (qa-gates/jest) |
| Coverage Evidence Checklist: per-language comparison summary | PASS | qa-gates/coverage-thresholds COVERAGE-DELTA rows (owner Decision 9 baseline) |
| 1.1 Independence | PASS | Tests use in-memory text and injected seams; P3 fixes remove the global helper, env clearing, and process-directory dependence |
| 1.1 Isolation | PASS | One behavior per It/test; tagged LS-K, LS-R, LA-, LI-, VT- cases |
| 1.1 Fast Execution | PASS | New suites parse in-memory text only; the Pester gate ran 14825 testcases in about 5.3 minutes across 8 shards |
| 1.1 Determinism | PASS | No clock, network, or filesystem reads in new tests; seams return fixed text |
| 1.1 Readability & Maintainability | PASS | Arrange/Act/Assert comments; inline -ForEach tables with labels |
| 1.2 Changed Files Meet Thresholds | PASS | coverage-thresholds: every listed file at or above 85% line, Python at or above 75% branch |
| 1.2 New Code Coverage at or above 90% | PASS | PoshQC.LeakScan.psm1 98.22%, PoshQC.LeakAllowlist.psm1 95.40%; changed Python modules 93.2% to 100% line |
| 1.2 Comprehensive Coverage | PASS | Every Detected kinds form and rules R1 to R5 have cases |
| 1.2 Positive Flows | PASS | LS-R01, LA-01, LI-01 |
| 1.2 Negative Flows | PASS | LS-R03, LA-03 (14 conditions), LI-02 to LI-05 |
| 1.2 Edge Cases | PASS | LS-K02 (strings, Mock-named commands), LS-R06 (consumed restore), LI-07 and LI-08 (folder filtering) |
| 1.2 Error Handling | PASS | LS-R04 parse error, LI-03, LI-11 (config throw reaches caller) |
| 1.2 Concurrency | N/A | No concurrent code paths added |
| 1.2 State Transitions | N/A | No stateful component added |
| 1.3 Clear Failure Messages | PASS | Should -Because texts and assert messages name the input |
| 1.3 Arrange-Act-Assert Pattern | PASS | Section comments in new Pester and pytest cases |
| 1.3 Document Intent | PASS | Test names and docstrings state the scenario |
| 1.4 Avoid External Dependencies | PASS | No network, no live executables; subprocess and shutil.which stubbed |
| 1.4 Use Mocks/Stubs | PASS | Injected seams; Mock of Get-PoshQCScanConfigFolder inside InModuleScope |
| 1.4 Environment Stability | PASS | No temporary files; batch-budget suites restore environment snapshots |
| 1.5 Pre-submission Review | PASS | This artifact |
| 2.1 Clarify the objective | PASS | spec.md and plan |
| 2.1 Read existing change plans | PASS | Plan executed task by task |
| 2.1 Document the plan | PASS | plan.2026-11-07T02-06.md |
| 2.2 Simplicity first | PASS | Pure AST core plus one I/O entry point |
| 2.2 Reusability | PASS | Shared argument binding and region-restore helpers |
| 2.2 Extensibility | PASS | Allowlist versioned; kinds table in one place |
| 2.2 Separation of concerns | PASS | Get-PoshQCLeakFinding has no I/O; Invoke-PoshQCLeakScan holds all reads |
| 2.3 Cohesive modules | PASS | LeakScan (detection, pairing) and LeakAllowlist (validation, comparison, entry point) |
| 2.3 At or below the 800-line hard limit | PASS | Largest changed file test_qc_runner.py at 711 lines; Warning in the code review table (700-line advisory tier) |
| 2.3 Public vs internal | PASS | Only Invoke-PoshQCLeakScan is exported |
| 2.3 No circular dependencies | PASS | Sub-modules dot-sourced in order; no cross-imports |
| 2.4 Descriptive names | PASS | Verb-noun names with the PoshQCLeak prefix |
| 2.4 Docs/docstrings | PASS | After the first-walk fix, every new Python function has a docstring; public PowerShell functions carry comment-based help |
| 2.4 Comment why, not what | PASS | Comments state rules and reasons |
| 2.5 Formatting | PASS | qa-gates/powershell-format and python-black (third pass) |
| 2.5 Linting | PASS | qa-gates/powershell-analyze and python-ruff (third pass) |
| 2.5 Type checking | PASS | qa-gates/python-pyright (third pass), with the worktree environment note |
| 2.5 Testing | PASS | qa-gates/pester-parallel, pytest-parallel, jest |
| 2.5 Full toolchain loop | PASS | Loop re-run from P6-T1 after each fix |
| 2.5 Explicit reporting | PASS | Evidence artifacts carry Timestamp, Command, EXIT_CODE, Output Summary |
| 2.6 Summarize changes | PASS | Final executor report |
| 2.6 Design choices explained | PASS | Module headers; classification artifact |
| 2.6 Update supporting documents | PASS | PoshQC README, execution-environment brief (six copies), ledger entry 0001 |
| 2.6 Provide next steps | PASS | CI-dependent criteria left for the orchestrator |
| 3A Formatting with Black | PASS | python-black |
| 3A Linting with Ruff | PASS | python-ruff |
| 3A Type checking with Pyright | PASS | python-pyright |
| 3A Testing with Pytest | PASS | pytest-parallel |
| 3A Strong typing | PASS | Typed helpers; no Any |
| 3A Dataclasses for value objects | N/A | No value object added |
| 3A Protocols/ABCs for interfaces | N/A | No interface added |
| 3A Avoid utility classes | PASS | Module-level helpers only |
| 3A Specific exceptions | N/A | No new production exception paths in Python |
| 3A Logging over print | N/A | No logging added |
| 3A Invariants at construction | N/A | No constructor added |
| 3B Formatting with Invoke-Formatter | PASS | powershell-format |
| 3B Linting with PSScriptAnalyzer | PASS | powershell-analyze: 0 findings |
| 3B Fix all findings | PASS | Mixed OutputType finding fixed during P1-T1 |
| 3B PowerShell 5.1 & 7.6+ compatible | PASS | After the second-walk fix; repository scan under 5.1 matches 7 |
| 3B Advanced functions | PASS | CmdletBinding on every function |
| 3B Parameter validation | PASS | Mandatory and AllowEmpty attributes |
| 3B Avoid global state | PASS | Script-scope constants only; DrmCopilotPromptSupport gains a seam, not state |
| 3B Error handling | PASS | throw with named file and path |
| 3B Cohesive and at or below the 800-line hard limit | PASS | LeakScan 497 lines, LeakAllowlist 212 lines |
| 3B Approved verbs | PASS | Get, Test, ConvertFrom, Compare, Resolve, Invoke |
| 3B Comment why | PASS | Rule comments in both modules |
| 3B Step 1 to Step 4 and rerun loop | PASS | Format, analyze, Pester gate; type check not applicable to PowerShell |
| 3C Bash items | N/A | No bash changes |
| 3D Formatting with jq | N/A | No jq in the toolchain; allowlist parsed and validated by ConvertFrom-PoshQCLeakAllowlist |
| 3D Schema validation | PASS | Allowlist validated by ConvertFrom-PoshQCLeakAllowlist (LA-03) |
| 3D Required $schema | N/A | No JSON policy file exists; the poshqc-* config files carry no $schema |
| 3D Strict JSON only | PASS | Allowlist is plain JSON |
| 3D Deterministic key order | PASS | Fixed key order version, exemptGlobalVariables, entries |
| 4A Use Pytest; no alternative runners | PASS | pytest only |
| 4A Coverage expectation | PASS | coverage-thresholds |
| 4A Focused unit tests | PASS | One behavior per test |
| 4A Mocking sparingly | PASS | Stubs limited to subprocess and PATH lookup |
| 4A Organization | PASS | Cases in existing files that mirror the modules |
| 4A Naming conventions | PASS | test_ names describe behavior |
| 4A Docstrings/comments | PASS | After the first-walk fix |
| 4B Use Pester; PoshQC configuration | PASS | Invoke-PoshQCParallelTest gate |
| 4B Focused unit tests; behavior over implementation | PASS | Findings asserted, not internals |
| 4B Mocking used sparingly | PASS | One Mock, in LI-09 to LI-11 |
| 4B Organization; file naming *.Tests.ps1 | PASS | tests/scripts/powershell/PoshQC and tests/scripts/workflows |
| 4B Describe/Context/It structure; logical grouping | PASS | Describe per function |
| 4B Docstrings/comments | PASS | Header comments in new test files |
| 4B Use PoshQCTest command; no alternative runners | PASS | Gate through Invoke-PoshQCParallelTest |
| 5 Test coverage detail | PASS | Tag counts in pester-parallel |
| 6 Test execution metrics | PASS | Pester 14825 testcases, pytest 16152 passed, Jest 5289 passed |
| 7 Code quality checks | PASS | Static stage clean |
| 8 Gaps and exceptions | PASS | No skipped or removed tests; Pyright environment note recorded |
| 9 Summary of changes | PASS | Branch diff listed by qa-gates/scope-check (third pass) |
| 10 Compliance verdict | PASS | No item fails |

## Code Review Template

| Item | Status | Evidence |
|---|---|---|
| Findings table: Warning, tests/scripts/dev_tools/atomic_executor/test_qc_runner.py at 711 lines | PASS | Advisory tier only (at or above 700, below 800); the plan placed the P4-T2 cases there; a later split is optional |
| Findings table: Info, Pyright in the item worktree | PASS | 27 environment-only errors from the shared environment; 0 with the worktree package first (python-pyright note) |
| Python implementation audit | PASS | Command lists gain -n auto; stale --cov flag removed; fix_all leak-scan step |
| TypeScript implementation audit | N/A | No TypeScript change |
| PowerShell implementation audit | PASS | AST-only detection, ParseInput, no file reads in the core |
| C# implementation audit | N/A | No C# change |
| Test quality audit | PASS | Reviewed artifacts listed above |
| No secrets in code | PASS | No credentials added |
| No unsafe subprocess or command construction | PASS | Static argv lists only |
| Input validation at boundaries | PASS | Allowlist validation rejects absolute paths, parent segments, unknown kinds, blank fields, duplicates |
| Error handling remains explicit | PASS | Every failure throws once with all messages |
| Configuration / path handling is safe | PASS | Paths normalized to forward slashes and compared ordinally |
| Verdict | PASS | No blocking finding |

## Feature Audit Template

| Item | Status | Evidence |
|---|---|---|
| Scope and baseline | PASS | evidence/baseline (P0-T2, P0-T3) precede every change outside docs/features/ (scope-check) |
| Acceptance criteria inventory | PASS | spec.md and user-story.md: 35 locally verifiable, 2 CI-dependent each |
| Acceptance criteria evaluation, 35 locally verifiable | PASS | Plan traceability table; gates and scope-check |
| Acceptance criteria evaluation, 2 CI-dependent | N/A | Pending CI on the PR head; left unchecked for the orchestrator |
| Acceptance criteria check-off | PASS | 35 checked in each file; 2 unchecked |
| AC status summary | PASS | spec.md 37 total, 35 checked; user-story.md 37 total, 35 checked |
