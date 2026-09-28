# Code Review: Epic-Level Checkpoint Seam for Enforcement Gates (#663) - Remediation Cycle 1 Re-Audit

**Review Date:** 2026-09-25
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue #663 in the branch name.
**Base Branch:** `origin/main` (`d754f83f`, equal to the merge base)
**Head Branch:** `bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` (`3371d937`)
**Review Type:** Re-audit after remediation cycle 1 (prior review `code-review.2026-09-25T20-26.md` at `ac8ef840`)
**Scope:** full branch diff `git diff origin/main...HEAD` (151 files, +13137/-100), with close reading of the cycle-1 range `git diff 71e6e594..HEAD` (46 files, +3942/-111; 10 code or test files, the rest feature-folder evidence).

---

## Executive Summary

Remediation cycle 1 changed two production files (each mirrored byte-identically) and four test files:

- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (plus `.codex/hooks/` and both extension-bundle copies). `Test-OrchestrationCommandTextUnresolvable` now returns true when the line contains `\"` or `\'` anywhere (line 131), or a backslash inside a double-quoted span (line 148). The `.DESCRIPTION` text was corrected. The row-12 call site comment was updated (line 469).
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (plus the bundle copy). `Resolve-EpicScopeCheckpoint` now selects the candidate branch from the effective worktree HEAD whenever `-MatchWorktreeHead` is set, ignoring any text branch signal (line 340). The module and parameter help were updated.
- Tests: six deny rows per command-exemption suite (claude and codex), one gate-4 end-to-end row, and two resolver rows.

Both prior findings are closed:

- **CR-1 (Blocker) is closed.** The exact CR-1 command and its `;` variant are denied through the new early check. The chain-operator form (CR-3) is denied as well, because row 12 runs before `Split-OrchestrationCommandLine`. A hand trace shows that for every line the scanner still accepts, its quote state now matches POSIX (details under Security / Correctness Checks).
- **CR-2 (Major) is closed.** For the gate-4 command and path legs, the candidate branch and the `MERGE_HEAD` probe both come from the `-C` worktree, or the session root when there is no `-C`. Gates 1 and 3 are unchanged: without `-MatchWorktreeHead`, a null text branch still returns `no-branch-signal` at line 316, so `$candidate = $branch` is non-null exactly as before.

Fail-before evidence shows the new rows failing before the production change: RB1 has 12 failures, the six new names in each of two suites. RB2 has three failures: H1, H2, and G4-11. Final evidence shows 5073 Pester tests with 0 failures and 0 errors. The reviewer parsed `artifacts/pester/powershell-coverage.xml` independently: helpers 97.04% (164/169) in both measured copies, `EpicScopeResolution.psm1` 90.38% (94/104), and 95.87% repo-wide (9840/10264).

No new fail-open path was introduced. One pre-existing class remains outside the R1 scope: an unquoted backslash before a chain operator or whitespace. Its record, follow-up 8, understates it (N-1 below). The code in question is byte-identical to `origin/main`. N-1 is non-blocking, but the follow-up text should be corrected.

**Top 3 risks:**
1. N-1: follow-up 8 says the unquoted `\;` mismatch "fails toward deny". Reviewer trace shows it can fail open in principle. Exploitation needs on-disk paths named `add`, `commit`, or `-m`, and zero tracked such paths exist. Pre-existing from #539.
2. The #655 end-to-end sequence has not been rerun on a live epic (follow-up 5), and no CI run exists yet for the branch head.
3. The PR context artifacts are absent (CR-9 carried forward). pr-author requires them.

