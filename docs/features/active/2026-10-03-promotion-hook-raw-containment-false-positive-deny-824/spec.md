# promotion-hook-raw-containment-false-positive-deny (Spec)

- **Issue:** #824
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-03T14-45 (revision for remediation cycle 2; see `### Cycle 2 design decision` under `## Proposed Fix`)
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source)
- **Research:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/research/research.2026-10-03T08-30.md`

## Context
`.claude/hooks/enforce-promotion-mcp-only.ps1` denies read-only wrapped `pwsh` commands whose raw text merely contains the letters "gh", "issue" and "new" anywhere. The raw-containment fallback in `.claude/hooks/hook-command-invocation.ps1` is documented as loose, on the basis that a false positive only forces a checkpoint check. The promotion hook turns that loose match into an unconditional deny with no checkpoint check and no escape path.

Research established that the defect is in the shared helper, not in the promotion hook. `Resolve-CommandLineInvocation` (rule R2, `hook-command-invocation.ps1:202-205`) classifies any wrapper-led or live-substitution segment as an invocation when `Test-CommandLineRawContainment` (`:92-117`) finds the command word and every subcommand element as ordinal, case-insensitive substrings of the raw segment text. Word boundaries, order, and adjacency are not checked. The `.codex` copy is identical. Every hook that calls the resolver family inherits R2 (research section 3).

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (PowerShell hooks)
- Command/flags used: Bash tool command routed through the PreToolUse hook
- Data source or fixture: main at 93725814

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Send this read-only Bash command, which invokes no `gh`, through the PreToolUse hook:
   `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'`
2. Observe the hook decision.

Expected:
Allow. Only an actual `gh issue create|new` invocation, or a genuinely unresolvable segment, is denied.

Actual:
Deny with PROMOTION_MCP_ONLY_BLOCKED (gh issue creation reason).

Trace (research section 2.4): the command is one wrapper-led segment, so `ScanText = RawText`. The promotion hook's adjacency regex (`enforce-promotion-mcp-only.ps1:116-120`) does not match. R2 matches because `gh` is a substring of `through`, `issue` occurs literally, and `new` is a substring of `New-Object`. `Test-CommandLineInvocation` returns true and the hook returns the gh-issue deny reason (`:126-129`).

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PROMOTION_MCP_ONLY_BLOCKED`

## Scope & Non-Goals
- In scope:
  - Replacing R2 raw containment with a token-aware, whole-token, order-independent match in the shared helper on both runtimes (`.claude/hooks`, `.codex/hooks`).
  - Making the worktree-removal gates fail closed when a classified wrapped removal has no extractable literal target operand (cycle 2 design decision).
  - Making `.codex/codex-web-setup.sh` safe to source and covering its changed lines with bats tests measured by kcov (review pass 2, finding R3).
  - Auditing every hook that reaches R2 through the resolver family, recording the audit, and adding false-positive regression tests per affected hook family.
  - Correcting the documented contract of `Test-CommandLineRawContainment` and the related comments.
  - Keeping the bundled mirrors under `extensions/drm-copilot/resources` and the pack manifests in parity.
- Out of scope / non-goals: see `## Non-Goals / Follow-ups`.
- Explicitly excluded systems, integrations, or datasets: no change to hook registration, `.claude/settings.json`, or any hook entry-point decision logic other than optional comment updates.

## Root Cause Analysis
- R2 uses unordered, unbounded substring containment as a classification signal. That signal was documented as safe because "a false positive only forces a checkpoint check" (`hook-command-invocation.ps1:29`, `:98-99`).
- The documented contract holds for two caller families (preimplementation gate, epic merge gate) and is false for four (research section 3):
  - promotion hook: unconditional deny;
  - pr-author `gh pr create` Case B: `PR_AUTHOR_SKILL_BLOCKED`;
  - epic and parallel worktree-removal gates: R2 returns `OperandIndex = -1`, no path resolves, and every allow predicate rejects a null path;
  - `validate-bash`: returns a denylist literal when a `-f`, `--force`, or `--hard` token is present outside the quoted argument.
- An atomic plan's read-only phrase-count verification command was blocked twice in one plan. Plans may not reword commands to avoid a hook, so each block required a maintainer-approved one-time bypass.

## Proposed Fix

### Design summary (what changes where):
Research Option A. Introduce a pure function `Test-CommandLineRawInvocation` in a new shared module `hook-command-raw-invocation.ps1` under each hooks root. `hook-command-invocation.ps1` dot-sources it, and R2 calls it instead of `Test-CommandLineRawContainment`. R1 (Unbalanced), R3 (structural), R3a (unmodeled option), all public signatures, and every hook caller remain unchanged.

