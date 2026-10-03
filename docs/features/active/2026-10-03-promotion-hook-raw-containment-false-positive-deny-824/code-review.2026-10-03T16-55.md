# Code Review: Whole-token R2 matcher, fail-closed worktree-gate operands, and source-safe setup script (#824)

---

**Review Date:** 2026-10-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its suffix matches issue 824 in the branch name.
**Base Branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `425772de97a84663d781d2bffeac4b8e4787787f`
**Review Type:** Reaudit after remediation cycle 2 (pass 3)

---

## Executive Summary

Remediation cycle 2 (commit 425772de) made four changes:

- `Test-CommandLineRawInvocation` now classifies a wrapper-led or substitution segment when the command word and every subcommand element each occur as a whole token, in any order. The sequence and absorption grammar is kept for operand extraction only.
- The three worktree-removal gates no longer allow `NoOperand`. A wrapped removal replaces the structural path only when the reader returns a single literal operand.
- `.codex/codex-web-setup.sh` moves solution discovery into three functions and ends with a `BASH_SOURCE` guard. 15 bats cases cover it.
- The `shell-coverage` workflow gains a scoped kcov measurement and a changed-function gate, `scripts/dev-tools/KcovFunctionCoverageGate.ps1`, which has its own Pester suite.

All three pass-2 blockers are closed for their reproduced forms. The reviewer repeated the base-versus-head probe through the real decision entry points:

- Y1, Y2, Y3, Y5 and the other wrapped `gh issue create` spellings are denied on both runtimes.
- X1-X10 are denied on all three gates.
- The #824 reproduction and the Addendum 1 reproduction are allowed.

The reviewer also ran the bats suite and kcov locally. Every changed function measured 100%.

The probe found one new regression class, in the gate operand path. The reader returns one literal operand from the first classifying segment, and the gate then authorizes the whole command on that operand. A command that also names an authorized worktree can therefore carry a second removal that the gate never checks. That second removal can sit in the same segment behind a redirection, a subexpression, or `xargs`, or in a later segment.

**What changed (cycle 2):**
- `hook-command-raw-invocation.ps1` (four byte-identical copies, 300 lines): whole-token classifier `Test-CommandLineRawWordPresent`.
- Three worktree-removal gates: the `NoOperand` allow line removed.
- `hook-command-invocation.ps1` (four copies): contract comments only.
- `.codex/codex-web-setup.sh` (two copies, 405 lines), the bats suite, and one fixture directory.
- `.github/workflows/_shell-coverage.yml`, `scripts/dev-tools/KcovFunctionCoverageGate.ps1`, and two new Pester suites.

**Top 3 risks:**
1. An unauthorized worktree removal passes all three worktree-removal gates when the same command names an authorized worktree first (CR-1).
2. The modified workflow has not run against the branch head. Runner behavior is unverified: the kcov build cache, `pwsh` on `ubuntu-latest`, and the shallow `git fetch` of the base SHA (CR-2).
3. `list_root_solution_files` and the top-level wiring that feeds `REPO_ROOT` and `SOLUTION_FILE` have no row asserting a non-empty listing (CR-3, Minor).

