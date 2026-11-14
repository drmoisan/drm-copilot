# Self-Review - Issue 1019

Timestamp: 2026-11-06T18-34
Command: sh SCRATCH/issue-1019-p2-t9.sh (git diff --name-status MERGE_BASE...HEAD; git status --porcelain; sha256sum; cmp; wc -l; SCRATCH/issue-1019-mut-check.ps1), walked against docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md
EXIT_CODE: 0
Output Summary: No FAIL row. The file set is MODULE, BUNDLE, SUITE, and FEATURE documents. MODULE and BUNDLE hashes are equal (6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf; cmp exit 0). Physical lines: MODULE 265, SUITE 492, both below 800. AC status: 7 of 8 checked; AC-8 is pending-CI and unchecked. MERGE_BASE c4a2398aa93c721e06f6878851526d4338ec98c7.

## File Set

`git diff --name-status MERGE_BASE...HEAD` lists `.claude/lib/docs/DocsPythonTokens.psm1` (M), `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsPythonTokens.psm1` (M), `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` (M), and files under `<FEATURE>` (A). `git status --porcelain` lists only `<FEATURE>` paths, namely `issue.md`, the plan, and Phase 2 evidence, which the orchestrator commits.

Commits since `MERGE_BASE`, on branch `bug/docs-tokenizer-scaling-1019`:

1. `99b26392e` docs(1019): add feature folder and tokenizer root-cause profile
2. `6e33db871` docs(1019): add the minimal-audit plan after preflight clearance
3. `1bee6ac5c` docs(1019): record Phase 0 baselines for the tokenizer scaling fix
4. `39a0bdbe1` fix(docs): make the Python tokenizer linear with a bounded lexing window

## Recorded Decisions and Observations

### "Whole source" wording

The candidate comment in the `Get-DocsPythonToken` loop head and the candidate test title `passes the whole source to a .NET method only at the restart after a string token` say "whole source", while `$source` is now a bounded window. Both texts are kept for merge identity with 1034. The declaration comment above `$source` states that inside the loop "the whole source" means that window. This is an accepted wording decision and not a defect.

### Coding-cookie loop

The `for` loop over the coding cookie stays outside the token loop and passes `$lines[$cookieLine]` at most twice per run. Only a one-line source makes that element the whole source, once, so the root-cause profile classifies it as bounded. The guard inspects direct variable arguments and does not report it.

### Long-input property case and the window margin

The Phase 1 engineer reported that the long-input property case passes when the window margin is mutated to 0, while the padded-offset cases catch that mutation. This run reproduced that report with `SCRATCH/issue-1019-mut-check.ps1`, on a scratch copy of the final module with `$script:DocsPythonTokenWindowMargin` set to 0.

| Case in `Get-DocsPythonToken window boundaries` | Result on the mutant |
| --- | --- |
| `keeps the token at each padded offset across the window end: <Case>`, 12 cases | all Failed |
| `property: long inputs reconstruct their spans and lines` | Passed |
| `keeps the following token correct when a string ends at the window end` | Failed |
| `keeps Line, Column and EndLine after a triple-quoted string longer than one window` | Passed |
| `lexes a token longer than two windows: <Case>`, 4 cases | all Failed |
| `reports diagnostics with the right Line past the first window: <Case>`, 3 cases | all Failed |

Totals: 20 failed, 2 passed. The likely mechanism, read from the code and consistent with these results, is that a match end cannot exceed `$source.Length` minus 0, so the margin branch never rebases and only a string token moves the window. The two passing inputs reach a string token before each window end, so they do not exercise the margin. The long-input property case therefore does not guard the margin on its own; the padded-offset cases do. Only margin 0 was measured. No test was changed, because the plan specifies this case and its acceptance is met. Any strengthening of the case is a separate decision for the orchestrator.

### Other observations