Matcher (cycle 2, supersedes the ordered sequence grammar of research section 8): applied case-insensitively to the segment `RawText`, including the contents of a quoted `-Command` / `-c` argument. A segment classifies as an invocation of `CommandWord` + `SubcommandPath` when the command word and every subcommand element each occur somewhere in the raw text as a whole token, that is, each word matches `(?i)(?<![\w-])<word>(?![\w-])` (with `<word>` regex-escaped). Order, adjacency, and the number of occurrences are not checked. Path-qualified, `.exe`, quoted, and escaped-quote spellings of the command word match because `/`, `\`, `.`, `"` and `'` are not in `[\w-]`. Expansion-carried forms (`bash -c 'x=create; gh issue $x'`, `bash -c 'c=gh; $c issue create'`, `cmd="issue create"; gh $cmd`) match because each word also occurs literally elsewhere in the text.

### Cycle 2 design decision
Recorded by the orchestrator for remediation cycle 2 after review pass 2 (`remediation-inputs.2026-10-03T13-56.md`, `code-review.2026-10-03T13-56.md`).

1. **Classification on the wrapper-led / substitution (R2) path is a whole-token, order-independent match** (definition above), replacing the order-preserving sequence grammar used in the initial implementation and in cycle 1.
   - Rationale: two review passes found real bypass forms that substring containment caught and every ordered-grammar revision missed: multi-word variables, splats, and bash arrays (pass 1, B1-B3, B5); positional and special parameters `$@`, `$*`, `$1`, and `xargs`-led invocations (pass 2, Y1-Y5); and operands supplied through `xargs`, `Join-Path` or `Get-Item` subexpressions, and redirections (pass 2, X1-X10). Each revision of the ordered grammar added recognized spellings, and each subsequent pass found more.
   - Detection relative to the earlier matchers: the whole-token match detects every text that the ordered matcher detects when every word occurs literally in the text. It does not detect a text in which a command or subcommand word occurs only through an expansion (for example `gh issue $x` with `x` set outside the text); the ordered matcher's expansion tier detected that form, and raw containment at the merge base did not. Relative to the merge-base raw containment, the whole-token match loses only texts that containment also failed to detect, because a whole-token occurrence is also a substring occurrence.
   - False positives removed: it rejects the substring matches in both reproductions (`through`, `New-Object`, `.claude/worktrees/`, `Remove-Item`) and in the AC-6, AC-18, AC-20, and AC-21 fixtures, because none of those texts contains every word as a whole token.
   - Requester alignment: the issue gives `(?i)(?<![\w-])gh\s+issue\s+(?:create|new)\b` as an example of a token-aware match ("for example"). The "order-preserving" qualifier was introduced by this spec, not by the requester.
   - Accepted trade: a wrapped payload that only mentions the command, but names every command word as a whole token in any order (for example `pwsh -c 'Write-Output "create an issue with gh"'`), is classified and therefore denied by hard-deny callers. Raw containment at the merge base denied the same text. See `## Risks & Mitigations`.

