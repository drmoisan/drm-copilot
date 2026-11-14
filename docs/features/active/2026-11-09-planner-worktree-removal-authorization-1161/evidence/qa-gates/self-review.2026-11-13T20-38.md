# Self-Review ([P4-T7], supersedes self-review.2026-11-13T20-37.md)

Timestamp: 2026-11-13T20-38
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff from the merge base of origin/main and HEAD (the merge base equals the origin/main tip; head 2d6cf541b); wc and awk logical line counts on the changed files; cmp of each hook and document against its bundle copy (P3-T4 and the P2-T6 re-copy); git grep of the git seams for the invocation form
EXIT_CODE: 1
Output Summary:
- Rows: 119 total; PASS 105, FAIL 3, N/A 11, counted from the tables of this file. The three FAIL rows are one finding (AC-27, exception E1) recorded in the mechanical rows, policy-audit section 8, and the feature audit.
- Supersedes `self-review.2026-11-13T20-37.md`, whose Output Summary row counts (118, 98, 1, 19) were not taken from its tables; its tables are identical to the tables below. That file is left unedited because evidence is append-only.
- The FAIL finding is AC-27 (host-path invariant): exception E1 of `scope-check.2026-11-13T20-36.md`, an evidence artifact of this run that quotes a drive-shaped synthetic value. It cannot be fixed without editing evidence, which the append-only directive forbids, so it is open for an owner decision. Per the plan, P4-T7 is not checked off while this row is FAIL.
- Gates read: pwsh-static.2026-11-13T20-15.md, python-static.2026-11-13T18-55.md, typescript-static.2026-11-13T18-55.md, pester-gate.2026-11-13T20-34.md, pytest-gate.2026-11-13T20-08.md, jest-gate.2026-11-13T20-09.md, scope-check.2026-11-13T20-36.md, all against the Phase 0 baseline artifacts under evidence/baseline/.

## Mechanical Rows Required by the Plan

| Item | Result | Evidence |
|---|---|---|
| P2-T6 line cap after the main merge | PASS | both Claude gates 500 logical lines, resolution sibling 260 (`evidence/other/file-size.2026-11-13T18-50.md`); session-root-reads-850.Constraints.Tests.ps1 3, 0 failed |
| #1163 session-root derivation | PASS | both Claude gates pass `(Get-Location).Path` to `Get-PlannerWorktreeRemovalTargetDecision`, the same derivation as `$mainRoot` and the #1163 `-BranchWorktreeResolver` default |
| Byte-identical helper twin and mirrors | PASS | legacy-codex-hook-contracts.Tests.ps1 44, 0 failed (four-copy pin); test_push_down_claude_resource_contracts and test_push_down_codex_and_agents_resource_contracts pass |
| Pack manifests list the new hooks | PASS | completeness and dependency-closure tests pass; entries placed outside ledger entry 0010's patch context (ProcessReductionChain.Ledger.Tests.ps1 5, 0 failed) |
| Frozen surfaces and registrations unchanged | PASS | scope-check: 0 of 4 paths in the merge-base diff |
| Host-path invariant (AC-27) | FAIL | scope-check exception E1: `evidence/qa-gates/pwsh-static.2026-11-13T20-15.md` quotes the removed drive-rooted synthetic test value; no host data, but drive-shaped; append-only forbids the redaction; owner decision required. Exception E2 (not a path): the `Command:` field of `scope-check.2026-11-13T20-36.md` names the home-directory search tokens, so a rerun of the same search matches that line |
| Execution-environment brief unchanged | PASS | no `.claude/skills/execution-environment/` path in the merge-base diff |

## Policy Audit Template