- `SUITE` is 492 physical lines against the Pre-Mortem estimate of at most about 400. It remains below the 500-line guidance tier.
- The test `reports PYTHON_TOKEN_LIMIT above 262,144 tokens and accepts exactly 262,144 (built in test code, below 1,048,576 bytes)` took 41.127 s in the coverage run, above the about 10 s that the execution-environment brief uses as a signal. The next slowest case took 1.958 s. The test is pre-existing and tokenizes about 524,000 tokens in two calls; the scaling evidence shows linear cost. No fix was made, because the test is outside this plan's task text. This is reported as Info.
- The rebase statements appear twice in `Get-DocsPythonToken`, in the margin branch and after a string token. [P1-T2] specifies both, and they differ in how the window size is chosen. This is reported as Info.
- The whole-population figure printed by the folder run, 31.61% over 338 files, reflects a one-folder scan and is not a measure of `MODULE`.
- The `## Evidence Checklist` in `issue.md` is outside `## Acceptance Criteria` and no plan task checks it, so it was left unchanged.

## Policy-Audit Template

### Header and Coverage Metrics

| Item | Status | Evidence |
| --- | --- | --- |
| Coverage metrics, Python | N/A | No Python file changed. |
| Coverage metrics, PowerShell | PASS | 1 production file plus its byte-identical bundle copy, 1 test file. 56 `SUITE` tests, 0 failed. Baseline 98.44% lines; post-change 100% lines; changed lines 100%. `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md`. |
| Coverage metrics, Bash | N/A | No Bash file changed. |
| Coverage metrics, JSON | N/A | No JSON file changed. |
| TypeScript baseline coverage artifact | N/A | N/A - out of scope. |
| TypeScript post-change coverage artifact | N/A | N/A - out of scope. |
| PowerShell baseline coverage artifact | PASS | `evidence/baseline/pester-coverage-before.2026-11-06T18-01.md`. |
| PowerShell post-change coverage artifact | PASS | `evidence/qa-gates/suite-duration-after.2026-11-06T18-28.md`. |
| Per-language comparison summary | PASS | PowerShell: baseline 98.44% lines, post-change 100% lines, change +1.56%, changed-line coverage 100%. The baseline excludes the token-limit test. |
| Non-negotiable verdict rule | PASS | Numeric baseline, post-change, and changed-line values are recorded. |
| Fail-closed rule | PASS | No required baseline, QA, or comparison artifact is missing. |
| Evidence rule | PASS | Every value comes from a recorded run. |

### Executive Summary

| Item | Status | Evidence |
| --- | --- | --- |
| `general-code-change` evaluated | PASS | Section 2 below. |
| `general-unit-test` evaluated | PASS | Section 1 below. |
| Python policies evaluated | N/A | Out of scope. |
| PowerShell policies evaluated | PASS | Sections 3B and 4B below. |
| Bash policies evaluated | N/A | Out of scope. |
| JSON policies evaluated | N/A | Out of scope. |
| Temporary scripts deleted | N/A | Phase 2 helpers are PowerShell files and `sh` launchers under `SCRATCH`, outside the worktree, and none is committed. |
| Ongoing tooling scripts tested | N/A | No tooling script was added to the repository. |