2. **Worktree-removal gates fail closed when the target operand cannot be extracted.** On the Claude epic and parallel worktree-removal gates and the Codex epic worktree-removal gate, a removal classified on the R2 path is gated on its operand only when the wrapped-operand resolution yields exactly one literal operand; every other outcome (no operand, an operand the reader cannot read, more than one distinct operand, an expansion-sourced operand, or no ordered match from which to read) is denied, with or without a checkpoint record.
   - This reverses the cycle-1 rule that allowed a classified wrapped removal with no operand (`NoOperand`). Review pass 2 (R1) showed real removals reaching that branch (X1, X2, X3, X4, X7, X8, X10).
   - With whole-token classification, the Addendum 1 false-positive signature (`.claude/worktrees/`, `Remove-Item`) is no longer classified and no longer reaches the empty-operand branch, so AC-30 continues to hold.
   - This is a deliberate trade against Addendum 1 required change 2 ("a containment match with no extractable operand must not deny unconditionally"), made in favour of issue requirement 4 ("Do not weaken detection of real bypasses"). The PR body must call out this trade.
   - Expansion-sourced operands continue to fail closed. The five AC-31 literal forms keep today's gating (denied without an authorizing checkpoint, allowed with one).
   - Test consequence: the cycle-1 `A824-WT6` rows ("allows a wrapped removal that names no operand") in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` (Claude), and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex) change their expected decision from allow to deny under this decision. This is a specified behaviour change, not an assertion edit to make a failing test pass. The AC-16 and AC-29 restrictions on assertion edits apply to the research section 6.1 pins and the signature pins, which are unaffected.

### Boundaries and invariants to preserve:
- R1 Unbalanced classification is evaluated before R2 and still returns a match (fail-closed).
- R2 still returns `OperandIndex = -1`. A real wrapped `git worktree remove` is gated by the worktree gates on its wrapped operand only when exactly one literal operand is extracted, and is otherwise denied (cycle 2 design decision 2). Real wrapped invocations still reach the merge and preimplementation checkpoint checks.
- No R2 classification and no non-literal operand outcome is routed to an allow.
- The promotion adjacency regex and the `gh api` lookahead regex are not modified.
- Public signatures pinned by `hook-command-invocation.Tests.ps1:300-328` (both surfaces) do not change.
- `.claude` and `.codex` copies of the shared helper and new module are content-identical.

### Dependencies or blocked work:
None.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
1. `.claude/hooks/hook-command-raw-invocation.ps1` (new)
2. `.codex/hooks/hook-command-raw-invocation.ps1` (new, identical)
3. `.claude/hooks/hook-command-invocation.ps1` (dot-source, R2 predicate, comments)
4. `.codex/hooks/hook-command-invocation.ps1` (identical edit)
5. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1` (new mirror)
6. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1` (mirror)
7. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1` (new mirror)
8. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1` (mirror)
9. `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (add new module path)
10. `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (add new module path)
11. `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` line 30 (append module name to `SharedModuleNames`; no new lines)
12. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`, `.codex/hooks/enforce-epic-worktree-removal-gate.ps1`, and their bundled mirrors (cycle 2: fail closed on any non-literal operand outcome)
13. `.codex/codex-web-setup.sh` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` (cycle 2: safe to source; byte-identical)
14. New bats test file(s) under `tests/shell/` that source `.codex/codex-web-setup.sh`, plus any committed fixture directories under `tests/fixtures/` (cycle 2, AC-42)

Optional: comment-only updates to `enforce-promotion-mcp-only.ps1:122-125` on either surface, mirrored if made. Optional: move `Test-CommandLineRawContainment` into the new module.

#### Functions/classes/CLI commands impacted:
- New: `Test-CommandLineRawInvocation` (plus an optional pattern-builder helper).
- Changed: `Resolve-CommandLineInvocation` (R2 predicate only).
- Retained for operand extraction only (cycle 2): `Get-CommandLineRawInvocationOperand` and `Resolve-CommandLineWrappedInvocationOperand`. Classification no longer depends on them; any outcome other than a single literal operand is denied by the gates.
- Changed (cycle 2): the wrapped-operand branch of `Invoke-EpicWorktreeRemovalGateDecision`, `Invoke-ParallelWorktreeRemovalGateDecision`, and `Invoke-CodexWorktreeRemovalDecision` no longer allows `NoOperand`.
- Unchanged signature, changed behaviour through R2: `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, `Test-CommandLineFlag`.
- Retained: `Test-CommandLineRawContainment`, used only by the informational `Test-CommandLineMention`.

#### Data flow and validation changes:
Wrapper-led and live-substitution segments are classified as an invocation only when the raw text contains the command word and every subcommand element as whole tokens, in any order. Substring presence (a word embedded in a longer word or hyphenated name) no longer classifies.

#### Error handling and logging updates:
No change to deny reason strings or logging.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the R2 predicate; the negative-control tests will fail on that revert, which is intended.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
`Test-CommandLineRawInvocation -RawText <string> -CommandWord <string> -SubcommandPath <string[]>` returns `[bool]`. Pure; no I/O.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
All existing wrapper deny pins (research section 6.1) use spellings in which every word occurs as a whole token and remain green without edits. The test title on each surface that was renamed under AC-16 now reads "... as a token-aware ordered sequence"; under cycle 2 it is renamed again so that it does not assert order, with its assertions retained. `-Because` messages and `.DESCRIPTION` text that describe an ordered sequence may be reworded without changing any asserted value. The `A824-WT6` expected decision changes as recorded in `### Cycle 2 design decision`.

#### Performance constraints (latency/throughput/memory):
The matcher evaluates one regex per word consisting of a literal between a fixed-width lookbehind and lookahead, with no quantifiers, so each evaluation is linear in the raw text length. No numeric latency target is set.