| Section | Item | Result | Evidence |
|---|---|---|---|
| Coverage Evidence Checklist | Python baseline artifact | PASS | evidence/baseline/pytest-gate.2026-11-10T03-33.md |
| Coverage Evidence Checklist | Python post-change artifact | PASS | evidence/qa-gates/pytest-gate.2026-11-13T20-08.md |
| Coverage Evidence Checklist | TypeScript baseline artifact | PASS | evidence/baseline/jest-gate.2026-11-10T03-38.md |
| Coverage Evidence Checklist | TypeScript post-change artifact | PASS | evidence/qa-gates/jest-gate.2026-11-13T20-09.md |
| Coverage Evidence Checklist | PowerShell baseline artifact | PASS | evidence/baseline/pester-gate.2026-11-10T04-07.md |
| Coverage Evidence Checklist | PowerShell post-change artifact | PASS | evidence/qa-gates/pester-gate.2026-11-13T20-34.md |
| Coverage Evidence Checklist | Per-language comparison summary | PASS | Pester 95.80% to 95.86%; pytest 97.11%/94.38% to 97.13%/94.42%; Jest 97.15%/93.87% to 97.18%/93.95% |
| Executive Summary | Temporary scripts deleted or kept with tests | PASS | every helper script is under SCRATCH, outside the worktree; the branch adds no script |
| 1.1 | Independence | PASS | parallel gates only (8-worker Invoke-PoshQCParallelTest, pytest -n auto, Jest workers), all 0 failed; a pre-existing order dependence found by the P2-T6 task check was fixed on both sides (leaker and victim), each side proven alone at the merge base |
| 1.1 | Isolation | PASS | helper rows target one pure function each; adapter rows mock the two seams; gate rows drive one decision per row |
| 1.1 | Fast execution | PASS | Pester 791.71 s wall across 8 workers for 22679 tests; pytest 266.83 s; the new suites hold no wait |
| 1.1 | Determinism | PASS | in-memory checkpoint texts and git results; no clock, randomness, network, or live git (AST rows assert the seams) |
| 1.1 | Readability | PASS | row names state the code or condition (`U1` to `U5`, each refusal code) |
| 1.2 | Baseline coverage documented | PASS | evidence/baseline/ P0-T2 to P0-T4 |
| 1.2 | No coverage regression | PASS | every changed file equal or higher than its baseline; the Codex gate's earlier drop to 97.70% was fixed to 100.00% |
| 1.2 | Changed files meet thresholds | PASS | lowest changed PowerShell file 93.33%; Python 100%/99.21%; TypeScript 100%/100% |
| 1.2 | New code coverage >= 90% | PASS | helper 100%, Claude adapter 93.88%, Codex adapter 93.33%, TS module 100%, Python additions fully covered |
| 1.2 | Comprehensive coverage | PASS | one row per refusal code, per U condition, per status, per ancestry outcome; validators over the 18-file shared corpus |
| 1.2 | Positive flows | PASS | allow rows for `prepared` and `fanned_in` through both refs on all three gates |
| 1.2 | Negative flows | PASS | rejecting corpus rows for each validator string; refusal rows for each code |
| 1.2 | Edge cases | PASS | detached HEAD, bare stanza, locked line variants, case-variant status and purpose, empty integration branch, trailing `.lock` branch |
| 1.2 | Error handling | PASS | GIT_FAILED rows for listing, status, rev-parse, and merge-base exits; unparseable checkpoint rows |
| 1.2 | Concurrency | N/A | hooks evaluate one command; no concurrent code |
| 1.2 | State transitions | PASS | `preparation_status` eligibility rows (preparing, prepared, fanned_in, removed, abandoned) |
| 1.2.1 | Per-language comparison | PASS | see Coverage Evidence Checklist |
| 1.3 | Clear failure messages | PASS | refusal sentences asserted as literals; `-Because` on guard rows |
| 1.3 | Arrange-Act-Assert | PASS | new rows set the scenario, call one function, assert; the added entry-point row carries the three comments |
| 1.3 | Document intent | PASS | each suite carries a .SYNOPSIS and .DESCRIPTION naming the isolation approach |
| 1.4 | Avoid external dependencies | PASS | no file, git process, or network in any new row (AC-34 search found only AST assertion strings) |
| 1.4 | Use mocks/stubs | PASS | the R1 and R3 seams, path-filtered Test-Path and Get-Content mocks in the entry-point row |
| 1.4 | Environment stability | PASS | leak scan 0 failures; no row depends on gitignored state |
| 1.5 | Pre-submission review | PASS | this artifact |
| 2.1 | Clarify the objective | PASS | issue #1161, spec.md D1 to D20 |
| 2.1 | Read existing change plans | PASS | plan.2026-11-09T16-33.md and the research artifact |
| 2.1 | Document the plan | PASS | plan.2026-11-09T16-33.md (preflight ALL CLEAR) |
| 2.2 | Simplicity first | PASS | one pure helper, two thin adapters, one call per gate |
| 2.2 | Reusability | PASS | the helper is byte-identical on both surfaces; validators share one corpus |
| 2.2 | Extensibility | PASS | refusal codes and U conditions are table-driven in the helper |
| 2.2 | Separation of concerns | PASS | decisions in the pure helper; reads and git calls only in the adapter seams (AST rows) |
| 2.3 | Cohesive modules | PASS | helper (decision), adapters (I/O), gates (wiring) |
| 2.3 | At or below the 800-line hard limit | PASS | largest changed files: jest.config.cjs 582, legacy-codex-hook-contracts.Tests.ps1 517, both Claude gates 500, epic-planner-state-core.ts 499, validate_epic_planner_state.py 498 |
| 2.3 | Public vs internal | PASS | the gates call one adapter function each; helper functions are script-scope definitions |
| 2.3 | No circular dependencies | PASS | gate dot-sources adapter, adapter dot-sources helper and imports WorktreeItemResolution; no back edge |
| 2.4 | Descriptive names | PASS | Get-PlannerWorktreeRemovalTargetDecision, Format-PlannerWorktreeRefusalSentence, ConvertFrom-PlannerWorktreePorcelain |
| 2.4 | Docs/docstrings | PASS | comment-based help on every function; gate .DESCRIPTION paragraphs pinned by the contract suite |
| 2.4 | Comment why, not what | PASS | comments state R1 to R7 reasons (seam scope, import without -Force) |
| 2.5 | Formatting | PASS | pwsh-static.2026-11-13T20-15.md 0 files differ; Black 2 files unchanged; Prettier clean |
| 2.5 | Linting | PASS | PSSA 0, Ruff 0, ESLint 0 |
| 2.5 | Type checking | PASS | Pyright 0 errors; tsc 0 errors for both tsconfig files; N/A for PowerShell |
| 2.5 | Testing | PASS | Pester 22679 0 failed; pytest 16714 0 failed; Jest 5546 0 failed |
| 2.5 | Full toolchain loop | PASS | loop restarted four times after fixes (P2-T6 line cap, guard and ledger, Codex coverage, host-path row) and ended in one clean pass |
| 2.5 | Explicit reporting | PASS | evidence/qa-gates/ and evidence/other/ artifacts |
| 2.6 | Summarize changes | PASS | commit messages from f675e13f1 to 2d6cf541b; PR body pending |
| 2.6 | Design choices explained | PASS | plan revision decisions R1 to R7 |
| 2.6 | Update supporting documents | PASS | epic-plan skills, epic-planner agents, parallel-orchestrate skill, parallel-orchestration rule, and their mirrors |
| 2.6 | Provide next steps | PASS | owner decision on E1; then P4-T6 and P4-T7 complete and the PR is authored |
| 3A.1 | Black | PASS | python-static.2026-11-13T18-55.md |
| 3A.1 | Ruff | PASS | All checks passed |
| 3A.1 | Pyright | PASS | 0 errors |
| 3A.1 | Pytest | PASS | 16714 passed, 0 failed |
| 3A.2 | Strong typing | PASS | `_validate_planner_worktrees` is fully annotated; Pyright 0 |
| 3A.2 | Dataclasses for value objects | N/A | no value object added |
| 3A.2 | Protocols/ABCs | N/A | no interface added |
| 3A.2 | Avoid utility classes | PASS | module function only |
| 3A.3 | Specific exceptions | PASS | the validator returns error strings; no exception handler added |
| 3A.3 | Logging over print | PASS | no print added |
| 3A.3 | Invariants at construction | N/A | no constructor changed |
| 3B.1 | Invoke-Formatter | PASS | 0 files differ; porcelain unchanged across the format step |
| 3B.1 | PSScriptAnalyzer | PASS | 0 findings |
| 3B.1 | Fix all findings | PASS | none open |
| 3B.1 | PowerShell 7 compatible | PASS | the gates and suites run under PowerShell 7.6 in every gate run |
| 3B.2 | Advanced functions | PASS | every new function carries `[CmdletBinding()]` and typed parameters |
| 3B.2 | Parameter validation | PASS | Mandatory and AllowNull or AllowEmptyString attributes as needed |
| 3B.2 | Avoid global state | PASS | no global variable; leak scan 0 failures |
| 3B.2 | Error handling | PASS | guarded dot-source and import record dependency failures; git failures map to GIT_FAILED |
| 3B.3 | Cohesive and at or below 800 lines | PASS | helper 482, adapters below 200, gates 500 |
| 3B.3 | Approved verbs | PASS | Add, Complete, ConvertFrom, ConvertTo, Format, Get, Invoke, Test; PSUseApprovedVerbs 0 findings |
| 3B.3 | Comment why | PASS | see 2.4 |
| 3B.4 | Format / Analyze / Test / Rerun | PASS | pwsh-static.2026-11-13T20-15.md and pester-gate.2026-11-13T20-34.md |
| 3C | Shell (shfmt, shellcheck, bats, shebang, size) | N/A | no shell file in the diff |
| 3D | JSON formatting and strict JSON | PASS | the 18 corpus files and both manifests parse in Python, TypeScript, and PowerShell; LF line endings |
| 3D | Required $schema and key order | N/A | the corpus and manifests are not schema-governed configuration |
| 4A | Pytest, coverage, focused tests, organization, naming | PASS | test_validate_epic_planner_state_planner_worktrees.py mirrors the module and is parametrized over the corpus |
| 4B.1 | Pester 6 and PoshQC configuration | PASS | one Invoke-PoshQCParallelTest per gate |
| 4B.2 | Focused tests, behavior over implementation, mocking, organization | PASS | suites under tests/scripts/claude-hooks, codex-hooks, and claude-runtime mirror the hook layout; mocks only at the named seams |
| 4B.3 | File naming, Describe/Context/It, grouping, comments | PASS | `*.Tests.ps1`; Context per concern (decision rows, seam body, AST shape) |
| 4B.4 | PoshQC test command, no alternative runner | PASS | gate evidence from Invoke-PoshQCParallelTest only; task checks are recorded as task checks |
| 5 | Test coverage detail | PASS | see 1.2 and the per-file tables in the gate artifacts |
| 6 | Test execution metrics | PASS | counts above; 0 failed in every final gate |
| 7 | Code quality checks | PASS | static artifacts above |
| CI Cross-check | CI checks relied on | N/A | the PR head's CI is read by the orchestrator after the PR exists |
| 8 | Gaps and exceptions | FAIL | E1 open (see the mechanical row); no other gap |
| 8 | Removed or skipped tests | PASS | none removed; the pytest skip count equals the baseline's 6 |
| 9 | Summary of changes | PASS | see 2.6 |
| 10 | Compliance verdict | N/A | the verdict follows the owner decision on E1 |

