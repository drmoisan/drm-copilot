# Self-Review: Release Exemption for the Checkpoint-Free Pull Request Path (#1231)

Timestamp: 2026-11-24T01-30
Command: walk of .dev/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against the branch changes: `git diff --name-only <merge base of origin/main and HEAD>...HEAD` (8 committed feature-folder documents) plus `git status --porcelain` (the uncommitted implementation)
EXIT_CODE: 0
Output Summary: every checklist item is PASS or N/A; no FAIL row. One FAIL found during the walk (two new It names without the ` (#1231)` suffix) was fixed and the PowerShell QA loop re-run before this record was written (evidence/qa-gates/powershell-static.2026-11-24T01-18.md, evidence/qa-gates/pester.2026-11-24T01-30.md).

Scope reviewed: 4 new hook files (hook-release-pull-request-context.ps1, enforce-pr-author-skill.release.ps1, enforce-model-routing-receipt-release.ps1, enforce-orchestration-preimplementation-gate-release-receipt.ps1); 4 edited hook files (enforce-pr-author-skill.ps1 header, enforce-pr-author-skill.cleanup.ps1, enforce-model-routing-receipt.ps1, enforce-orchestration-preimplementation-gate.ps1); their 8 claude-customizations bundle copies; pack-manifests/core.json; 5 new Pester suites; 4 documentation sources and their generated targets and bundle copies.

## Policy Audit Template