## Assumptions, Constraints, Dependencies
- Assumptions: hook decision seams (`Invoke-PromotionMcpOnlyDecision`, `Get-PrAuthorBypassReason`, `Get-BlockedPatternMatch`, `Test-ImplementationCommand`, worktree-gate decision functions) accept literal command strings and run in-process without `gh`, network, clock, or temporary files.
- Constraints: 500-line cap. `hook-command-invocation.ps1` is 483 lines on both surfaces and `legacy-codex-hook-contracts.Tests.ps1` is 497 lines; the matcher must live in the new module.
- External dependencies: none. A repo-side change does not alter what an installed extension pushes down until it is rebuilt and reinstalled (release concern only).

## Data / API / Config Impact
- User-facing or API changes: fewer false-positive denies; no new deny reasons.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: one new dot-sourced shared module per runtime, listed in each pack manifest. Hook registration counts in `codex-bundle-hook-probe.Tests.ps1` are unaffected.

## Test Strategy
All new Pester `It` blocks added for this issue carry `-Tag 'Issue824'` so they can be selected with `Invoke-Pester -TagFilter Issue824`. Tests follow Arrange-Act-Assert, use pure seams, and create no temporary files.

- Unit tests: new `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1` and `tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1`.
- Negative control: in `hook-command-invocation.Tests.ps1` (both surfaces), one fixture for which `Test-CommandLineRawContainment` is true and `Test-CommandLineInvocation` is false, asserted in the same `It`.
- Promotion acceptance matrix: `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` (Claude) and `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (Codex), one `It` per case; deny rows assert the exact reason from `Get-PromotionMcpOnlyGhIssueBlockedReason`.
- Audit regressions: the trigger-scoping suites for pr-author, epic and parallel worktree gates, validate-bash, and the preimplementation gate (both runtimes where the hook exists).
- Parity and contract: the four pytest bundle/manifest contract files and `legacy-codex-hook-contracts.Tests.ps1`.
- Bash (cycle 2, AC-42): bats tests that source `.codex/codex-web-setup.sh`, run under kcov scoped to that file; changed-line coverage recorded under the feature folder `evidence/qa-gates/`; `bash -n` on both copies.
- Fail-before / pass-after (cycle 2): the new AC-14 rows and AC-43 rows are run against the cycle-1 head `c7b78cd2` and recorded as failing, then recorded as passing under `evidence/regression-testing/`.
- Toolchain: `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest` with coverage, followed by the repository toolchain.

## Acceptance Criteria

### Shared matcher correction

- [x] AC-1: In `.claude/hooks/hook-command-invocation.ps1` and `.codex/hooks/hook-command-invocation.ps1`, the R2 branch of `Resolve-CommandLineInvocation` no longer calls `Test-CommandLineRawContainment`; it calls `Test-CommandLineRawInvocation`, defined in the new `hook-command-raw-invocation.ps1` under the same hooks root, which applies a token-aware, boundary-checked, order-independent whole-token match to the segment `RawText`, including the contents of a quoted `-Command` / `-c` argument: the segment classifies only when the command word and every subcommand element each occur, case-insensitively, as a whole token bounded by `(?<![\w-])` and `(?![\w-])`. Verified by Grep: inside `Resolve-CommandLineInvocation` on both surfaces, `Test-CommandLineRawContainment` has no match and `Test-CommandLineRawInvocation` has exactly one match.
- [x] AC-2: No classification or deny decision in any `.claude/hooks` or `.codex/hooks` file is made from `Test-CommandLineRawContainment`; its only remaining caller is `Test-CommandLineMention`. If loose containment is retained for any classification path, that path routes to a checkpoint check and never to an unconditional deny. Verified by Grep for `Test-CommandLineRawContainment` across both hooks roots, which returns only the definition and the `Test-CommandLineMention` call site on each surface.
- [x] AC-3: Fail-closed behaviour for unresolvable segments is preserved: an Unbalanced segment (`echo "unterminated`) is denied by the promotion hook on both runtimes. Verified by an `Issue824`-tagged test in each promotion trigger-scoping suite.
- [x] AC-4: `tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1` and `tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1` exist and pass, with positive cases for: adjacent words; extra whitespace; mixed case; a leading `&`, `;`, `|`, `(`, `"`, `'`, or newline; `/usr/bin/gh`; `C:\tools\gh.exe`; a quoted `.exe` path; escaped quotes `\"gh\"`; `-R x`; `--repo=x`; `-C "a b"`; an unmodeled dash option; an expansion in the command position; an expansion in a subcommand position. Negative cases: `through issue New-Object`; `legit push`; `git worktree list ... removed`; `high priority ... create`; `gh issue newline`; `gh issue list`; an all-expansion sequence `$a $b $c`.

### Promotion hook: must allow

