# Self-Review: Issue 1097 Stage C Review Remediation

Timestamp: 2026-11-07T08-37
Command: policy-audit, code-review, and feature-audit templates under docs/features/templates/policy_audit/ walked against the diff from the merge base of origin/main and HEAD, and against the name listing of the diff since this cycle began
EXIT_CODE: 0
Output Summary: no FAIL row. F1, F3, F4, F5, F6, and each form of the decisions section have a row naming the proving test or artifact. The walk found one item, fixed before this write: two PSReviewUnusedParameter findings in the new ReviewGuard rows. Per the coordinator hold, no row compares coverage with an earlier figure.

## Finding Rows

| Finding | Status | Proving test or artifact |
| --- | --- | --- |
| F1 Merge commands the gate does not read | PASS | Shared rows in `EpicMergeGateReview.Cases.Helpers.ps1` under `RG-` and `RGC-`; the five reviewer commands as `reviewer-*` in real-process-merge-gate (deny from both gates, fixtures A and B) |
| F3 Entry number before the head read | PASS | `CRS-SKILL-COMMITS-ENTRY-NUMBER-BEFORE-HEAD-READ` over four copies |
| F4 Ordinal key name | PASS | `OCR-READINESS-BLOCKS-KEY-NAME-CASE-VARIANT`, `OCR-COMPLETION-UNCHANGED-FOR-KEY-NAME-CASE-VARIANT` |
| F5 Key documented in the orchestrator-state skill | PASS | `CRS-AGENTS-STATE-SKILL-DOCUMENTS-KEY` over source and bundle; the review-outcomes section compared equal to the merge base |
| F6 Guard .NOTES names its run-time calls | PASS | `.NOTES` of the guard names `ConvertFrom-DocsOnlyNameList`, the scanner and command functions, and the two Claude-only functions |
| Coordinator requirement: best-effort read without the key | PASS | `RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION` (six cases), `RGC-SHAPE-NOKEY-READ-FAILURE-KEEPS-DECISION` (four cases), `RG-SHAPE-RESOLUTION-FAILURE-KEEPS-SESSION-KEY-DENY`, and fixture `C-no-worktree` of real-process-merge-gate |

## Decision Form Rows

| Form | Status | Proving test or artifact |
| --- | --- | --- |
| if/then, while, for, case | PASS | `RG-` and `RGC-` `wrapper-if-then`, `wrapper-while`, `wrapper-for`, `wrapper-case` with `pending-` and `nokey-` forms; real-process-merge-gate |
| exec, !, time, env, command, builtin | PASS | `wrapper-exec`, `wrapper-bang`, `wrapper-time`, `wrapper-env`, `wrapper-command`, `wrapper-builtin`; real-process-merge-gate |
| subshell, brace group, $( ), backticks | PASS | `wrapper-subshell`, `wrapper-brace-group`, `wrapper-dollar-substitution`, `wrapper-backtick-substitution`; real-process-merge-gate |
| eval, sh -c, bash -c, pwsh -c, xargs | PASS | `wrapper-eval`, `wrapper-sh-c`, `wrapper-bash-c`, `wrapper-pwsh-c`, `wrapper-xargs`; real-process-merge-gate |
| leading backslash; cd prefix | PASS | `wrapper-leading-backslash`, `wrapper-cd-prefix`; real-process-merge-gate |
| quoted word; line continuation | PASS | `quoted-token-review-passed` allow; `quoted-token-review-pending`, `quoted-word-review-pending`, `line-continuation-review-pending` each `REVIEW_GATE_NOT_PASSED` |
| backslash inside a word; variable or substituted subcommand | PASS | `split-backslash-word`, `split-variable-subcommand`, `split-substituted-subcommand` |
| REST path, literal or variable number; curl | PASS | `api-rest-merge`, `api-rest-merge-variable-number`, `api-curl-rest-merge` |
| GraphQL merge, auto-merge, enqueue | PASS | `api-graphql-merge`, `api-graphql-auto-merge`, `api-graphql-enqueue`, and `api-graphql-other-mutation` for the word rule |
| GraphQL query from a file, variable, or --input | PASS | `api-graphql-query-file`, `api-graphql-query-variable`, `api-graphql-input-file` |
| --auto, --admin, -R, --repo | PASS | `flag-auto`, `flag-admin`, `flag-repo-short`, `flag-repo-long` |
| More than one invocation | PASS | `chain-semicolon`, `chain-and`, `chain-or`, `chain-pipe`, `chain-background`, `chain-newline`, `chain-second-bare`, `chain-push-then-merge` |
| Bare, branch, or URL selector | PASS | `bare-command`, `selector-branch`, `selector-url` |
| Prose naming the phrase | PASS | `prose-over-match`, `prose-in-merge-body`; the trade is stated in the rule and D10 |
| Script file; encoded or composed text; alias; endpoint in a variable | PASS | `disclosed-script-file`, `disclosed-encoded-payload`; `CRS-RULE-DISCLOSES-UNREAD-MERGE-FORMS` |
| Queued auto-merge | PASS | `allow-disable-auto`; `CRS-RULE-DISCLOSES-UNREAD-MERGE-FORMS` |
| PowerShell tool, mcp tools, web UI, Codex shell_command | PASS | No hook runs, so no row; `CRS-RULE-DISCLOSES-UNREAD-MERGE-FORMS` pins the disclosure |
| Must stay allowed | PASS | `allow-pr-view`, `allow-pr-view-merge-fields`, `allow-pr-checks`, `allow-pr-create`, `allow-pr-create-merge-title`, `allow-pr-edit`, `allow-confirmation-query`, `allow-confirmation-query-poll-loop` |
| Allowed through the guard | PASS | `allow-skill-merge`, `allow-skill-merge-match-head`, `allow-skill-merge-number-first` |
| Checkpoint reads | PASS | `RG-SHAPE-KEY-IN-ITEM-WORKTREE-ONLY`, `RG-SHAPE-SECOND-NUMBER-ITEM-CARRIES-KEY`, `RG-SHAPE-SESSION-KEY-WITH-FIRST-ITEM-KEYLESS`, `RG-SHAPE-NUMBERLESS-WRAPPER-SESSION-KEY`, `RG-SHAPE-BOUND-COMMAND-READS-NO-EXTRA-CHECKPOINT` |