### 1. General Unit Test Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 1.1 Independence | PASS | Three seeded file orders, failed 0 each. `evidence/regression-testing/shuffle-isolation.2026-11-06T18-28.md`. |
| 1.1 Isolation | PASS | Each `It` targets one tokenizer behavior; the guard cases target the module syntax tree. |
| 1.1 Fast execution | PASS | `SUITE` 27.07 s, 56 tests, down from a 600 s lower bound. One pre-existing slow test is recorded above as Info. |
| 1.1 Determinism | PASS | Seeds 101910 and 102210 are fixed; no clock, sleep, or timing threshold. The search of added lines for sleep, clock, stopwatch, and temporary-file calls returned 0. |
| 1.1 Readability and maintainability | PASS | Descriptive titles; `-Because` text names the case, offset, or seed. |
| 1.2 Baseline coverage documented | PASS | 98.44% lines, 126 covered and 2 missed, recorded before the change. |
| 1.2 No coverage regression | PASS | 98.44% to 100% lines. |
| 1.2 New code coverage at least 90% | PASS | 29 of 29 measurable changed lines, from the coverage report against `git diff --unified=0 MERGE_BASE`. |
| 1.2 Comprehensive coverage | PASS | Both functions, `Get-DocsPythonToken` and `Read-DocsPythonStringEnd`, at 100% of measured lines; no uncovered line. |
| 1.2 Positive flows | PASS | `Get-DocsPythonToken token classes` and the padded-offset cases. |
| 1.2 Negative flows | PASS | `reports <Code> as a blocking error for: <Case>`, 12 cases, and the past-first-window diagnostics, 3 cases. |
| 1.2 Edge cases | PASS | Offsets 1010 through 1026, closing quotes at 1015, 1016, 1023, and 1024, and tokens longer than two windows. |
| 1.2 Error handling | PASS | Diagnostic code, severity, blocking flag, and line are asserted. |
| 1.2 Concurrency | N/A | The functions are pure and share no mutable state. |
| 1.2 State transitions | PASS | Window doubling and reset are driven by `lexes a token longer than two windows: <Case>`; rebase after a string by the string-end case. |
| 1.2.1 Per-language comparison | PASS | Recorded under the header table above. |
| 1.3 Clear failure messages | PASS | The guard failure messages in `guard-fail-before.2026-11-06T18-28.md` name the offending expression. |
| 1.3 Arrange-Act-Assert | PASS | New cases carry Arrange, Act, and Assert sections. |
| 1.3 Document intent | PASS | Titles state the scenario; comments state why the syntax tree is pinned. |
| 1.4 Avoid external dependencies | PASS | In-memory strings and `Parser::ParseFile` on the module path only. |
| 1.4 Use mocks or stubs | N/A | No external system is involved, so no mock is used. |
| 1.4 Environment stability | PASS | Paths resolve from `$PSScriptRoot`; no temporary file; no global state. |
| 1.5 Pre-submission review | PASS | This self-review; the reduced audit follows from the orchestrator. |

### 2. General Code Change Policy

| Item | Status | Evidence |
| --- | --- | --- |
| 2.1 Clarify the objective | PASS | `issue.md`, issue 1019. |
| 2.1 Read existing change plans | PASS | Candidate hunks taken from 1034; plan cites them. |
| 2.1 Document the plan | PASS | `plan.2026-11-06T12-15.md`. |
| 2.2 Simplicity first | PASS | A bounded substring replaces the whole-source argument; no new function. |
| 2.2 Reusability | PASS | Rebase statements repeat twice as the plan specifies; recorded above as Info. |
| 2.2 Extensibility | PASS | The exported signature and token contract are unchanged. |
| 2.2 Separation of concerns | PASS | The module stays pure with no I/O. |
| 2.3 Cohesive modules | PASS | The change stays inside the tokenizer module. |
| 2.3 At or below the 800-line hard limit | PASS | `MODULE` 265, `SUITE` 492; neither has a baseline entry or needs one; neither reaches 700. |
| 2.3 Public vs internal | PASS | `Export-ModuleMember -Function Get-DocsPythonToken` is unchanged. |
| 2.3 No circular dependencies | PASS | Module imports are unchanged. |
| 2.4 Descriptive names | PASS | `$sourceText`, `$windowStart`, `$windowSize`, `DocsPythonTokenWindowMargin`. |
| 2.4 Docs and docstrings | PASS | Existing comment-based help remains accurate; a declaration comment explains the window. |
| 2.4 Comment why, not what | PASS | Comments state the per-call cost that motivates the slices. |
| 2.5 Formatting | PASS | `evidence/qa-gates/format.2026-11-06T18-15.md`; hashes unchanged. |
| 2.5 Linting | PASS | `evidence/qa-gates/analyze.2026-11-06T18-15.md`; 0 findings each. |
| 2.5 Type checking | N/A | Not applicable for PowerShell. |
| 2.5 Testing | PASS | Folder run 2049 tests, 0 failures. |
| 2.5 Full toolchain loop | PASS | One pass; no step changed a file or failed. |
| 2.5 Explicit reporting | PASS | Commands and results are in the Phase 2 artifacts. |
| 2.6 Summarize changes | PASS | The commit subject and this record; the orchestrator writes the pull request. |
| 2.6 Design choices explained | PASS | `issue.md` `## Implementation Intent` and the recorded decisions above. |
| 2.6 Update supporting documents | PASS | `issue.md` and the plan are updated. |
| 2.6 Provide next steps | PASS | Listed at the end of this record. |