- [x] AC-5: The exact reproduction command `pwsh -NoProfile -Command '$parts = New-Object System.Collections.Generic.List[string]; foreach ($t in @("a phrase that runs through the text", "The call is guarded (issue #1)")) { Write-Output $t }'` is allowed by the promotion hook on both runtimes. Verified by an `Issue824`-tagged test through `Invoke-PromotionMcpOnlyDecision` in `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` (Claude) and `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (Codex).
- [x] AC-6: A wrapped payload containing "through", "issue", and "New-Object" with no `gh issue create|new` token sequence (`pwsh -NoProfile -Command 'Write-Output "through"; "issue"; New-Object Text.StringBuilder'`) is allowed by the promotion hook on both runtimes. Verified by an `Issue824`-tagged test in each promotion trigger-scoping suite.

### Promotion hook: must still deny

Each criterion below is verified by an `Issue824`-tagged test in both `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` (Claude) and `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1` (Codex) that asserts a deny decision and, for the `gh issue` cases, the exact reason returned by `Get-PromotionMcpOnlyGhIssueBlockedReason`.

- [x] AC-7: `gh issue create --title x` is denied.
- [x] AC-8: `gh issue new --title x` is denied.
- [x] AC-9: `GH  Issue  Create` (mixed case, doubled spacing) is denied.
- [x] AC-10: `pwsh -NoProfile -Command 'gh issue create --title x'` is denied.
- [x] AC-11: `pwsh -c "& gh issue new"` is denied.
- [x] AC-12: `bash -c "gh issue create"` is denied.
- [x] AC-13: `gh api repos/o/r/issues -X POST` is denied.
- [ ] AC-14: Detection of real bypasses that raw containment caught before the fix is not weakened: `bash -c "gh -R o/r issue create"`, `bash -c 'x=create; gh issue $x'`, and `bash -c 'c=gh; $c issue create'` are each denied, and `gh --repo o/r issue list` is allowed. The review-pass-2 bypass forms are also denied. By the promotion hook on both runtimes, asserting the reason from `Get-PromotionMcpOnlyGhIssueBlockedReason`: `bash -c 'gh "$@"' _ issue create`; `bash -c 'gh $*' _ issue create`; `bash -c 'echo issue create | xargs gh'`; `bash -c 'gh $1 $2' _ issue create`. By the Claude epic and parallel worktree-removal gates and the Codex epic worktree-removal gate, without an authorizing checkpoint record (verified by `Issue824`-tagged tests in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`): `bash -c 'echo /repo/worktrees/item-a-101 | xargs git worktree remove'`; `echo /repo/worktrees/item-a-101 | xargs git worktree remove`; `pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'`; `bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101'`; `pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)'`; `bash -c 'printf "%s" /repo/worktrees/item-a-101 | xargs git worktree remove --force'`; `bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101'`.

### Negative control

- [x] AC-15: `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` and `tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1` each contain an `Issue824`-tagged `It` that, for the reproduction fixture, asserts in the same block that `Test-CommandLineRawContainment` returns `$true` and `Test-CommandLineInvocation -CommandWord 'gh' -SubcommandPath @('issue','new')` returns `$false`. Reverting R2 to substring containment causes this test to fail.
- [x] AC-16: The test titled "classifies a wrapper-led segment whose raw text carries the words in any arrangement" is renamed on both surfaces to describe token-aware whole-token matching without asserting word order, with its assertions retained; every pre-existing wrapper deny pin listed in research section 6.1 passes without edits to its assertions.

### Hook audit and per-hook correction