## Scope Rows

| Item | Status | Evidence |
| --- | --- | --- |
| The diff since this cycle began holds only the planned paths | PASS | A filter of the name listing against the guard, the gates, their bundles, the two modules, the rule, the skills, entry 0002, the named tests, and FEATURE left 0 paths |
| No Python or TypeScript source | PASS | 0 paths by extension filter |
| No execution-environment, atomic-plan-contract, or Epic #1019 path | PASS | 0 paths by name filter |
| No acceptance-criterion, baseline, or coverage-comparison text changed | PASS | `spec.md` differs by one line, D10; `user-story.md` does not differ; no existing evidence file changed |
| Reduction token on commits that edit entry 0002 | PASS | `docs(hooks): correct the merge guard disclosure (reduction: 0002)` and `fix(orchestrate): pin the concurrent key name and state the merge shape (reduction: 0002)` |
| Four guard copies byte-identical | PASS | stage-c-review-powershell-format-lint, 9 mirror groups, 0 differing; `RG-TWIN-IS-BYTE-IDENTICAL` |
| Ledger valid and replay holds | PASS | stage-c-review-ledger-replay: 25 blocks, 13 paths, 0 differing |
| No tag | PASS | `git tag --points-at HEAD` lists nothing |
| Merge commit line | PASS | Unchanged; it stays with the orchestrator |

## Policy Audit Template