**PR readiness recommendation:** **Needs Revision.** CR-1 is a verified enforcement regression in hard-deny hooks. CR-2 is resolved by pushing the branch and obtaining a green run.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/hook-command-raw-invocation.ps1` (and `.codex` copy and both mirrors); `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `Get-CommandLineRawInvocationOperand` token loop (`if ($token.Length -eq 0) { break }`); `Resolve-CommandLineWrappedInvocationOperand` (first classifying segment only); gate lines 365-366 (epic), 371-372 (parallel), 135-136 (Codex) | CR-1: For each fully literal match, the reader breaks without recording anything when the token after the match is empty. The token is empty when the operand follows `>`, `<`, or `(`, or when `xargs` supplies it. When another match in the same segment yields a literal operand, the result is `Operand` with that single value. Separately, the resolver reads only the first segment that classifies. In both cases the gate authorizes the whole command on one operand. With a checkpoint authorizing only `/repo/worktrees/item-b-102` (B) and target `/repo/worktrees/item-a-101` (A), each of these is denied at the merge base and allowed at head: W1 `bash -c 'git worktree remove B; git worktree remove >/dev/null A'`; W2 `bash -c 'git worktree remove B; echo A (pipe) xargs git worktree remove'`; W3 `pwsh -c 'git worktree remove B; git worktree remove (Join-Path /repo/worktrees item-a-101)'`; W4 `bash -c 'git worktree remove B && git worktree remove </dev/null A'`; W5 `bash -c "git worktree remove B"; bash -c "git worktree remove A"`; W6 `bash -c "git worktree remove B" && git worktree remove A`. (pipe) is the shell pipe character. | Make the wrapped-operand result fail closed for the whole command. (1) In `Get-CommandLineRawInvocationOperand`, return `Indeterminate` when any fully literal match yields an empty token while another match yields an operand. More simply, return `Operand` only when every accepted match yields the same literal token, and `NoOperand` only when every match yields none. Optionally, also require the number of fully literal matches to equal the number of whole-token occurrences of the last subcommand word. (2) In `Resolve-CommandLineWrappedInvocationOperand`, or in each gate, return `Indeterminate` when more than one segment of the command classifies as `git worktree remove`, whether wrapped or structural. (3) Add Issue824-tagged deny rows for W1-W6 in all three gate suites, using a checkpoint that authorizes B only, and unit rows in both `hook-command-raw-invocation.Tests.ps1` files. Keep A824-WT5-1..5, A824-WT3, and the X and WT10/11 rows green without assertion edits. | The gates protect unmerged worktrees. Cycle 2 design decision 2 denies "an operand the reader cannot read", and the spec invariant states that "no non-literal operand outcome is routed to an allow". Here an unreadable operand, and a later segment, are routed to an allow by the presence of one authorized operand. The merge base denied every one of these commands, so this weakens detection, contrary to issue requirement 4 and the general clause of AC-14. | Reviewer probe: `git archive f6ef5b2f .claude/hooks .claude/lib .codex/hooks` into the session scratchpad. Calls went through `Invoke-EpicWorktreeRemovalGateDecision` and `Invoke-ParallelWorktreeRemovalGateDecision`, with mocked run target and checkpoint seams. W1-W6 are denied at base and allowed at head on both Claude gates. Three further head-allow rows are excluded because git itself rejects them: two operands in one `git worktree remove`, and two forms with no operand. W1, W2, W5, and W6 were also run through `Invoke-CodexWorktreeRemovalDecision` and are denied at base and allowed at head. Controls: `bash -c "git worktree remove A"` is denied at both commits, and `bash -c "git worktree remove B"` is allowed at head. |
| Blocker | `.github/workflows/_shell-coverage.yml` | lines 64-97 (three new steps) | CR-2: The branch modifies a workflow. No workflow run exists against head `425772de`, which is on no remote branch, and no PR exists. Under the `modified-workflow-needs-green-run` rule this blocks until a green run on the head is recorded. | Push the branch, open the PR or dispatch `ci.yml`, and record the green `shell-coverage / Shell Coverage (Bats + kcov)` run with its head SHA in the feature evidence. The Gate step log should show six `FUNCTION ... PASS` lines and `UNCOVERED-CHANGED=NONE`. | `.claude/skills/feature-review-workflow/SKILL.md` policy rule; classified `awaiting_ci`. | `git branch -r --contains HEAD` returns nothing; `gh pr list --head bug/promotion-hook-raw-containment-false-positive-deny-824 --state all` returns `[]`. |
| Minor | `tests/shell/test_codex_web_setup_codex_copy.bats` | C824-7; top-level lines 32-35 of `.codex/codex-web-setup.sh` | CR-3: `list_root_solution_files` is asserted only for a directory with no solution file. No row drives the top-level wiring that passes its output to `resolve_repo_root` and `select_solution_file`. By inspection, a mutant that changed the `-name '*.sln'` pattern, or that swapped the two arguments of `resolve_repo_root` at the call site, would keep every row green. Line coverage is 100% because these lines run at source time. | Add a committed fixture directory containing one or more empty `*.sln` files. Assert `list_root_solution_files` on it, and assert the derived `SOLUTION_FILE` and `REPO_ROOT` by re-running the top-level assignments in a subshell with that fixture as the working directory. | Line coverage does not show that the listing is correct; AC-42 is met because it names the discovery function as an accepted test seam. | Code inspection of C824-1..C824-15. |
| Info | `scripts/dev-tools/KcovFunctionCoverageGate.ps1` | line 26 | CR-4: `Set-StrictMode -Version Latest` at file scope applies to the scope that dot-sources the file, both in the workflow step and in the Pester suite. | Optionally move strict mode inside each function, or document the effect. | Unexpected strict mode in a caller can surface errors unrelated to the gate. | Code inspection. |
| Info | `tests/shell/test_codex_web_setup_codex_copy.bats` | lines 146, 159, 172-173 | CR-5: shellcheck reports SC2329 and SC2034 for stubs and variables consumed through `run`. This is the usual bats false-positive pattern, and `.bats` files are outside the shell-QC discovery roots. | None required; add directives if the file is brought into shell-QC discovery. | Recorded for completeness. | `shellcheck tests/shell/test_codex_web_setup_codex_copy.bats` (reviewer, WSL). |
| Info | `.claude/hooks/hook-command-invocation.ps1` (four copies) | lines 180, 214 | CR-6: A text grep for `Test-CommandLineRawInvocation` inside `Resolve-CommandLineInvocation` returns two lines. One is the comment-help sentence that AC-22 requires, and the other is the single call. AC-1 holds on the call site, as the executor's AST check also records. | None. | Disambiguates the AC-1 grep wording. | `grep -n` and `evidence/qa-gates/r2-ac1-ac2.2026-10-03T16-23.md`. |
| Info | `.claude/hooks/hook-command-raw-invocation.ps1` | `Test-CommandLineRawInvocation` | CR-7: The reviewer probed the promotion hook with 20 spellings on both runtimes. Head allows four texts that the merge base denied: `gh-issue create`, `gh issue create_`, a backslash-t joined word, and `"high-priority issue: gh-cli create-new"`. None of the four is an executable `gh issue create` invocation, because each fuses a word with a hyphen or word character. No real-invocation regression was found. | None. | Confirms the classifier change removes false positives without losing real invocations in the probed set. | Reviewer probe through `Invoke-PromotionMcpOnlyDecision` (Claude envelope and Codex mapped envelope). |