- [x] AC-17: An audit record exists at `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/other/containment-path-hook-audit.md` naming, for each of the following hooks, its resolver call sites, the effect of an R2 false positive before the fix, and its disposition after the fix: `enforce-promotion-mcp-only.ps1` (Claude, Codex); `enforce-pr-author-skill-helpers.ps1` and `enforce-pr-author-skill.epic-base-branch.ps1` (Claude); `enforce-epic-worktree-removal-gate.ps1` (Claude, Codex); `enforce-parallel-worktree-removal-gate.ps1` (Claude); `validate-bash.ps1` (Claude, Codex); `enforce-orchestration-preimplementation-gate.ps1` (Claude, Codex); `enforce-epic-merge-gate.ps1` (Claude, Codex). The record also states that `enforce-parallel-abandon-gate.ps1` does not reach R2. The call-site inventory cites the research Numeric Derivation Evidence (Claim N1).
- [x] AC-18: The pr-author hook allows `pwsh -NoProfile -Command 'Select-String -Path README.md -Pattern "high priority" | ForEach-Object { "create" }'` (no Case B `PR_AUTHOR_SKILL_BLOCKED`). Verified by an `Issue824`-tagged test in `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`.
- [x] AC-19: The worktree-removal gates allow `pwsh -NoProfile -Command 'git worktree list --porcelain | Select-String -NotMatch "removed"'` and still deny `bash -c "git worktree remove ../x"`. Verified by `Issue824`-tagged tests in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1` (Claude), `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1` (Claude), and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex).
- [x] AC-20: `validate-bash` returns no blocked pattern for `pwsh -NoProfile -f ./scripts/legit-push.ps1`. Verified by `Issue824`-tagged tests in `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` and `tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1`.
- [x] AC-21: `Test-ImplementationCommand` returns `$false` for `pwsh -NoProfile -Command 'Write-Output "digit address"'` and the epic merge gate still routes `bash -c "gh pr merge --merge 688"` to its checkpoint check. Verified by `Issue824`-tagged tests in the preimplementation-gate and epic-merge-gate trigger-scoping suites on both runtimes.

### Documented contract

- [x] AC-22: The description of `Test-CommandLineRawContainment` (`hook-command-invocation.ps1:96-99`), the R2 sentence in the `Resolve-CommandLineInvocation` description (`:172-174`), and the option-table comment (`:28-30`) are corrected on both surfaces so that they no longer claim a false positive only forces a checkpoint check; they state that R2 requires the command word and every subcommand element to occur as whole tokens and name the callers for which a classification is a hard deny. Verified by Grep for `only forces a checkpoint check` across `.claude/hooks`, `.codex/hooks`, and `extensions/drm-copilot/resources`, which returns no match.

### Parity

- [x] AC-23: The `.claude` and `.codex` copies of `hook-command-invocation.ps1` are content-identical, and the `.claude` and `.codex` copies of `hook-command-raw-invocation.ps1` are content-identical. Verified by comparing file hashes (`Get-FileHash`) of each pair.
- [x] AC-24: Each canonical file changed or added under `.claude/hooks` and `.codex/hooks` is byte-identical to its mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, and both `pack-manifests/core.json` files list the new module path. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` passing.
- [x] AC-25: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` lists `hook-command-raw-invocation.ps1` in `SharedModuleNames` on its existing line, the file does not grow beyond 497 lines, and the suite passes.

### Toolchain and limits

- [x] AC-26: `Invoke-PoshQCFormat` leaves no changes, `Invoke-PoshQCAnalyze` reports zero errors, and `Invoke-PoshQCTest` with coverage passes, with line coverage >= 85% on each changed or new PowerShell file under `.claude/hooks` and `.codex/hooks` and no uncovered changed lines relative to the baseline. Evidence is recorded under the feature folder `evidence/qa-gates/`.
- [ ] AC-27: The repository's full toolchain passes on the PR head, including the Windows PoshQC job and the Linux hook-suite Pester job in `.github/workflows/_poshqc.yml`. (CI-dependent; checked off at S9.)
- [x] AC-28: No file changed or added by this issue exceeds 500 lines, including `hook-command-invocation.ps1` and `hook-command-raw-invocation.ps1` on both surfaces and every modified test file. Verified by a line count of each changed file.
- [x] AC-29: The public parameter signatures of `Test-CommandLineInvocation`, `Get-CommandLineOperand`, `Get-CommandLineFlagValue`, and `Test-CommandLineFlag` are unchanged. Verified by the existing signature-pin tests in `hook-command-invocation.Tests.ps1` (both surfaces) passing without edits.

### Remediation cycle 2 additions

These criteria are numbered after the Scope Extension criteria (AC-30 to AC-41) to avoid identifier collisions.

- [x] AC-42: `.codex/codex-web-setup.sh` is safe to source: sourcing it does not run `main` (a `BASH_SOURCE` guard equivalent to the one in `.github/codex/codex-web-setup.sh`, or the changed logic isolated in functions callable alone). `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/codex-web-setup.sh` is byte-identical to it. bats tests that source `.codex/codex-web-setup.sh` (not `.github/codex/codex-web-setup.sh`) cover the lines changed by this issue: solution-file discovery with no `.sln` at the root (`REPO_ROOT` falls back to the working directory and `SOLUTION_FILE` is empty), with one `.sln`, and with several `.sln` files (the first in `LC_ALL=C` order is selected); the restore step skipped with its warning when no solution exists; and `verify_windows_visual_studio_task_capability` failing with its message when no solution exists. The tests create no temporary files; they use committed fixture directories under `tests/fixtures/` or a discovery function that takes its candidates as input. A kcov run scoped to `.codex/codex-web-setup.sh` records line coverage >= 85% for each function that contains a changed line (including any function introduced to hold the discovery logic) and no uncovered changed executable line, under the feature folder `evidence/qa-gates/`. `bash -n` passes on both copies, and neither copy exceeds 500 lines.
- [ ] AC-43: On the Claude epic and parallel worktree-removal gates and the Codex epic worktree-removal gate, a wrapper-led or substitution-segment `git worktree remove` that classifies on the R2 path but does not yield exactly one literal target operand is denied, with or without a checkpoint record. This includes `pwsh -NoProfile -Command 'git worktree remove'` (no operand) and `bash -c 'git worktree remove "$target"'` (expansion-sourced operand). The AC-30 reproduction remains allowed and the AC-31 forms keep their gating. Verified by `Issue824`-tagged tests in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1`, in which the `A824-WT6` rows assert deny as recorded in `### Cycle 2 design decision`.

