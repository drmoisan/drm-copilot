# Code Review: Token-aware R2 matcher, worktree-gate operand resolution, and #823 follow-ups (#824)

---

**Review Date:** 2026-10-03
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Feature Folder Selection Rule:** Only active feature folder changed on the branch; its suffix matches issue 824 in the branch name.
**Base Branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head Branch:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `c7b78cd2ea8c5a0bd010f0424f54498b7802597c`
**Review Type:** Reaudit after remediation cycle 1 (pass 2)

---

## Executive Summary

Remediation cycle 1 (commit c7b78cd2) made five changes:

- It extended the R2 matcher with a backslash-newline separator and an absorption form, in which one expansion or splat token stands in for the remaining subcommand elements.
- It restricted an expansion in the command position to texts that also contain the command word token-bounded.
- It added a raw operand reader, `Get-CommandLineRawInvocationOperand` and `Resolve-CommandLineWrappedInvocationOperand`.
- It wired that reader into the epic and parallel worktree-removal gates (Claude) and the Codex epic gate, as owner Addendum 1 requires.
- It delivered the #823 follow-ups: a threshold-precedence resolver for the feature-review coverage hook, neutral product names, a solution-neutral `msbuild` command, the step 8 wording, and the per-metric fallback sentence.

The pass-1 blocker forms B1-B5 are now denied on both runtimes, and the pass-1 advisory false positive (CR-2 of pass 1) is fixed. Tests, format, analyze, Python checks, and mirror parity all pass in reviewer re-runs.

The reviewer repeated the base-versus-head probe through the real decision entry points, with a control that is denied at both commits. It found two new regression classes.

The first is in the gates. A wrapped `git worktree remove` whose operand the reader cannot read is now classified `NoOperand`, and each gate allows it. Seven real removals are denied at the merge base and allowed at head on both Claude gates; three of them were also confirmed on the Codex gate.

The second is in the matcher. Four wrapped `gh issue create` forms that use positional parameters or `xargs` are denied at the merge base and allowed at head on both runtimes.

A third blocking item is the untested bash change in `.codex/codex-web-setup.sh`.

**What changed:**
- `hook-command-raw-invocation.ps1` (both runtimes, 109 to 298 lines): absorption form, command-position guard, operand reader, wrapped-operand resolver.
- Three worktree-removal gates: 7 added lines each, using the wrapped operand and allowing on `NoOperand`.
- `validate-feature-review-coverage.ps1` plus the new `feature-review-coverage-thresholds.ps1`.
- Policy, skill, agent, and instruction text; `.codex/codex-web-setup.sh`; mirrors and manifests; 19 Pester suites; 2 Python test files.

**Top 3 risks:**
1. Real worktree removals pass all three worktree-removal gates when the operand follows a redirection or PowerShell subexpression, or comes from `xargs` (CR-1).
2. Wrapped `gh issue create` through positional parameters or `xargs` passes the promotion hook on both runtimes. The same shared matcher gap applies to every R2 caller (CR-2).
3. The bash solution-discovery change has no test or coverage measurement (CR-3).