**PR readiness recommendation:** **Ready** once the PR context is collected and CI runs. No Blocker or Major finding remains.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Resolved | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and three byte-identical copies) | lines 110-163; checks at 131 and 148 | CR-1 closed. The exact CR-1 line `git add docs/features/active/x/a.md && git commit -m "a\"" > src/prod.ts "\"" docs/features/active/x/a.md` contains `\"`, so line 131 returns true. `Test-ExemptOrchestrationStagingCommand` then returns false at line 469, before any split, and the gate's pre-change deny applies. The `;` variant is denied the same way. D4 accepted rows (double-quoted messages with apostrophes and `<`/`>`, single-quoted `<`/`>`) carry no backslash and still pass. The `'\''` idiom contains `\'` and is denied. `$` and backtick are still denied in every quote state (line 141). | None. | Fail closed without modelling escapes, consistent with D4. | Diff `71e6e594..HEAD`; test rows at CommandExemption `:467-486`, codex `:474-493`; `evidence/regression-testing/rem1-fail-before-rb1.md` (FailedCount 12); `evidence/qa-gates/rem1-final-pester-coverage.md` (0 failures). |
| Resolved | `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` | lines 334-359 | CR-2 closed. With `-MatchWorktreeHead`, `$candidate` comes from `Get-EpicScopeWorktreeHeadBranch` on the selector root, or the session root when there is no selector. `Test-EpicScopeMergeInProgress` probes the same `$effectiveRoot` (line 357). A `branch:` label in a commit message no longer decides gate-4 scope. Gates 1 and 3 (callers at `enforce-pr-author-skill-helpers.ps1:344` and `enforce-model-routing-receipt.ps1:247`) do not pass the switch. For them the early return at line 316 guarantees a non-null `$branch`, so the new `-not $MatchWorktreeHead` branch is equivalent to the old `$null -ne $branch` branch. | None. | D2 requires the merge to be in progress in the effective worktree. | Resolver rows at `EpicScopeResolution.Tests.ps1:354-383`; gate row at `...gate.EpicScope.Tests.ps1:228-245`; `rem1-fail-before-rb2.md` (H1, H2, G4-11 failed before). |
| Resolved | `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | lines 58-107 | CR-3 closed by the same check. Row 12 runs at line 469, before `Split-OrchestrationCommandLine`, so no escaped-quote line reaches the splitter. A dedicated deny row was added (`git commit -m "x\"" ; touch src/prod.ts ; "\"" -- docs/features/active/x/a.md`). | None. | | CommandExemption `:474`. |
| Minor | `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md` | line 25 (follow-up 8) | N-1. Follow-up 8 says an unquoted backslash before `;`, `&`, or a pipe character "fails toward deny for chains". This is not always true. Consider `git add -- docs/features/active/x/a.md\;git commit -m src/prod.ts docs/features/active/x/b.md`. The scanner reads two segments and classifies both as exempt: `-m` consumes `src/prod.ts` as a message. A POSIX shell runs a single `git add --` whose pathspecs include `commit`, `-m`, and `src/prod.ts`. `git add` aborts when any pathspec matches nothing, so exploitation requires on-disk paths named `commit` and `-m` (or `add`). Zero tracked paths have an `add`, `commit`, `-m`, or `-C` component (reviewer scan of `git ls-files`). A related pre-existing form: an unquoted `\ ` (backslash-space) in a message folds the following operand into the message, so git commits the full index. The split, tokenizer, and segment classifier are byte-identical to `origin/main` (reviewer diff), so this is not introduced by the branch. | Correct the follow-up 8 text before promotion. It should state that the mismatch can fail open when files named after the reinterpreted tokens exist, and that unquoted `\` + whitespace also desynchronises tokenization. Suggested durable fix, in a separate issue: treat any unquoted backslash as unresolvable, with an explicit decision on D4 row 18 (unquoted backslash separators such as `docs\features\...`, which a POSIX shell also strips). | Accuracy of recorded residual risk; the exemption is allow-side only. | Reviewer diff of `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, and `Test-ExemptOrchestrationSegmentToken` against `origin/main` (all unchanged); code trace of `helpers.ps1:58-107`, `:166-217`, `:338-442`. |
| Minor | pre-existing gate suites under `tests/scripts/claude-hooks/` | n/a | CR-4 carried forward as follow-up 6. Pre-existing gate-1, gate-3, and gate-4 suites reach the unmocked resolver, which reads the gitignored `artifacts/orchestration/epic-orchestrator-state.json`. This has no effect in CI, where the file is absent. | Track through follow-up 6 (same class as #510). | Recorded appropriately; not introduced by cycle 1. | `evidence/other/follow-ups.md:21`. |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | lines 18-22 | CR-5 carried forward as follow-up 3 (PURITY header wording). | Track through follow-up 3. | Documentation accuracy only. | `evidence/other/follow-ups.md` item 3. |
| Info | `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md` | line 83 | RR-1 / follow-up 7. The design prose still describes head matching only "for a leg with no branch signal", while the code now ignores text signals on every command or path leg. AC-1 (line 226) remains accurate. | Update the design prose with the follow-up or at PR time. The AC needs no change. | Spec text is not an AC; recorded appropriately. | `evidence/other/follow-ups.md:23`. |
| Info | `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` | n/a | CR-9 carried forward. PR context artifacts are still absent, and the collector is not in this reviewer's toolset. The review used `git diff origin/main...HEAD` and `git diff 71e6e594..HEAD` directly. | Run `mcp__drm-copilot__collect_pr_context` against `origin/main` before pr-author. | pr-author preflight requires them. | `ls artifacts/pr_context.*` (absent). |
| Info | branch head `3371d937` | n/a | No CI workflow run exists for the branch (`gh run list --branch ...` returned no rows). | Confirm CI is green after the PR is opened (S9 gate). | CI is the authoritative portability check. | Reviewer `gh run list`. |

No Blocker or Major finding remains. One new Minor (N-1) concerns documentation accuracy for a pre-existing condition.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python file changed in cycle 1. The branch-level Python changes are two test-support files (`tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`), which the prior review accepted.

#### Typing and API notes

- Unchanged from the prior review.

#### Error handling and logging

- Not applicable (test-only Python).

### PowerShell implementation audit

#### What changed well

- The CR-1 fix is minimal and fail-closed: two string checks and one in-loop check. It adds no escape modelling, which D4 forbids. The fix runs before the splitter, so it also covers the chain-operator variant.
- The CR-2 fix is a one-condition change: the switch, not the presence of a text branch, now selects the matching strategy. It narrows a text-controlled input on the gate-4 path and leaves the gate-1 and gate-3 semantics unchanged.
- The docstrings now describe the behaviour accurately (helpers `.DESCRIPTION` at lines 115-120; resolver `.DESCRIPTION` and `.PARAMETER MatchWorktreeHead`).
- Mirrors: reviewer SHA-256 shows the four helpers copies all equal `5bb872e2...81d7f`, and the two module copies both equal `9ff75eeb...d61ec`.

#### API and safety notes

- `Contains('\"')` and `Contains("\'")` are ordinal substring checks. PowerShell single-quoted `'\"'` is the two characters backslash and double quote, and `"\'"` is backslash and single quote. Both are correct.
- The in-loop backslash check is guarded by `$openQuote -eq '"'`, so backslashes inside single quotes, which POSIX treats as literal, do not deny unless followed by `'`. Those are caught by line 131, which is conservative.
- Behaviour tightened: a double-quoted message containing any backslash (for example `"path a\b"`) is now denied. This is intended and covered by a deny row. Unquoted backslash separators (D4 row 18, test at CommandExemption `:100-102`) remain allowed.

#### Error handling and logging

- Unchanged. Row 12 returns false, and the gate's pre-change deny path supplies the reason text (`PREIMPLEMENTATION_GATE_BLOCKED`, asserted by the new rows).

---

## Test Quality Audit

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:467-486` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:474-493`: six parameterised deny rows each. They cover the exact CR-1 line, the `;` variant, the CR-3 chain-operator form, an unquoted `\"`, an unquoted `\'`, and a backslash inside a double-quoted message. Each asserts `deny` with a `-Because` message and the `PREIMPLEMENTATION_GATE_BLOCKED` reason.
- `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1:354-383`: two rows. H1: a text label equal to `integration_branch` with a differing selector HEAD gives `branch-mismatch`, with the merge probe invoked 0 times. H2: a text label naming another branch with a selector HEAD equal to `integration_branch` gives epic scope, and the merge probe targets the selector root.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:228-245`: end-to-end gate row G4-11. The selector worktree HEAD differs from the label, the result is the single-feature deny, and the merge probe is invoked 0 times.
- Fail-before: `evidence/regression-testing/rem1-fail-before-rb1.md` (EXIT 1, FailedCount 12, exactly the six new names twice) and `rem1-fail-before-rb2.md` (EXIT 1, FailedCount 3: H1, H2, G4-11 with the expected wrong-direction values).
- Post: `evidence/qa-gates/rem1-final-pester-coverage.md` (5073 tests, 0 failures, 0 errors, 9 disabled), `rem1-final-coverage-delta.md` (changed-line coverage 100% for all three measured files in the cycle range), `rem1-final-poshqc-format.md` (0 formatted, 517 already formatted), `rem1-final-poshqc-analyze.md` (no findings), `rem1-final-pytest-contracts.md` (27 passed), `rem1-final-seven-stage-loop.md` (pass 1 clean).

### CI portability review

- No changed test file references `origin/`, `refs/remotes`, or `FETCH_HEAD`. A reviewer Grep over the ten branch-changed PowerShell suites returned no match.
- No `New-Item`, `TestDrive`, `GetTempPath`, `$env:TEMP`, or `Out-File` in those suites, so no temporary files are created.
- Cycle-1 added test lines contain no drive-rooted path. They use the synthetic POSIX roots `/synthetic-worktrees/*`. Drive-letter strings elsewhere in the command-exemption suites are pre-existing literal command text for D4 rows 16b and LACS, not filesystem roots.
- No gitignored checkpoint is read by the new rows. The resolver rows use `Set-EpicScopeResolverMock` and the gate row uses `Set-EpicScopeSeam`, so checkpoint text comes from a mock.
- Every cycle-1 file is committed LF (`git ls-files --eol`: `i/lf w/lf attr/text=auto eol=lf`), and no test constructs CRLF content.

### Quality assessment prompts

- Would the new rows fail if the fix were reverted? Yes, as the fail-before evidence shows.
- Do the rows assert the decision and not only absence of error? Yes: `permissionDecision` equals `deny`, and the reason is matched.
- Is the non-regression of D4 accepted rows proven? Yes. The #663 exempt rows (apostrophe, `<`/`>` in quotes) and the D4 row-18 allow row passed in the final run.

---

## Security / Correctness Checks

Hand trace of the post-fix scanner (PowerShell cannot be executed from this worktree; the isolation guard denies `pwsh`):

| Input class | POSIX behaviour | Scanner behaviour | Outcome |
|---|---|---|---|
| `\"` or `\'` anywhere | may or may not move a span boundary | line 131 returns true | deny (fail closed) |
| `\` inside `"..."` | escapes `"`, `\`, `$`, backtick, newline | line 148 returns true | deny (fail closed) |
| `\` inside `'...'`, not followed by `'` | literal | literal, span closes at next `'` | agreement |
| `$` or backtick, any state | expansion | line 141 returns true | deny |
| unquoted `<` or `>` | redirection | returns true | deny |
| quoted `<` or `>` (no backslash) | literal | literal | agreement (D4 accepted) |
| unquoted `\>` or `\<` | literal | returns true | deny (fail closed) |
| unquoted backslash before `;`, `&`, or a pipe character | literal | splits a segment | pre-existing mismatch (N-1); can fail open only if paths named `add`, `commit`, or `-m` exist |
| unquoted `\` + whitespace | joins tokens | splits tokens | pre-existing mismatch (N-1) |
| unquoted `\` + newline | line continuation | splits a segment; trailing `\` operand normalises to `/` and is denied | fail closed |

- Quote-state agreement: for every line that passes rows 12, 11, and 13, the scanner's span boundaries equal the shell's. So the D4 narrowing introduced by #663 (quoted `<` and `>`) can no longer hide a redirection or a chain operator.
- No new fail-open path: the cycle-1 helpers change only adds `return $true` paths to an allow-side predicate. The resolver change narrows gate-4 epic scope for lines whose text label disagrees with the worktree HEAD. The converse, where the text names another branch but the worktree HEAD equals `integration_branch`, now enters epic scope. This is the documented D2 and AC-1 behaviour, and the allow still requires a ready epic checkpoint and `MERGE_HEAD` in that worktree.
- No Python in hooks: no added hook or lib line on the branch invokes `python`, `poetry`, or a `.py` file. The single Grep hit, `gitdir:\s`, is a false positive of the drive-letter pattern.

---

## Research Log

- `git diff 71e6e594..HEAD` for the six production copies and four test files.
- `git show origin/main:.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, then a function-level diff of `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, and `Test-ExemptOrchestrationSegmentToken` against HEAD (all three unchanged).
- `sha256sum` over the four helpers copies and two module copies.
- `git ls-files` scan for path components `add`, `commit`, `-m`, `-C` (count 0).
- Parse of `artifacts/pester/powershell-coverage.xml` for the ten changed measured PowerShell production files.
- `gh run list --repo drmoisan/drm-copilot --branch bug/enforcement-gates-lack-epic-level-checkpoint-seam-663` (no runs).

---

## Verdict

**Ready**, conditional on the carried-forward operational items (PR context collection, CI run, manual #655 rerun). CR-1, CR-2, and CR-3 are closed with fail-before and pass-after evidence. N-1 is a non-blocking documentation-accuracy correction to follow-up 8 for a pre-existing condition. Blocking findings: 0.