## Scope Extension

The two addenda below were posted on issue #824 by the repository owner (`drmoisan`) and are added to this spec's acceptance criteria. Their criteria text is copied verbatim from the issue comments; only the AC identifiers are added. The defect descriptions, required changes, and maintainer decisions are in the linked comments.

### Addendum 1: worktree-removal gates

Source: https://github.com/drmoisan/drm-copilot/issues/824#issuecomment-5970085575 (posted 2026-10-03T14:27:16Z by `drmoisan`). Scope: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (and their `.codex` and bundled counterparts where they exist). Required changes: (1) a token-aware match of an actual `git [-C <dir>] worktree remove` invocation on wrapper-led and substitution segments, including the `-Command` / `-c` argument, with Unbalanced segments kept fail-closed; (2) a containment match with no extractable operand (empty target path) must not deny unconditionally; (3) both changes applied to the parallel gate.

Reproduction: `pwsh -NoProfile -Command 'Set-Location -LiteralPath "C:/repo/.claude/worktrees/agent-x"; if (Test-Path -LiteralPath "src/Old.cs") { Remove-Item -LiteralPath "src/Old.cs" -Force }; git status --porcelain -- "src/Old.cs"'`

- [x] AC-30: The reproduction command is allowed by both worktree-removal gates.
- [x] AC-31: These are still gated exactly as today (denied without an authorizing checkpoint, allowed with one): `git worktree remove <path>`; `git worktree remove --force <path>`; `git -C <dir> worktree remove <path>`; `pwsh -Command 'git worktree remove <path>'`; `bash -c "git worktree remove <path>"`.
- [x] AC-32: Pester tests cover each case. They include a negative control that fails if the substring-containment deny path is restored.
- [x] AC-33: The PowerShell toolchain passes.

### Addendum 2: issue #823 follow-ups

Source: https://github.com/drmoisan/drm-copilot/issues/824#issuecomment-5970141337 (posted 2026-10-03T14:34:03Z by `drmoisan`). Source follow-ups file: `docs/features/potential/2026-10-03-issue-823-tier-rule-adoption-follow-ups.md`. Out of scope: FU-823-4 (the extension release); no release automation is run.