**PR readiness recommendation:** **Needs Revision.** CR-1 and CR-2 are verified enforcement regressions in hard-deny hooks; CR-3 is a coverage-policy gap on a changed production file.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/hook-command-raw-invocation.ps1` (and `.codex` copy and mirrors); `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | `Get-CommandLineRawInvocationOperand` lines 235-253; gate lines 364-366 (epic), 370-372 (parallel), 134-136 (Codex) | CR-1: The operand reader reads a token with `^[^\s;&(pipe)<>()]*`. It reports `NoOperand` when that token is empty, and the gates then allow. The token is empty when the operand follows a redirection or a PowerShell subexpression, and when `xargs` supplies the operand after the matched text. Seven commands that remove a worktree are denied at the merge base and allowed at head: X1 `bash -c 'echo P (pipe) xargs git worktree remove'`; X2 the same without the wrapper; X3 `pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'`; X4 `bash -c 'git worktree remove >/dev/null P'`; X7 `pwsh -c 'git worktree remove --force (Get-Item P)'`; X8 `bash -c 'printf "%s" P (pipe) xargs git worktree remove --force'`; X10 `bash -c 'git worktree remove </dev/null P'`. Here P is `/repo/worktrees/item-a-101` and (pipe) is the shell pipe character. | Make the reader fail closed. Report `Indeterminate`, not `NoOperand`, when the next non-separator character is `(`, `<`, `>`, `@`, or a digit followed by `>`, and when the matched invocation is the argument of `xargs` or `find -exec`. Alternatively, skip a redirection and its target before reading the operand. Report `NoOperand` only when the match is followed by end of text, a closing quote then end of text, `;`, `&`, a pipe, `#`, `)`, or a newline. Add Issue824-tagged deny rows for X1, X2, X3, X4, X7, X8, X10 in the three gate suites, and keep A824-WT6 (bare `git worktree remove` allowed) green. | Each gate protects active worktrees. Addendum 1 permits allowing a match that names no operand because that combination signals a false positive. In these seven commands an operand is present, so allowing them is a detection regression, contrary to issue requirement 4 ("Do not weaken detection of real bypasses"). | Reviewer probe: `git archive f6ef5b2f` of `.claude/hooks`, `.claude/lib`, `.codex` into the session scratchpad. Calls went through `Invoke-EpicWorktreeRemovalGateDecision` and `Invoke-ParallelWorktreeRemovalGateDecision`, with the checkpoint naming a different worktree. All seven are denied at base and allowed at head on both Claude gates. X1, X3, X4 were also run through `Invoke-CodexWorktreeRemovalDecision` and are denied at base and allowed at head. The control `bash -c "git worktree remove P"` is denied at both. |
| Blocker | `.claude/hooks/hook-command-raw-invocation.ps1` (and `.codex` copy and mirrors) | `Get-CommandLineRawInvocationPattern` lines 67-69 (`$expansion`, `$absorber`); absorption form lines 152-161 | CR-2: The expansion and absorber grammar accepts `$name`, `${...}`, `$(...)`, backtick spans, `@name`, and `@(...)`, but not positional or special parameters (`$1`..`$9`, `$@`, `$*`). It has no form for a command word that is the last argument of `xargs`. Four wrapped invocations that raw containment denied are allowed at head: Y1 `bash -c 'gh "$@"' _ issue create`; Y2 `bash -c 'gh $*' _ issue create`; Y3 `bash -c 'echo issue create (pipe) xargs gh'`; Y5 `bash -c 'gh $1 $2' _ issue create`. | Add `\$[0-9@*#]` and `\$\{[0-9]+\}` to the expansion and absorber alternatives. Add an `xargs` form: `xargs`, an option run, the literal command word, then end of command, accepted when every subcommand literal occurs token-bounded in the raw text. Add Issue824-tagged unit rows and promotion deny rows for Y1, Y2, Y3, Y5 on both runtimes. Keep the reproduction, AC-6, and the CR-2 (pass 1) allow rows green. | The promotion hook hard-denies on R2, and AC-14 states that detection of real bypasses that raw containment caught is not weakened. This is the same regression class as pass-1 CR-1. The same shared matcher serves the pr-author, worktree, validate-bash, preimplementation, and merge-gate callers. | Reviewer probe through `Invoke-PromotionMcpOnlyDecision` with the Claude envelope and the Codex mapped envelope: Y1, Y2, Y3, Y5 are denied at base and allowed at head on both runtimes. The control `gh issue create --title x` is denied at both. `pwsh -c '& gh $args' issue create` is denied at head (absorbed by `$args`). |
| Blocker | `.codex/codex-web-setup.sh` (and bundled mirror) | lines 9-16 (`compgen -G`, `SOLUTION_FILE`), 268-271, 294 | CR-3: New behavior, namely solution-file discovery, the skipped restore when no solution exists, and the `fail` in `verify_windows_visual_studio_task_capability`, has no test. No coverage measurement exists, because `.codex/` is outside the shell-QC discovery roots. The existing `tests/shell/test_codex_web_setup_*.bats` source `.github/codex/codex-web-setup.sh`, a separate copy. | The `.codex` copy calls `main "$@"` unconditionally (line 394), so first make it safe to source: add the `BASH_SOURCE` guard that the `.github/codex/` copy carries, or isolate discovery in a callable function. Then add bats tests that drive the changed branches against `.codex/codex-web-setup.sh`: no `.sln`, one `.sln`, several `.sln` (first by `LC_ALL=C` order), restore skipped with the warning, and verification failing with the message. Use committed fixture directories, or refactor discovery into a function that takes a directory listing, so that no temporary file is created. Record a kcov line-coverage measurement of the changed lines under `evidence/qa-gates/`. | `.claude/rules/general-unit-test.md` requires tests for changed behavior and line coverage for bash (kcov); every changed language needs an explicit coverage verdict. | `git diff origin/main...HEAD -- .codex/codex-web-setup.sh`; grep of `tests/shell/` for `sln` and `SOLUTION` finds nothing; `evidence/qa-gates/r1-sh-syntax.2026-10-03T13-41.md` records a syntax check only. |
| Minor | `.claude/hooks/feature-review-coverage-thresholds.ps1` | lines 50-58 | CR-4: The resolver takes the first percentage on the same line after "line coverage" or "branch coverage". A narrative sentence in a consumer `CLAUDE.md` such as "line coverage fell from 92% to 70%" would set the line threshold to 92. | Optionally require a comparator (`>=`, `at least`, `minimum`, `threshold`) between the phrase and the figure, and add a row for a narrative sentence. | Root `CLAUDE.md` files are prose; the heuristic can misread them. | Code inspection of the documented pattern. |
| Minor | `.claude/hooks/hook-command-raw-invocation.ps1` | lines 239-241 | CR-5: A quoted operand containing a space (`bash -c 'git worktree remove "/repo/my wt"'`) is read as `/repo/my`. With an authorizing record for `/repo/my wt`, the removal is denied. The direction is fail-closed. | Optionally read a quoted token up to its matching quote. | False deny only; recorded for completeness. | Code inspection of the token pattern. |
| Info | `.codex/codex-web-setup.sh` | line 16 | CR-6: `find -printf` is GNU-specific. The script targets Codex Web (Linux), so this is acceptable. | None required. | Portability note. | Code inspection. |
| Info | `.claude/rules/typescript.md`, `.claude/rules/csharp.md` (and bundled copies) | typescript.md line 57; csharp.md lines 5, 10 | CR-7: `typescript.md` still refers to "the No-COM architecture assertions" in `architecture-boundaries.md`, whose heading is now "Host-Neutral Architecture Rules". `csharp.md` names No-COM. Neither file is in the FU-823-2 listed set, and rule edits beyond that set are not authorized. | Record a follow-up for the owner. | Cross-reference is now stale in pushed text. | `git grep -n -E "TaskMaster(pipe)No-COM"` over `.claude/rules` and the bundle. |
| Info | `.codex/hooks/validate-feature-review-coverage.ps1` | lines 23-24, 195, 200, 280 | CR-8: The Codex copy of the coverage hook still uses a fixed 80% floor and no threshold precedence. FU-823-1 named only the `.claude` hook. | Record a follow-up. | Runtime drift between the Claude and Codex review gates. | Grep of the Codex hook. |
| Info | `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/spec.md` | AC-14 | CR-9: AC-14 was checked off by the executor after cycle 1. CR-1 and CR-2 contradict its general clause, so the reviewer grades it PARTIAL and has unchecked it again. | Re-check AC-14 after CR-1 and CR-2 are remediated and reaudited. | Keeps the AC source consistent with verified behavior. | Feature audit AC-14 row. |

