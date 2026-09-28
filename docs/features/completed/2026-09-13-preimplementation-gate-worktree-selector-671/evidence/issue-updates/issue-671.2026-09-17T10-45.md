# Issue #671 Update Mirror — Remediation R1

Timestamp: 2026-09-17T10-12
Task: [P7-T10]
PostedAs: unknown

Posting note: the executor did not post this text to GitHub. It was not asked to post, and it may not stage, commit, or push. The orchestrator owns posting. If the text is posted, update `PostedAs:` and record the URL.

## Update text

Remediation R1 for #671 (preimplementation gate worktree selector, LACS) is implemented and verified in the feature worktree. The changes are not yet committed.

**What changed**
- **L3 fixture replacement.** The `LACS L3a` and `LACS L3b` deny rows now use commands the gate's staging trigger classifies (`git -C C:/repo/wt && git add -- …` and `git -C C:/repo/wt --no-pager add -- …`). Both rows now reach the L3 rejection in `Test-ExemptOrchestrationSelector`. The previous fixtures carried no `add`/`commit`, so the gate never consulted the exemption for them.
- **Empty-token fail-open closed.** `Test-ExemptOrchestrationSegmentToken` now declares `[AllowEmptyString()]` on `$Token`. Before this change, an empty quoted token (`""`) failed parameter binding, the caller continued past the error, and `Test-ExemptOrchestrationStagingCommand` returned true. For example, `git add "" -- src/foo.ps1` was allowed. Such lines now allow only when every operand is exempt, and deny otherwise.
- **Direction: narrowing only.** No command line that denied before R1 allows after it. `git commit -m "" -- <exempt operand>` still allows, and a row pins that decision. `git add "" -- src/foo.ps1`, `git add -- "" scripts/powershell/Sample.ps1`, `git add -- src/foo.ts ""`, `git commit -m "" -- src/foo.ts`, and `git -C "" add -- …` now deny.
- **Fail-closed guard.** The per-segment loop of `Test-ExemptOrchestrationStagingCommand` is wrapped in `try`/`catch`, and any classification error answers false.
- **Unit-level predicate rows.** Both command-exemption suites add a Context that calls `Test-ExemptOrchestrationSelector` directly: 3 accept rows, 12 reject rows covering L1–L8, and one node that mocks a classification error and asserts the guard returns false. The suites also add a deny row for an accepted selector followed by an unmodelled subcommand, and a five-row empty-token Context. The comment-based help now states that the caller rejects any subcommand other than `add` or `commit`.
- The spec was amended first: fixture tables, INV-6, the function-impact table, the backward-compatibility note, criteria 11/19/20 reworded, and criteria 25/26 added. All four helpers copies are byte-identical (441 lines each), and the gate, modes, shared-parser, and epic-merge files are unchanged.

**Verification (from `artifacts/pester/*.xml`, fresh for each run)**
- Both command-exemption suites: 105 tests, 0 failures; all 46 `issue #671` nodes pass.
- Full Pester run: 4641 tests, 2 failures. Both are pre-existing baseline failures, and neither is an `issue #671` node.
- PSScriptAnalyzer: 0 findings on the four helpers copies and the three suites. The formatter changed no file.
- Coverage: repository-wide line coverage is **95.56%** (8986 / 9404). The `.claude/hooks` helpers per-file line coverage is **96.71%** (147 / 152), up from 92.72% before R1 and above the 94.92% pre-change baseline. The `.codex/hooks` copy is identical at 96.71%. Changed-line coverage is 38 / 38 instrumented lines.
- Python push-down contract tests: 16 passed.
- All 26 spec acceptance criteria are checked, each with an evidence path.