### 3A. Python Code Change

| Item | Status | Evidence |
| --- | --- | --- |
| 3A.1 Black, Ruff, Pyright, Pytest (4 items) | N/A | No Python file changed. |
| 3A.2 Strong typing, dataclasses, protocols, utility classes (4 items) | N/A | No Python file changed. |
| 3A.3 Specific exceptions, logging, invariants (3 items) | N/A | No Python file changed. |

### 3B. PowerShell Code Change

| Item | Status | Evidence |
| --- | --- | --- |
| 3B.1 Formatting with Invoke-Formatter | PASS | Formatter text equal for `MODULE` and `SUITE`. |
| 3B.1 Linting with PSScriptAnalyzer | PASS | 0 findings each. |
| 3B.1 Fix all findings | PASS | There were no findings to fix. |
| 3B.1 PowerShell compatibility | PASS | `.claude/rules/powershell.md` requires PowerShell 7 or later, and the module states 7.4 or later; the template's 5.1 wording does not apply to this module. Runs used PowerShell 7. |
| 3B.2 Advanced functions | PASS | `[CmdletBinding()]` is unchanged on both functions. |
| 3B.2 Parameter validation | PASS | Parameter attributes are unchanged. |
| 3B.2 Avoid global state | PASS | The two new script-scope values are constants that nothing reassigns. |
| 3B.2 Error handling | PASS | Blocking diagnostics are unchanged, confirmed by the differential. |
| 3B.3 Cohesive and at or below the 800-line limit | PASS | 265 and 492 physical lines. |
| 3B.3 Approved verbs | PASS | No function was added or renamed; PSScriptAnalyzer reports 0 findings. |
| 3B.3 Comment why | PASS | See 2.4. |
| 3B.4 Step 1 Format | PASS | See 2.5. |
| 3B.4 Step 2 Analyze | PASS | See 2.5. |
| 3B.4 Step 3 Type check | N/A | Not applicable for PowerShell. |
| 3B.4 Step 4 Test | PASS | See 2.5. |
| 3B.4 Rerun loop if needed | PASS | One iteration was needed. |

### 3C and 3D. Bash and JSON

| Item | Status | Evidence |
| --- | --- | --- |
| 3C.1 shfmt, shellcheck, bats (3 items) | N/A | No Bash file changed. |
| 3C.2 Shebang, error handling, line limit (3 items) | N/A | No Bash file changed. |
| 3D.1 Formatting, schema validation, `$schema` (3 items) | N/A | No JSON file changed. |
| 3D.2 Strict JSON, key order (2 items) | N/A | No JSON file changed. |

### 4A. Python Unit Test

| Item | Status | Evidence |
| --- | --- | --- |
| 4A.1 to 4A.4, all items (9 items) | N/A | No Python test changed. |

### 4B. PowerShell Unit Test