Three Blockers (CR-1, CR-2, CR-3).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- B1-B5 and the pass-1 CR-2 false positive are fixed and pinned by Issue824 rows on both runtimes (reviewer probe confirms deny for B1-B5 and allow for the CR-2 forms).
- The absorption form requires every remaining subcommand literal to occur token-bounded, so the #824 reproduction and AC-6 still allow.
- `Resolve-CommandLineWrappedInvocationOperand` returns `NotApplicable` for Unbalanced segments and structural matches, so R1 stays fail-closed and the structural operand reader is unchanged.
- An `Indeterminate` operand (expansion or absorption match, a `$` or backtick in the token, an unknown option, or more than one distinct operand) keeps the existing deny path.
- The threshold resolver is pure, documented, and fully covered. The hook docstring now matches its behavior.
- All `.claude`, `.codex`, `.agents`, and `.github` canonical files are byte-identical to their bundled mirrors (reviewer `cmp` over 24 files; one SHA-256 per four-copy group).

#### API and safety notes

- `NoOperand` is treated as proof that nothing is removed. The reader cannot establish that: it stops at characters that do not end a shell argument list (`(`, `<`, `>`), and it does not consider an operand supplied by `xargs` (CR-1).
- The matcher remains a set of recognized spellings. Each review pass has found further spellings that raw containment caught. A closed alternative with a smaller false-negative surface is token-bounded unordered presence: the command word and every subcommand literal each occur token-bounded somewhere in the raw text. It still rejects the #824 and Addendum 1 reproductions, AC-6, AC-18, AC-20, and AC-21, because none of those texts contains every word token-bounded. However, AC-1 requires an "order-preserving sequence match", so adopting it needs the owner's agreement. It is recorded as an option, not a requirement.
- `Test-LanguageCoverageRow` gains `-LineFloor` and `-BranchFloor` with defaults equal to the previous constants, so existing callers are unaffected.