Two Blockers (CR-1 autonomous; CR-2 awaiting CI).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Classification is one closed rule. A whole-token occurrence is also a substring occurrence, so the R2 classification set at head is a subset of the merge-base set. No executable `gh issue create`, `gh pr create`, or `git worktree remove` spelling that the merge base classified was found unclassified at head (CR-7).
- The reproduction, AC-6, AC-18, AC-20, AC-21, and the Addendum 1 reproduction remain allowed; the accepted residual (`pwsh -c 'Write-Output "create an issue with gh"'` denied) behaves as the spec records.
- The `NoOperand` allow branch is gone; X1-X10, A824-WT6, and A824-WT11 deny on all three gates (reviewer run).
- `KcovFunctionCoverageGate.ps1` separates pure decisions from file reads, throws on ambiguous input, and is fully covered (63/63).
- Mirror parity holds: one SHA-256 per four-copy group for both shared modules, and the two setup-script copies are byte-identical.

#### API and safety notes

- The operand reader proves only that the matches it could read agree. It does not prove that every removal in the command was read (CR-1). A whole-command rule is needed: every classifying segment, and every match within it, must yield the same literal operand.
- A pre-existing gap with the same shape exists on the structural path. `git worktree remove B && git worktree remove A` is allowed at both the merge base and head, because the structural reader also reads the first classifying segment only. This is not a regression. The CR-1 fix (2) closes it if it counts structural segments too.

### Bash implementation audit

- `set -euo pipefail` is preserved. The new functions are pure apart from `find` and `pwd`. `select_solution_file` uses `LC_ALL=C sort`, and C824-6 discriminates C order from locale order.
- Sourcing still runs the top-level assignments, which call `find` on the script-relative root. This is side-effect free and is how kcov records the top-level changed lines.
- `find -printf` is GNU-specific. The script targets Codex Web on Linux (carried note).

### Workflow audit

- The new Measure step uses the same kcov include-pattern approach as the reviewer's local run, which produced `merged/kcov-merged/cov.xml`. The Gate step's arguments match the reviewer's call, which exited 0.
- `BASE_SHA` is empty on push and `workflow_dispatch` runs. The gate then prints `CHANGED-LINES=NOT-CHECKED` and still passes, so changed-line gating happens on pull-request runs only. This is documented in the plan and in `evidence/other/r2-ac-checkoff.2026-10-03T16-41.md`.

### Python implementation audit

- No Python file changed in cycle 2; 148 reviewer-run cases pass.

---

## Test Review

- 861 Pester tests in the 31 suites that target a changed file pass. The bats suite passes 15/15, and 148 Python cases pass.
- The negative controls A824-WT3 and N824-1 still assert that containment is true while the decision allows.
- Missing scenarios: commands that combine an authorized operand with a second removal (CR-1); a non-empty `list_root_solution_files` listing and the top-level discovery wiring (CR-3).

---

## Verification Commands (reviewer)

- Base-versus-head probe: Pester containers that dot-source each hook from the merge-base archive and from the worktree and print one decision per command (session scratchpad).
- `Invoke-Pester` on 31 suites with scoped coverage of the 10 changed production files: 861 passed, 0 failed; changed-line coverage complete.
- `Invoke-Formatter` (check-only) and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 0 drift and 0 findings over 40 files.
- WSL Ubuntu: `bats` 15/15; `kcov` 43 scoped to the setup script, then `Invoke-KcovFunctionCoverageGate` with the base diff, giving exit 0 and `UNCOVERED-CHANGED=NONE`; `shellcheck`, `shfmt -d`, `bash -n` clean.
- `poetry run python -m pytest` on 6 files: 148 passed.
- `sha256sum` over the shared modules, mirrors, and setup-script copies: parity holds.