| Item | Status | Evidence |
| --- | --- | --- |
| 4B.1 Use Pester v5.x | PASS | Blocks use the modern syntax. The suite requires at least 5.0.0, and the repository selects 6.2.0, which these runs used. |
| 4B.1 Use PoshQC configuration | PASS | Self-hosted `Invoke-PoshQCTest` with its default settings path; no setting changed. |
| 4B.1 PowerShell compatibility | PASS | See 3B.1. |
| 4B.2 Focused unit tests | PASS | 22 window-boundary and 2 guard tests added by this item, plus 3 candidate tests. |
| 4B.2 Test behavior over implementation | PASS | Behavior cases assert tokens and diagnostics. The guard cases assert code structure deliberately, as AC-4 requires a guard with no timing. |
| 4B.2 Mocking used sparingly | PASS | No mock is used. |
| 4B.2 Organization | PASS | `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1` mirrors `.claude/lib/docs/DocsPythonTokens.psm1`. |
| 4B.3 File naming | PASS | `DocsPythonTokens.Tests.ps1`. |
| 4B.3 Describe/Context/It structure | PASS | 5 `Describe` blocks and 23 `It` blocks, expanding to 56 tests. |
| 4B.3 Logical grouping | PASS | Separate describes for the structural guard and window boundaries. |
| 4B.3 Docstrings and comments | PASS | The file synopsis is retained; helpers carry comments. |
| 4B.4 Use PoshQCTest command | PASS | `Invoke-PoshQCTest -Root <worktree> -ScanFolders tests/scripts/claude-lib/docs`. |
| 4B.4 No alternative test runners | PASS | Pester only. Direct Pester runs are the helpers the plan names. |

### 5 to 10. Coverage Detail, Metrics, Quality, Gaps, Summary, Verdict

| Item | Status | Evidence |
| --- | --- | --- |
| 5 Test coverage detail | PASS | `MODULE` 151 of 151 lines; no uncovered line. |
| 6 Total tests | PASS | `SUITE` 56; folder run 2049. |
| 6 Tests passed | PASS | 56 of 56; 2049 of 2049. |
| 6 Tests failed | PASS | 0. |
| 6 Execution time | PASS | 27.07 s without coverage; 46.832 s with coverage. |
| 6 Average time per test | PASS | About 483 ms from 27.07 s over 56 tests; the token-limit test holds most of the total. |
| 6 Discovery time | N/A | The helper does not report discovery time separately. |
| 6 Functions tested | PASS | 2 of 2. |
| 6 Test file size | PASS | 492 physical lines. |
| 6 Code coverage | PASS | 100% lines. Pester measures no branch coverage. |
| 7 Python checks (4 items) | N/A | Out of scope. |
| 7 Invoke-Formatter | PASS | See 2.5. |
| 7 PSScriptAnalyzer | PASS | See 2.5. |
| 7 Pester tests | PASS | See 2.5. |
| 8 Identified gaps | PASS | None against policy. Info items are listed above. |
| 8 Approved exceptions | N/A | None needed. |
| 8 Removed or skipped tests | PASS | None. |
| 9 Commits in this branch | PASS | Listed under `## File Set`. |
| 9 Files modified | PASS | Listed under `## File Set`. |
| 10 Compliance verdict | PASS | Compliant on the evidence recorded here; AC-8 stays pending-CI. |
| Appendix A test inventory | PASS | The inventory is the `SUITE` file; the folder run has 0 failures. |
| Appendix B toolchain commands | PASS | Recorded in each artifact's `Command:` field. |

## Code-Review Template