Maintainer decisions recorded in that comment:
- FU-823-2: neutralize names only (keep each rule's substance and push-down status).
- FU-823-3: generalize `msbuild TaskMaster.sln` to a solution-neutral form, including the canonical `.github/instructions/csharp-code-change.instructions.md` and `.github/instructions/csharp-unit-test.instructions.md`.

Canonical policy edit authorization: the repository owner authorizes edits to the canonical `.github/instructions/` files for FU-823-3 only (comment 5970141337). No other `.github/instructions/` or `.claude/rules/` change is authorized by this addendum beyond the files the comment lists. The PR body must call out these canonical edits.

- [x] AC-34: FU-823-1: the hook resolves thresholds by the precedence above. Pester tests cover: a root `CLAUDE.md` with lower figures, no figures, and a line-only figure. The docstring matches the behavior.
- [x] AC-35: FU-823-2: no pushed file in the listed set names TaskMaster or No-COM. A test fails if those names reappear in pushed rule or skill files.
- [x] AC-36: FU-823-3: no surface hard-codes `TaskMaster.sln`. A test fails if it reappears. The bundled-payload parity tests stay green.
- [x] AC-37: FU-823-5: step 8 of the workflow refers to the governing thresholds, not fixed 80/90 figures.
- [x] AC-38: Review note A: the per-metric fallback is stated wherever the precedence wording appears.
- [x] AC-39: Review note B: the test asserts only on coverage-threshold context.
- [x] AC-40: The follow-ups file marks FU-823-1, -2, -3 and -5 as resolved by #824, and FU-823-4 as still open.
- [x] AC-41: The full toolchain passes (Python, TypeScript/Jest, and PowerShell format, analyze and test with coverage).

## Non-Goals / Follow-ups
The following pre-existing gaps were identified by research and are not acceptance criteria for #824. They should be filed as follow-up items.

- `gh api` write-surface gaps in the promotion lookahead regex (research section 4): `--method=POST`, `-XPOST`, implicit POST through `-f` / `-F` / `--field` / `--raw-field` / `--input`, a global option between `gh` and `api` (`gh -R x api ...`), and the GraphQL `createIssue` mutation.
- `sudo gh pr create ...`: `sudo` is neither a scanner wrapper nor a transparent wrapper, so R3 does not match and the pr-author hook does not catch the PR form. (The promotion adjacency regex still catches `sudo gh issue create`.)
- Backslash-newline continuation outside quotes (`gh issue \` newline `create`): the tokenizer produces a `\` token, R3 fails, and masked text defeats the adjacency regex.
- `validate-bash` Leg 1 ordinal substring search for multi-word literals in raw-scanned segments (for example `digit push -fx` contains `git push -f`).
- `bash -c "git -C x push --force"` is not blocked by `validate-bash` today.
- Obfuscations that raw containment already missed (`g""h`, `g\h`, `$(printf g)h`) remain undetected; this is not a regression.
- Texts in which a command or subcommand word occurs only through an expansion whose value is set outside the text (for example `bash -c 'gh issue $x'` with `x` from the environment) are not classified by the whole-token match. Raw containment at the merge base did not detect them either; the cycle-1 ordered matcher's expansion tier did. Not a regression relative to the merge base.
- A quoted operand containing a space (`bash -c 'git worktree remove "/repo/my wt"'`) is read only up to the space, so an authorizing record for the full path does not match and the removal is denied (code review pass 2, CR-5). The direction is fail-closed.
- Policy question for the owner (review pass 2, advisory A2): the shell-QC discovery roots in `.claude/rules/shell.md` exclude `.codex/`, while the Coverage Exclusion Policy admits no excluded production file. AC-42 measures the changed lines of `.codex/codex-web-setup.sh` only; whole-file coverage and the discovery-root change are not in scope.
- Review pass 2 advisories A3 (No-COM references in `.claude/rules/typescript.md` and `.claude/rules/csharp.md`), A4 (fixed 80% floor in `.codex/hooks/validate-feature-review-coverage.ps1`), and CR-4 (comparator requirement in the CLAUDE.md coverage-figure resolver).

## Risks & Mitigations
- Technical or operational risks:
  - The token-aware matcher could miss a real wrapped bypass that unordered containment caught. Two review passes found such misses in the ordered sequence grammar (pass 1: B1-B5; pass 2: Y1-Y5).
  - Accepted trade (cycle 2): a wrapped payload that only mentions a command but names every command word as a whole token, in any order, is classified and denied by hard-deny callers (for example `pwsh -c 'Write-Output "create an issue with gh"'` is denied by the promotion hook, and `pwsh -c 'Write-Output "remove the git worktree"'` reaches the worktree gates, which deny it because no literal operand is extracted). Raw containment at the merge base denied the same texts, so this is not a regression; it is a residual false-positive class that the ordered grammar avoided.
  - Accepted trade (cycle 2): a classified wrapped `git worktree remove` with no extractable literal operand is denied even when it removes nothing, which departs from Addendum 1 required change 2. The PR body calls this out.
  - Operand reader gaps (redirections, subexpressions, `xargs`-supplied operands) could otherwise let a real removal through; under cycle 2 design decision 2 every such outcome is denied.
- Mitigations and rollbacks: whole-token classification detects every bypass form in AC-14 because each of them names every word literally; existing wrapper deny pins stay green (AC-16); the negative control (AC-15) prevents silent reversion to substring containment; AC-43 pins the operand fail-closed rule. Rollback is a revert of the R2 predicate and of the gate operand branch.

## Rollout & Follow-up
- Release/rollout steps: merge; the change reaches consumers after the extension is rebuilt, released, and reinstalled.
- Post-fix monitoring or clean-up tasks: file the Non-Goals / Follow-ups items.
- PR body callouts: the canonical `.github/instructions/` edits authorized for FU-823-3, and the cycle 2 trade against Addendum 1 required change 2 (operand-less wrapped removals are denied).
- Links: issue https://github.com/drmoisan/drm-copilot/issues/824; research `research/research.2026-10-03T08-30.md`.