## Code Review Template

| Item | Result | Evidence |
|---|---|---|
| Findings: Blocker or Major | PASS | none in code; E1 is an evidence-record finding |
| Python implementation audit | PASS | additive private validator called only when the key is present; `REQUIRED_KEYS` unchanged; byte-identical strings to TypeScript |
| TypeScript implementation audit | PASS | one import and one call in epic-planner-state-core.ts; new module with its own coverageThreshold entry; no `any` or suppression added |
| PowerShell implementation audit | PASS | pure helper with no I/O (AST rows); adapters confine reads and git to seams; gate edits limited to dot-source, call, appended sentence, and help |
| C# implementation audit | N/A | no C# in scope |
| Test quality: determinism, isolation, speed, diagnostics | PASS | see policy-audit 1.1 |
| Security: no secrets | PASS | added lines contain no credential literal |
| Security: no unsafe subprocess or command construction | PASS | git runs as `& git @GitArgs` with an argument array in the two seams only; no string-built command and no Invoke-Expression |
| Security: input validation at boundaries | PASS | validators reject drive, leading slash, backslash, colon, and dot-segment paths and malformed branches |
| Security: error handling explicit | PASS | refusal codes for every failed check; dependency failures deny |
| Security: configuration and path handling | PASS | records are repository-relative; the branch is a policy-level control, disclosed in the gate help and skills (D13, D15) |
| Research log | N/A | no external research in this run |
| Size Warning (700 lines) | N/A | no changed file at or above 700 |

## Feature Audit Template

| Item | Result | Evidence |
|---|---|---|
| Work mode resolution | PASS | issue.md: full-feature; sources spec.md and user-story.md |
| spec.md AC-1 to AC-26, AC-28 to AC-34 | PASS | checked off as each gate verified them (33 of 34) |
| spec.md AC-27 | FAIL | exception E1; unchecked pending the owner decision |
| user-story.md criteria | PASS | 15 of 16 checked; the host-path criterion is unchecked with AC-27 |