| Item | Status | Evidence |
| --- | --- | --- |
| Coverage evidence checklist | PASS | stage-c-review-powershell-test holds each file against the threshold from this run alone; the hold applies |
| 1.1 Independence | PASS | Rows build in-memory checkpoints and set their own mocks; they passed in the 8-worker run |
| 1.1 Isolation | PASS | One decision per row; one behavior per `It` |
| 1.1 Fast execution | PASS | No new test starts a process; the gate took 304.11 seconds |
| 1.1 Determinism | PASS | Fixed texts and object ids; no clock, randomness, or network |
| 1.1 Readability | PASS | Row names state the form; the case table reads as the decisions section |
| 1.2 Baseline coverage documented | PASS | stage-c-review-recorded-gates, copied from the recorded stage C gates |
| 1.2 No coverage regression | N/A | The hold forbids a comparison; each changed file is reported against the threshold in stage-c-review-powershell-test |
| 1.2 New code coverage | PASS | Claude guard 98.77%, Codex guard 91.98%, Claude gate 98.60%, Codex gate 99.40% |
| 1.2 Comprehensive coverage | PASS | The missed guard lines are named in stage-c-review-powershell-test |
| 1.2 Positive flows | PASS | `allow-*`, `quoted-token-review-passed` |
| 1.2 Negative flows | PASS | The denied forms with `pending-` rows |
| 1.2 Edge cases | PASS | `chain-second-bare`, `split-*`, `RG-SHAPE-NUMBERLESS-WRAPPER-SESSION-KEY`, `allow-confirmation-query-poll-loop` |
| 1.2 Error handling | PASS | `RG-SHAPE-NOKEY-RESOLUTION-FAILURE-KEEPS-DECISION`, `RGC-SHAPE-NOKEY-READ-FAILURE-KEEPS-DECISION` |
| 1.2 Concurrency | N/A | The rule holds no shared state |
| 1.2 State transitions | N/A | The rule is a stateless decision per command |
| 1.2.1 Per-language comparison | N/A | The hold forbids a comparison; PowerShell is the only language changed |
| 1.3 Clear failure messages | PASS | `-Because` carries the reason text |
| 1.3 Arrange, Act, Assert | PASS | Marked in each new `It` with more than one step |
| 1.3 Document intent | PASS | Comment help on helpers; row names state the scenario |
| 1.4 External dependencies | PASS | Process and read seams are mocked; no new test reads a file beyond committed skill text |
| 1.4 Mocks and stubs | PASS | Existing seams only, with parameter filters by named parameter |
| 1.4 Environment stability | PASS | `[char]92` for each backslash; `Join-Path` from a synthetic root; no drive letter |
| 1.5 Pre-submission review | PASS | This artifact |
| 2.1 Before making changes | PASS | phase0-instructions-read and stage-c-review-recorded-gates precede the first code commit |
| 2.2 Design principles | PASS | Pure predicates in the shared guard; I/O isolated in one Claude-only reader; no new dependency or file |
| 2.3 Module and file structure | PASS | Guard 696 lines, below the 700 advisory tier; Claude gate 497, below the 500 limit of the task; case helper 356 |
| 2.4 Naming, docs, comments | PASS | Comment help on each new function; the guard header states the shape step and the limits |
| 2.5 Formatting, linting, type checking, testing | PASS | stage-c-review-powershell-format-lint and stage-c-review-powershell-test; type checking does not apply |
| 2.5 Full toolchain loop | PASS | One analyzer failure restarted format and lint; no file changed after the passing pass |
| 2.5 Explicit reporting | PASS | Each artifact records command, exit code, and summary |
| 2.6 Summarize and document | PASS | Commit bodies, rule section, D10, and entry 0002 |
| 2.6 Next steps | PASS | A re-review follows, then the two `[C]` criteria are re-checked |
| 3A Python | N/A | No Python file in this cycle |
| 3B PowerShell tooling, design, safety | PASS | Advanced functions, `CmdletBinding`, typed parameters, no new mutable state; analyzer findings 0 |
| 3B PowerShell structure, naming, comments | PASS | Approved verbs and singular nouns |
| 3C Bash | N/A | No bash file in this cycle |
| 3D JSON | N/A | No JSON file in this cycle |
| 4A Python unit test policy | N/A | No Python test in this cycle |
| 4B PowerShell unit test policy | PASS | Pester, `-ForEach` over shared rows, wrapper seams mocked, never the executables |
| 5 Test coverage detail | PASS | 204 shared rows under each of two prefixes, plus 12 `RG-SHAPE-*`, 4 `RGC-SHAPE-*`, 2 `OCR-*`, and 12 `CRS-*` cases |
| 6 Test execution metrics | PASS | stage-c-review-powershell-test: 15392 tests, 0 failures |
| 7 Code quality checks | PASS | Format and lint clean; no test skipped or removed |
| 8 Gaps and exceptions | PASS | The disclosed limits are stated in the rule and D10. The no-number deny of `Get-EpicMergeGateReviewDecision` is now reached only through a direct call; it stays, because the plan keeps that function unchanged |
| 9 Summary of changes | PASS | Branch log and the name listing above |
| 10 Compliance verdict | PASS | Compliant with no open item |

## Code Review Template

| Item | Status | Evidence |
| --- | --- | --- |
| PowerShell: what changed well | PASS | One allowlist decides the bound shape, so an unknown flag fails by absence |
| PowerShell: API and safety notes | PASS | `Get-EpicMergeGateReviewDecision` and every scanner file are unchanged |
| PowerShell: error handling and logging | PASS | Each catch states why a failure sees no key; a key already read still denies (`RG-SHAPE-RESOLUTION-FAILURE-KEEPS-SESSION-KEY-DENY`) |
| Python, TypeScript, and C# audits | N/A | No such file in this cycle |
| Test quality prompts | PASS | Each rule is designed to be falsifiable: the sole-segment check guards `chain-push-then-merge`, the allowlist guards `flag-admin`, and the candidate read guards `RG-SHAPE-KEY-IN-ITEM-WORKTREE-ONLY`. No mutation run was made |
| Security and correctness checks | PASS | The command text is never executed; real-process rows ran with no mocked seam; the control stays policy-level, as D10 states |
| Research log | N/A | No external source used |
| Verdict | PASS | No Blocking item found by this walk; the re-review decides |

## Feature Audit Template

| Item | Status | Evidence |
| --- | --- | --- |
| Scope and baseline | PASS | Scope rows above; stage-c-review-recorded-gates |
| Acceptance criteria inventory | PASS | `spec.md` and `user-story.md`; the only change is the text of decision D10, which is outside both inventories |
| Acceptance criteria evaluation | PASS | The two `[C]` criteria the reviewer unchecked stay unchecked until the re-review, as the plan requires |
| Summary | PASS | F1, F3, F4, F5, and F6 are addressed; F2 needs no action |
| Acceptance criteria check-off | N/A | This cycle checks off no criterion |