| Section | Item | Result | Evidence |
|---|---|---|---|
| Coverage Evidence Checklist | TypeScript baseline and post-change artifacts | N/A | No TypeScript file changed. |
| Coverage Evidence Checklist | PowerShell baseline artifact | PASS | evidence/baseline/pester.2026-11-23T23-52.md (96.84% repo-wide; per-file figures for the four edited files). |
| Coverage Evidence Checklist | PowerShell post-change artifact | PASS | evidence/qa-gates/pester.2026-11-24T01-30.md, evidence/qa-gates/coverage-delta.2026-11-24T01-13.md. |
| Coverage Evidence Checklist | Per-language comparison summary | PASS | coverage-delta artifact: repo-wide 96.84% to 96.85%; no edited file dropped; new files 100%. |
| Executive Summary | Policy documents evaluated | PASS | general-code-change, general-unit-test, powershell rules; Python and Bash rules N/A (no file in scope). |
| Executive Summary | Temporary artifacts cleanup | PASS | All helper scripts are under SCRATCH, outside the worktree; none was added to the repository. |
| 1.1 | Independence | PASS | Each suite registers mocks per row (BeforeEach fixtures); the suites passed in the parallel 8-worker gate. |
| 1.1 | Isolation | PASS | One behavior per It: one row per code, allow row, absent-file row, and caught-error row per leg. |
| 1.1 | Fast execution | PASS | Single-suite runs complete in 1 to 2 s of test time (for example, the receipt suite reported "Tests completed in 1.61s"). |
| 1.1 | Determinism | PASS | No clock, network, process, or git; synthetic roots under /synthetic-worktrees/; all git and file seams mocked. |
| 1.1 | Readability and maintainability | PASS | Arrange/Act/Assert comments, descriptive names ending with (#1231), suite synopsis blocks. |
| 1.2 | Baseline coverage documented | PASS | Phase 0 artifact with repo-wide and per-file figures. |
| 1.2 | No coverage regression | PASS | Repo-wide +0.01; cleanup +0.19, model-routing +0.19, gate +0.04, pr-author 0.00. |
| 1.2 | Changed files meet thresholds | PASS | All changed files at or above 85% (lowest 91.23%). |
| 1.2 | New code coverage of at least 90% | PASS | New files 132/132 lines (100%); no missed line lies in a changed hunk of the edited files. |
| 1.2 | Comprehensive coverage | PASS | Every function of the four new files is exercised; Get-PrAuthorReleasePublishedHead seam body has its own row. |
| 1.2 | Positive flows | PASS | Allow rows for each leg (unit and decision level: AC-01, AC-05, AC-07). |
| 1.2 | Negative flows | PASS | One row per RELEASE_EXEMPTION_*, RELEASE_DELEGATION_*, and RELEASE_RECEIPT_* code. |
| 1.2 | Edge cases | PASS | Case-sensitive path row (Package.json), non-numeric <N>, nested relative and absolute receipt paths, blank root, --head with no value, '..' values, multiple allowances not combined. |
| 1.2 | Error handling | PASS | One caught-error row per leg asserting Write-Debug, empty suffix or null reason, and not allowed (AC-11). |
| 1.2 | Concurrency | N/A | The legs are stateless per call. |
| 1.2 | State transitions | N/A | No stateful component. |
| 1.2.1 | Per-language coverage comparison | PASS | PowerShell: 96.84% to 96.85% lines; new/changed code 100%. Python and TypeScript: N/A (out of scope); the pytest gate shows identical totals. |
| 1.3 | Clear failure messages | PASS | Should -Because messages name the row and the reason text. |
| 1.3 | Arrange-Act-Assert | PASS | Comment markers in every It. |
| 1.3 | Document intent | PASS | It names state behavior and the AC; each suite has a .SYNOPSIS and .DESCRIPTION. |
| 1.4 | Avoid external dependencies | PASS | No git, network, or process; Invoke-PrAuthorDocsOnlyGitExe and Invoke-DocsOnlyGitExe are mocked. |
| 1.4 | Use mocks and stubs | PASS | Mocked seams: allowance reader, container probe, checkpoint presence, HEAD branch, published head, git wrappers, resolution seams. |
| 1.4 | Environment stability | PASS | No temporary files; Invoke-PoshQCLeakScan: 0 failures. |
| 1.5 | Pre-submission review | PASS | This record. |
| 2.1 | Clarify the objective | PASS | spec.md and issue #1231. |
| 2.1 | Read existing change plans | PASS | plan.2026-11-23T17-58.md executed in order. |
| 2.1 | Document the plan | PASS | Plan checked off task by task with task-check evidence. |
| 2.2 | Simplicity first | PASS | Three small legs plus one pure predicate file; each leg is a linear first-failure-wins sequence. |
| 2.2 | Reusability | PASS | Reuses ConvertFrom-ReleaseAllowanceConfig, Test-ReleaseAllowanceBranchMatch, the #1201 file seams, Get-DocsEstateDelegationLabel, Get-ModelRoutingDocsEstateCommit, and the docs-only git seam; no new parser or matcher. |
| 2.2 | Extensibility | PASS | Shared Get-ReleasePullRequestConfigState and Get-ReleasePullRequestPathDecision take injected readers. |
| 2.2 | Separation of concerns | PASS | Pure predicates in hook-release-pull-request-context.ps1; I/O only through the existing seams. |
| 2.3 | Cohesive modules | PASS | One file per leg plus the shared pure file. |
| 2.3 | At or below the 800-line hard limit | PASS | Largest changed file 501 lines (gate); new files 108 to 177 lines; no file at or above 700. |
| 2.3 | Public vs internal | PASS | Each leg exposes one entry function; helpers are named for their leg. |
| 2.3 | No circular dependencies | PASS | The pure file dot-sources nothing; legs dot-source only the #1201 release sibling and the pure file. |
| 2.4 | Descriptive names | PASS | Get-PrAuthorReleaseExemption, Get-ModelRoutingReleaseDecision, Get-OrchestrationReleaseReceiptResult, Get-ReleasePullRequest*. |
| 2.4 | Docs and docstrings | PASS | Comment-based help with the evaluation order in each new file header and function. |
| 2.4 | Comment why, not what | PASS | Header notes explain fail-closed behavior, the policy-level disclosure, and call-time dependencies. |
| 2.5 | Formatting | PASS | 0 files changed (evidence/qa-gates/powershell-static.2026-11-24T01-18.md). |
| 2.5 | Linting | PASS | 0 analyzer findings. |
| 2.5 | Type checking | N/A | PowerShell. |
| 2.5 | Testing | PASS | Pester 29270 passed and 0 failed; pytest 17104 passed and 0 failed. |
| 2.5 | Full toolchain loop | PASS | Pass 1 failed AL-34 and was fixed; pass 2 was green; pass 3 re-ran after the It-name fix and was green. |
| 2.5 | Explicit reporting | PASS | Every command and exit code is recorded under evidence/. |
| 2.6 | Summarize changes | PASS | This record and the task-check files. |
| 2.6 | Design choices explained | PASS | File headers and the rule, brief, and skill text. |
| 2.6 | Update supporting documents | PASS | Rule, brief (four copies), pr-author skill, and pr-author agent regenerated; -Check reports no drift. |
| 2.6 | Provide next steps | PASS | Commit, push, PR, and CI remain for the orchestrator (not run here by instruction). |
| 3A | Python sections | N/A | No Python file changed. |
| 3B.1 | Formatting with Invoke-Formatter | PASS | Check mode over the 13 files: 0 changes. |
| 3B.1 | Linting with PSScriptAnalyzer | PASS | 0 findings with pssa.settings.psd1. |
| 3B.1 | Fix all findings | PASS | 13 PSReviewUnusedParameter findings in a test stub (P1-T1) were fixed before check-off. |
| 3B.1 | PowerShell 5.1 and 7.6+ compatible | PASS | Hooks target PowerShell 7+ per the repository rule; no 7.x-only syntax beyond what the existing hooks use. |
| 3B.2 | Advanced functions | PASS | Every function has CmdletBinding and OutputType. |
| 3B.2 | Parameter validation | PASS | Mandatory and AllowNull/AllowEmptyString attributes as in the sibling legs. |
| 3B.2 | Avoid global state | PASS | Only constant script-scope patterns with the ReleasePullRequest prefix; no global variables. |
| 3B.2 | Error handling | PASS | One try/catch per leg declining with Write-Debug; the gate's deny stands (fail closed). |
| 3B.3 | Cohesive and at or below 800 lines | PASS | See 2.3. |
| 3B.3 | Approved verbs | PASS | Get- and Test- only; analyzer reports no PSUseApprovedVerbs finding. |
| 3B.3 | Comment why | PASS | See 2.4. |
| 3B.4 | Step 1 format, step 2 analyze, step 4 test, rerun loop | PASS | Final static QC passes 2 and 3 clean; Pester passes 2 and 3 green. |
| 3B.4 | Step 3 type check | N/A | PowerShell. |
| 3C | Bash sections | N/A | No Bash file changed. |
| 3D.1 | JSON tooling | PASS | core.json parses (release-pull-request.Parity.Tests.ps1 reads it with ConvertFrom-Json); pack-manifest completeness and dependency-closure tests pass. |
| 3D.2 | JSON structure | PASS | Four entries appended to the existing paths array, adjacent to the #1201 entries. |
| 4A | Python unit-test sections | N/A | No Python test changed. |
| 4B.1 | Use Pester v6.x | PASS | Describe/Context/It, BeforeAll/BeforeEach, Should -Invoke. |
| 4B.1 | Use PoshQC configuration | PASS | All runs through the launcher pester suite (Invoke-PoshQCParallelTest). |
| 4B.1 | PowerShell compatibility | PASS | Suites carry #Requires -Version 7.0. |
| 4B.2 | Focused unit tests | PASS | Unit rows per function plus decision rows per gate. |
| 4B.2 | Behavior over implementation | PASS | Assertions on decisions, suffix text, and seam call counts named by the spec (AC-10). |
| 4B.2 | Mocking used sparingly | PASS | Only I/O and resolution seams are mocked; parsers and predicates run unmocked. |
| 4B.2 | Organization | PASS | tests/scripts/claude-hooks/<hook>.Tests.ps1 mirrors .claude/hooks/<hook>.ps1, following the existing suite naming. |
| 4B.3 | File naming | PASS | *.Tests.ps1. |
| 4B.3 | Describe/Context/It structure | PASS | Unit and decision contexts per suite. |
| 4B.3 | Logical grouping | PASS | Grouped by leg and by unit versus decision level. |
| 4B.3 | Docstrings and comments | PASS | Suite headers describe isolation and seams. |
| 4B.4 | Use the PoshQC test command | PASS | Launcher pester suite. |
| 4B.4 | No alternative test runners | PASS | Pester through PoshQC only. |
| 5 | Test coverage detail | PASS | Per-file 100% for new files; rows enumerated in the task-check evidence of P1-T1 to P3-T3. |
| 6 | Test execution metrics | PASS | 29288 cases, 29270 passed, 0 failed, 18 skipped; 667.64s wall-clock with 8 workers; largest new suite 389 lines. |
| 7 | Code quality checks (PowerShell) | PASS | Formatter 0, analyzer 0, Pester exit 0. |
| 7 | Code quality checks (Python) | N/A | No Python file changed; the full pytest gate passed (17104 passed). |
| CI Cross-check | CI results at the reviewed head | N/A | No commit or push was made by instruction; CI has not run on this change. |
| 8 | Gaps and exceptions | PASS | No approved exception; no skipped or removed test. |
| 9 | Summary of changes | PASS | See Scope reviewed above. |
| 10 | Compliance verdict | PASS | Fully compliant locally; CI pending. |
| Appendix A and B | Test inventory and command reference | PASS | Task-check and gate evidence list every suite and command. |

## Code Review Template

| Section | Item | Result | Evidence |
|---|---|---|---|
| Executive Summary | Change and scope stated | PASS | Three allow-side legs keyed on .claude/release-commit-allowance.json; Claude only; merge not covered (D1). |
| Executive Summary | Top risks | PASS | (1) Local tracking refs may be stale; disclosed, with `git push` immediately before `gh pr create` as the mitigation. (2) The gate file sits at the 500-line guidance tier. (3) Branch hooks reach isolated subagents only after merge; behavior is proven by Pester. |
| Findings Table | Blocker or Major findings | PASS | None. |
| Findings Table | Warning (file at or above 700 lines) | N/A | No covered file at or above 700 lines. |
| Implementation Audit (PowerShell) | What changed well | PASS | Shared pure predicates; exact reuse of the #1201 parser, matcher, and seams; no git call before the step that needs it; absent file is inert. |
| Implementation Audit (PowerShell) | API and safety notes | PASS | Ordinal, case-sensitive path matching; no path combination across allowances; owner:branch, -H, --head=, -R, --repo, and GH_REPO= rejected. |
| Implementation Audit (PowerShell) | Error handling and logging | PASS | try/catch with Write-Debug codes PR_AUTHOR_RELEASE_LEG_ERROR, MODEL_ROUTING_RELEASE_LEG_ERROR, PREIMPL_RELEASE_RECEIPT_LEG_ERROR. |
| Implementation Audit | Python, TypeScript, C# subsections | N/A | Not in scope. |
| Test Quality Audit | Reviewed artifacts | PASS | Five new suites; task-check, phase-gate, and final-gate evidence. |
| Test Quality Audit | Determinism, isolation, speed, diagnostics | PASS | See policy audit 1.1 and 1.3. |
| Security / Correctness | No secrets in code | PASS | No credential or token text in the change. |
| Security / Correctness | No unsafe subprocess or command construction | PASS | git runs only through the existing bounded seams with fixed argument arrays; no Invoke-Expression; no Python. |
| Security / Correctness | Input validation at boundaries | PASS | --head value regex with '..' rejection; base through Get-PrAuthorDocsOnlyBaseName; receipt path exact-match regex beneath R. |
| Security / Correctness | Error handling remains explicit | PASS | Every failure returns a named code; unexpected errors decline (fail closed). |
| Security / Correctness | Configuration and path handling | PASS | Directory entries rejected through the container probe; the allowance file is never shipped (AC-16). |
| Research Log | External research | N/A | None required; research.2026-11-23T23-00.md covers the design. |
| Verdict | Readiness | PASS | Go for the normal PR flow after commit, push, and CI. |

## Feature Audit Template

| Section | Item | Result | Evidence |
|---|---|---|---|
| Scope and Baseline | Base, head, merge base, sources | PASS | Base main; head feature/pr-author-release-exemption-1231; scope from the merge base of origin/main and HEAD plus the porcelain list; work mode full-feature. |
| Inventory | AC sources | PASS | spec.md (AC-01 to AC-23) and user-story.md (US-AC-01 to US-AC-08). |
| Evaluation | AC-01 to AC-04 (Leg 1) | PASS | enforce-pr-author-skill.Release.Tests.ps1 unit and decision rows; task-check P2-T1 and P2-T2. |
| Evaluation | AC-05 and AC-06 (Leg 2) | PASS | enforce-model-routing-receipt.Release.Tests.ps1; task-check P2-T3 and P2-T4. |
| Evaluation | AC-07 to AC-09 (Leg 3) | PASS | enforce-orchestration-preimplementation-gate-release-receipt.Tests.ps1; hook-release-allowance-context.Parity.Tests.ps1 unchanged; release-pull-request.Parity.Tests.ps1. |
| Evaluation | AC-10 and AC-11 (shared) | PASS | Absent-file exact-text rows and caught-error rows per gate and leg. |
| Evaluation | AC-12 to AC-14 | PASS | Parity suite token rows; contract-scope.2026-11-24T01-17.md (no .codex/ path; #1201 files unchanged); enforcement-hooks-no-python-invocation.Tests.ps1 passed. |
| Evaluation | AC-15 to AC-18 | PASS | Bundle byte identity, core.json listing, push-down contract tests, generator -Check no drift, brief copies identical, docs-estate contract unchanged, rule retains destination-owned and the disclosure. |
| Evaluation | AC-19 to AC-23 | PASS | Sizes recorded; five suites with synthetic roots and a clean leak scan; new files 100%; Decisions suites unchanged and passing; loop completed clean. |
| Evaluation | US-AC-01 to US-AC-08 | PASS | Each maps to the spec criteria above. |
| Summary | Overall readiness | PASS | 31 PASS, 0 PARTIAL, 0 UNVERIFIED, 0 FAIL. |
| AC Check-Off | Source files updated | PASS | spec.md 23 of 23 checked; user-story.md 8 of 8 checked. |
| AC Check-Off | CI-dependent criteria | N/A | No criterion requires the PR-head CI result; CI confirmation of the Linux hook-suite job remains for the orchestrator. |

## Walk Finding Fixed Before This Record

| Item | Initial result | Fix | Re-verification |
|---|---|---|---|
| Plan convention: new It names end with ` (#1231)` (policy audit 1.3 Document intent) | FAIL: `baseline mock interception probe` in enforce-pr-author-skill.Release.Tests.ps1 and enforce-model-routing-receipt.Release.Tests.ps1 | Both rows renamed to `baseline mock interception probe (#1231)` | Static QC pass 3 clean; full Pester gate pass 3: 29270 passed, 0 failed. |