| Item | Status | Evidence |
| --- | --- | --- |
| Executive summary inputs | PASS | Change scope and evidence are recorded above. |
| Top risks | PASS | (1) 1034 can change the merge result with a later commit. (2) The long-input property case does not guard the margin; other cases do. (3) CI on the pull request head is not yet observed. |
| PR readiness | PASS | Conditional Go: ready for the pull request and reduced audit, with AC-8 pending CI. |
| Findings table | PASS | No Blocker or Major finding. Info: the 41.127 s token-limit test; the repeated rebase statements; the property case and the margin. Nit: "whole source" wording, kept by decision. |
| Python implementation audit | N/A | Out of scope. |
| TypeScript implementation audit | N/A | Out of scope. |
| PowerShell, what changed well | PASS | No call in a loop passes the source text as an argument, which the guard pins; candidate hunks stay byte-identical. |
| PowerShell, API and safety | PASS | Signature and export unchanged; analyzer 0 findings. `ShouldProcess` does not apply to a pure function. |
| PowerShell, error handling | PASS | Diagnostics unchanged; 51 diagnostic inputs compare identical. |
| C# implementation audit | N/A | Out of scope. |
| Reviewed test and QA artifacts | PASS | The artifacts named in this record. |
| Determinism | PASS | Fixed seeds and no clock. |
| Isolation | PASS | Three seeded orders, failed 0. |
| Speed | PASS | See 1.1. |
| Diagnostics | PASS | `-Because` text and guard messages name the failing input. |
| No secrets in code | PASS | The diff adds no credential or token value. |
| No unsafe subprocess or command construction | N/A | The module starts no process. |
| Input validation at boundaries | PASS | The `-Text` parameter attributes are unchanged. |
| Error handling remains explicit | PASS | See above. |
| Configuration and path handling | PASS | Test paths resolve from `$PSScriptRoot`; no configuration file changed. |
| Research log | N/A | No external research was needed; the measurements are in the root-cause profile. |
| Verdict | PASS | Consistent with Conditional Go above. |

## Feature-Audit Template

| Item | Status | Evidence |
| --- | --- | --- |
| Scope and baseline | PASS | Base `epic/documentation-estate-tooling-integration`, head `bug/docs-tokenizer-scaling-1019`, `MERGE_BASE` above. |
| Requirements source | PASS | `issue.md` `## Acceptance Criteria` only; Work Mode `minor-audit` is explicit. |
| AC-1 root cause verified by measurement | PASS | `evidence/baseline/root-cause-profile.2026-11-06T17-25.md`. |
| AC-2 candidate hunks present, no loop passes the source | PASS | `evidence/regression-testing/candidate-hunks.2026-11-06T18-09.md`; hunk check re-run with 0 failures; guard passes on fixed. |
| AC-3 approximately linear | PASS | `evidence/qa-gates/scaling-after.2026-11-06T18-33.md`; ratios 1.72 to 2.09. |
| AC-4 structural guard | PASS | `evidence/regression-testing/guard-fail-before.2026-11-06T18-28.md`. |
| AC-5 behavior unchanged | PASS | `evidence/regression-testing/suite-on-fixed.2026-11-06T18-09.md`; `evidence/regression-testing/differential.2026-11-06T18-33.md`, zero differing hashes. |
| AC-6 bundle byte-identical, contract tests pass | PASS | `evidence/regression-testing/mirror-parity.2026-11-06T18-09.md`; `cmp` exit 0 in this review. |
| AC-7 toolchain, coverage, durations | PASS | `format`, `analyze`, and `suite-duration-after` artifacts under `evidence/qa-gates/`. |
| AC-8 CI green and merged | N/A | Pending-CI: the pull request does not exist yet. The criterion stays unchecked; the orchestrator owns it at S9. |
| Summary and readiness | PASS | 7 criteria verified; 1 pending-CI; 0 failed. |
| AC check-off | PASS | Summary below. |

## Acceptance Criteria Status

- Source: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/issue.md`
- Total AC items: 8
- Checked off (delivered): 7
- Remaining (unchecked): 1
- Items remaining: `CI is green on the pull request head and the pull request is merged into epic/documentation-estate-tooling-integration (CI-dependent).` This item is pending-CI.

## Next Steps

The orchestrator commits the Phase 2 work, opens the pull request against `epic/documentation-estate-tooling-integration`, runs the reduced audit, and checks off AC-8 at S9.