### Bash implementation audit

- `set -euo pipefail` is preserved. `compgen -G` sits inside an `if !` test, and the `find` pipeline exits 0 when nothing matches, so the discovery cannot abort the script.
- When no solution exists, the restore step now warns and returns, where it previously ran `nuget restore` on a missing file. `verify_windows_visual_studio_task_capability` now fails with an explicit message. This behavior change is reasonable but untested (CR-3).

### Python implementation audit

- `test_push_down_issue_824_follow_ups.py` pins FU-823-2, FU-823-3, FU-823-5, and review note A over 36 listed copies, plus a scan of the pushed roots for `TaskMaster.sln`. Two self-tests prove the scans can fail.
- `coverage_threshold_context` narrows the retired-figure scan to paragraphs that mention coverage (review note B), with a discriminating test.
- Black, Ruff, and Pyright are clean. One `S105` suppression on a test-fixture constant carries a justification.

### Documentation and policy text

- Canonical `.github/instructions/` edits are limited to the `msbuild` lines authorized for FU-823-3. `.claude/rules/` edits are limited to the owner-listed file (FU-823-2) and the review-note-A sentences. The callout for the PR body is recorded in `evidence/other/r1-canonical-edit-callout.2026-10-03T13-44.md`.
- The per-metric fallback wording is consistent across the rule, skill, agent, and hook copies (reviewer grep: every file that carries the precedence wording carries the fallback statement).

---

## Test Review

- 486 tests in the 19 changed suites pass (224 Issue824-tagged); 148 Python cases pass.
- The negative controls (A824-WT3 with `Test-CommandLineRawContainment` true; N824-1) discriminate: each asserts containment is true while the decision allows.
- Missing scenarios: redirection or subexpression before a worktree operand, `xargs`-supplied operands (CR-1); positional parameters and `xargs`-led `gh` (CR-2); the bash solution-discovery branches (CR-3).

---

## Verification Commands (reviewer)

- Base-versus-head probe: Pester container dot-sourcing each hook from the merge-base archive and from the worktree, printing one decision per command (session scratchpad).
- `Invoke-Pester` on the 19 changed suites: 486 passed, 0 failed.
- `Invoke-Formatter` (check-only) and `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: 0 drift, 0 findings over 28 files.
- `poetry run pytest` (6 files): 148 passed; `black --check`, `ruff check`, `pyright`: clean.
- `sha256sum` and `cmp` over canonical files and mirrors: parity holds.
- JaCoCo and lcov re-parse: PowerShell 85.46% repo-wide; Python 93.63%.
