# preimplementation-gate-blocks-attribution-trailers (Spec)

- **Issue:** #713
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T01-00
- **Status:** Approved (autonomous mode; user instruction 2026-09-26, no further approvals required)
- **Version:** 1.0
- **Work Mode:** full-bug (this file is the authoritative acceptance-criteria source)
- **Complexity band:** C3
- **Research:** `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/research/research.2026-09-27T00-30.md`

## Context

- **Summary.** With no ready per-feature checkpoint, the staging exemption of the preimplementation gate (`Test-ExemptOrchestrationStagingCommand` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`) denies several commit forms that a planner needs in order to write attribution trailers. Planning and housekeeping commits on `parallel/<slug>-plan` branches have therefore landed without `Co-Authored-By` lines.
- **Observed environment.** Windows 11, Claude Code, the parallel run `backlog-2026-09-26` (2026-09-25). The gate evaluates Bash commands only (`.claude/settings.json` matchers), so bash quoting semantics govern.
- **Impact.** Medium. Attribution required by session policy is lost on planning commits. No data loss.
- **Premise correction.** The issue premise is partly stale on the current tree. Issue #663 (PR #700) narrowed D4 row 12 so that `<` and `>` are rejected only outside quotes. A quoted `Co-Authored-By: Name <email>` no longer causes a denial on its own. The remaining defects are listed under Root Cause Analysis.

## Repro & Evidence

- **Steps.** With no ready `artifacts/orchestration/orchestrator-state.json` feature checkpoint, issue a pathspec-scoped `git commit` on a planning branch whose message carries attribution trailers, using any of the forms B3 to B7 below. Observe `PREIMPLEMENTATION_GATE_BLOCKED`.
- **Expected.** Attribution trailers are writable on planning and housekeeping commits through at least one documented form.
- **Actual (analytical trace from the research, section 3; to be confirmed by fail-before runs).**

| Row | Command shape (operand `-- docs/features/active/x/plan.md` unless noted) | Decision on base | Deciding check |
| --- | --- | --- | --- |
| B1 | `git commit -m '<s>' -m '<trailer 1><LF><trailer 2>'` (both trailers in one single-quoted value) | allow | none |
| B2 | `git commit -m "<s> Co-Authored-By: C <n@a.com>"` (inline; git does not parse it as a trailer) | allow | none (#663) |
| B3 | `git commit -m 'fix <backtick>Foo<backtick> handling'` | deny | interpolation check in `Test-OrchestrationCommandTextUnresolvable` |
| B4 | `git commit -m 'costs $5'` | deny | same |
| B5 | `git commit -m '<s>' --trailer 'Co-Authored-By: C <n@a.com>'` | deny | unmodelled option in `Test-ExemptOrchestrationSegmentToken` |
| B6 | `git commit -F docs/features/active/x/msg.txt` | deny | same |
| B7 | `git commit -m "$(cat <<'EOF' ... EOF)"` (Claude Code default recipe) | deny | interpolation check |
| B8 | `git commit -F - <<'EOF' ... EOF` | deny | outside-quote `<`, unmodelled `-F`, body lines as segments |
| B9 | the `#'` comment-desynchronization line (Security Argument, S4) | **allow (pre-existing bypass)** | no deny path |

- **Frequency.** Deterministic; the exemption is pure string logic.
- **Logs.** The `parallel/backlog-2026-09-26-plan` commit history; the planner's final report, deviation 3.

## Scope & Non-Goals

- **In scope.**
  - Treat `$` and backtick as literal inside single-quoted spans (D1, D2).
  - Admit `--trailer <value>` and `--trailer=<value>` on `git commit` only (D3).
  - Close the pre-existing `#` comment bypass by rejecting unquoted `#` (D6).
  - Pin the multi-`-m` one-paragraph trailer form with tests (D1, form B).
  - Document the admitted and non-admitted forms (D11).
  - Byte-identical propagation to all helpers mirrors (AC6).
- **Out of scope / non-goals.**
  - `-F <file>`, `--file`, and stdin message files (D4).
  - Heredoc-fed messages, including the Claude Code `-m "$(cat <<'EOF' ... EOF)"` recipe (D5).
  - Changing the deny reason text of either gate (D10).
  - Any edit to `Split-OrchestrationCommandLine` (owned by sibling #710), to either gate file, to the epic-scope module, to pack manifests, or to runsettings.
  - The Codex-surface skill `.agents/skills/epic-plan/SKILL.md`, which lacks an Integration Commit Form section (follow-up, see Rollout).
  - The unmocked epic-scope read in existing deny tests (#663 follow-up item 6, owned by sibling #709).
- **Explicitly excluded paths.** No path under `docs/features/parallel/` is written.

## Root Cause Analysis

- **Confirmed root cause (code reading; the research records that no shell was run).**
  1. `Test-OrchestrationCommandTextUnresolvable` rejects `$` and backtick in every quote state, including single quotes, where bash treats both as literal (POSIX 2.2.2).
  2. The option table in `Test-ExemptOrchestrationSegmentToken` models only `-m`, `--message`, `--message=` and attached `-m<text>` on `git commit`, so `--trailer` denies.
  3. Heredoc forms are denied by the interpolation check, the outside-quote `<` check, the unmodelled `-F`, and the line split. This is intended fail-closed behaviour and is retained (D5).
  4. **Pre-existing, separate defect.** No stage of the exemption models the `#` comment introducer (POSIX 2.3 rule 9). An unquoted `#'` makes the quote tracker and bash disagree about quote state, which admits arbitrary commands (B9).
- **Signals.** Research sections 1.2 to 1.5 and 3; the helpers file on this branch was re-read on 2026-09-27 and the cited function bodies match.
- **Affected components.** The staging-exemption helpers module and its three byte-identical mirrors. Both gate files consume it unchanged.

## Proposed Fix

### Design summary (what changes where)

In-place edits to the canonical helpers file `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, copied byte-for-byte to its three mirrors. Documentation additions to the Integration Commit Form sections of the two planner skills and their bundle mirrors. One new Pester suite.

### Boundaries and invariants to preserve

- The exemption stays allow-side only. A false result restores the caller's unchanged classification.
- Every parse ambiguity still answers false.
- The escaped-quote checks (`\"`, `\'` anywhere) and the backslash-inside-double-quotes check are unchanged. Sibling #710 D2 relies on them.
- The `Test-ExemptOrchestrationStagingCommand` docstring sentences that #710 cites are kept verbatim.
- Evaluation order is unchanged: `Test-OrchestrationCommandTextUnresolvable`, then `Split-OrchestrationCommandLine`, then tokenization. Allow decisions still return before any epic-scope read.
- The five exempt trees and the LACS selector rule are unchanged.

### Dependencies or blocked work

- None blocking. Siblings #707, #708, #709 and #710 run in the same parallel run. No sibling is assumed to merge first (see Merge-Order Independence).

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change (complete write set)

Production (helpers module, byte-identical set):

- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (canonical)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

Documentation:

- `.claude/skills/parallel-plan/SKILL.md`
- `.claude/skills/epic-plan/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md`

Tests (new file):

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`

Feature-folder artifacts:

- `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md` (this file)
- Evidence files under `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/` and `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/`, per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.

Read-only (consumed, **not** written): both gate files `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`; `.claude/hooks/hook-command-scanner.ps1`; `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`; both existing CommandExemption suites; the Parity and legacy Codex contract suites; `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; the pack manifests.

#### Functions/classes/CLI commands impacted

Edits are located by name and text anchor, not by line number:

1. **Constants block** (anchor: the comment beginning `# Characters that make a command line statically unresolvable` and the two `[char[]]` declarations beneath it).
   - Rename `$script:RedirectionCommandCharacters` to `$script:OutsideQuoteCommandCharacters` and add `'#'` to its members.
   - Reword the comment to state the new rule: `$` and backtick are unresolvable outside quotes and inside double quotes; `<`, `>` and `#` are unresolvable outside quotes only.
   - The variable is referenced only in the constants block and in `Test-OrchestrationCommandTextUnresolvable` (research section 4.2). The executor re-confirms this with a search at edit time.
2. **`Test-OrchestrationCommandTextUnresolvable`.**
   - Guard the interpolation check so that it does not fire when the open quote is a single quote. Shape: `if ($openQuote -ne "'" -and $script:InterpolationCommandCharacters -contains $character)`.
   - Replace the reference to the renamed constant in the outside-quote branch.
   - Update the `.DESCRIPTION` to state the single-quote rule and the `#` rule. Keep the backslash sentences verbatim.
3. **`Test-ExemptOrchestrationSegmentToken`**, inside the `if ($candidate.StartsWith('-'))` branch.
   - Admit `--trailer` as a value-consuming option alongside `-m` and `--message`. The next token is the value, and the existing index guard denies a dangling option.
   - Admit `--trailer=<value>` alongside `--message=`.
   - Reword the comment that begins `# The message option is the only modelled option`.
   - The `if ($subcommand -cne 'commit') { return $false }` guard stays ahead of these checks, so `git add --trailer` continues to deny.

No other function changes. `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationSelector` and `Test-ExemptOrchestrationStagingCommand` are untouched, apart from the rewording in item 4 below.

4. The `.DESCRIPTION` and the `# Row 12:` comment inside `Test-ExemptOrchestrationStagingCommand` may be reworded to reflect the single-quote rule only if the edit is line-neutral and does not alter the sentences #710 cites. The executor may leave them unchanged. The comment is non-normative.

#### Data flow and validation changes

- The decision flow is unchanged. Only the predicate outcomes for the forms listed in Behaviour Semantics change.

#### Error handling and logging updates

- None. The exemption returns booleans. The gate deny reason and the `PREIMPLEMENTATION_GATE_BLOCKED` prefix are unchanged (D10).

#### Rollback/feature-flag considerations

- No feature flag. Rollback is a revert of the helpers edit across all four copies, which must be reverted together to keep parity.

### Technical specifications (interfaces/contracts)

#### Behaviour semantics after the fix

With no ready checkpoint and every operand inside the five exempt trees:

- **Admitted:**
  - one or more `-m`, `--message` or `--message=` values;
  - one or more `--trailer` or `--trailer=` values on `git commit`;
  - `$`, backtick, `<` and `>` inside single-quoted spans;
  - `<` and `>` inside double-quoted spans.
- **Denied, unchanged:**
  - `$` or backtick outside quotes or inside double quotes;
  - `<` or `>` outside quotes;
  - escaped quotes, and backslash inside double quotes;
  - unbalanced quotes;
  - any segment that is not an all-exempt `git add` or `git commit`;
  - pathless commits;
  - `-F` and `--file`; heredoc forms;
  - every previously denied D4 row.
- **Denied, newly:**
  - unquoted `#` anywhere (D6);
  - `--trailer` on `git add`, and a dangling `--trailer` with no value. Both were already denied as unmodelled options and stay denied after the option is modelled.

#### Inputs/outputs and formats

- Function signatures are unchanged. `Test-OrchestrationCommandTextUnresolvable -CommandText <string>` returns `[bool]`. `Test-ExemptOrchestrationSegmentToken -Token <string[]>` returns `[bool]`.

#### Required configuration keys and defaults

- None.

#### Backward-compatibility expectations

- Every command form admitted on base remains admitted, except a form containing an unquoted `#`. The research searches found no existing fixture that places an unquoted `#`, `$` inside single quotes, a backtick, `--trailer` or `-F` in a position whose outcome changes. The existing suites are rerun to confirm this (AC10).

#### Performance constraints

- Single pass over the command text, as before. No measurable change.

## Security Argument

This change relaxes an enforcement gate. The gate's invariant is that an admitted command line stages or commits only paths inside the exempt trees and runs nothing else. That invariant holds only while the helper's quote tracker agrees with bash about which characters are quoted. The argument below covers each relaxed character or flag and the one pre-existing construct that breaks that agreement.

### S1. `$` inside single quotes

- **Bash semantics.** POSIX 2.2.2: enclosing characters in single quotes preserves the literal value of each character within the quotes. Inside single quotes, `$` begins no parameter expansion, command substitution, or arithmetic expansion. A single-quoted span cannot contain a single quote, so it cannot end early.
- **What remains denied.**
  - Outside quotes: `$VAR`, `${...}`, `$(...)` and `$((...))` still deny.
  - The ANSI-C and locale quoting forms `$'...'` and `$"..."` place the `$` outside the quote, so they still deny.
  - Inside double quotes, POSIX 2.2.3 keeps `$` special, so a double-quoted `$` still denies (D2). This covers the Claude Code `-m "$(cat <<'EOF' ... EOF)"` recipe.
- **Why no bypass opens.** The guard skips the interpolation check only when the tracker's open quote is `'`. When the tracker and bash agree on quote state, every `$` the guard skips is a literal byte in an argument that git receives verbatim. Agreement depends on S4.

### S2. Backtick inside single quotes

- **Bash semantics.** The same POSIX 2.2.2 rule applies: a backtick inside single quotes is literal and starts no command substitution.
- **What remains denied.** A backtick outside quotes, or inside double quotes (where POSIX 2.2.3 keeps it special), still denies.
- **Why no bypass opens.** The argument is the same as S1. PowerShell's use of the backtick as an escape character is irrelevant, because the gate evaluates Bash commands only.

### S3. `--trailer` on `git commit`

- **Parsing.**
  - The value is consumed as the next token, or taken from the `=` form, exactly as `-m` is. It is never collected as a pathspec operand, so the all-operands-exempt rule (D4 row 19) and the at-least-one-operand rule (D4 rows 1, 4, 7) still apply to the remaining tokens.
  - A dangling `--trailer` fails the existing index guard.
  - `git add --trailer` fails the existing subcommand guard, which runs before the option checks.
- **What the value cannot do.**
  - A trailer value is message text. It names no path and relocates nothing.
  - git executes a command for a trailer only when a `trailer.<key>.cmd` or `trailer.<key>.command` configuration exists. The admitted line cannot set that configuration: `git -c` is not admitted, because the LACS rule accepts only `-C <absolute>` between `git` and the subcommand.
  - That residual path depends on pre-existing repository or user configuration, and it is recorded under Risks.
- **Why no bypass opens.** The flag adds no new way to stage a path or to end a quoted span. Quote and character handling of its value is identical to that of `-m`.

### S4. The `#` comment bypass (pre-existing; closed in this change)

- **The defect.**
  - POSIX 2.3 rule 9: a `#` that begins a word starts a comment that runs to the next newline.
  - The exemption does not model this. Neither `Test-OrchestrationCommandTextUnresolvable`, `Split-OrchestrationCommandLine` nor `ConvertTo-OrchestrationCommandToken` handles `#`.
  - In the line below (LF-separated), the tracker opens a single-quoted span at the `'` after `#` and treats lines 2 and 3 as one quoted message value:

    ```
    git commit -m #'
    git add src/prod.ts && git commit -m x
    ' -- docs/features/active/x/a.md
    ```

  - Bash treats the `'` on line 1 as part of a comment, so line 2 runs as a complete list. It stages and commits a production file with no ready checkpoint.
  - Line 3 raises a syntax error only after line 2 has run.
- **Status.** This bypass is **pre-existing**. It exists on base without any `$` or backtick, so this change does not create it. The research found it by analysis, and the fail-before run in AC5 confirms it by execution. No prior follow-up list (#663) or sibling spec (#710) records it.
- **Why it must close in the same change.**
  - S1 and S2 are sound only when the tracker's quote state equals bash's quote state.
  - With the fix, every construct that can change bash's quote state relative to the tracker is either modelled or denied:
    - `'` and `"` are modelled;
    - escaped quotes and backslash inside double quotes are denied;
    - `$'`, `$"`, `${` and `$(` are denied because `$` is denied outside quotes;
    - a backtick outside quotes is denied;
    - `<<`, `<<<` and `<(` are denied because `<` is denied outside quotes;
    - an unquoted `#` is denied (this change).
  - History expansion (`!`) is disabled in non-interactive bash.
  - With `#` unmodelled, the S1 and S2 relaxation would widen what a desynchronized span can carry. Separately, issue AC3 ("chaining ... remain[s] denied") could not be checked off while a known chaining bypass exists.
- **The fix.**
  - `'#'` joins the outside-quote character set, so any unquoted `#` makes the line unresolvable.
  - The rule is stricter than bash, which treats a mid-word `#` such as `x#y` as literal. That over-strictness is accepted (fail-closed).
  - A `#` inside single or double quotes is literal in bash and remains admitted.

## Decisions

The research decision list D1 to D13 is adopted with its numbering and its recommended choices. No concrete defect was found in any recommendation. One clarification is recorded under D12.

| ID | Decision | Options considered | Adopted |
| --- | --- | --- | --- |
| D1 | Which commit forms to admit | (A) quote-aware interpolation; (B) multiple `-m`; (C) `-F <exempt-path>`; (D) `--trailer`; (E) heredoc-body awareness | **A + D, with B pinned by tests and documented.** C and E rejected. |
| D2 | Quote scope for the `$`/backtick relaxation | (a) single quotes only; (b) single and double quotes | **(a) single quotes only.** Bash expands both characters inside double quotes (POSIX 2.2.3). Issue AC2's wording is narrowed accordingly (AC3 below). This is recorded as a decision, not a deviation. |
| D3 | `--trailer` admission | (a) admit on `commit` only, net-zero lines; (b) defer | **(a).** It is the only single-line form, and git places the trailers in a correct trailer block. |
| D4 | `-F <file>` / `--file` | admit; reject | **Reject.** It needs a side file, and it would exceed the line budget in the helpers file. It gives no attribution benefit over D3. |
| D5 | Heredoc-fed messages | model; document as not admitted | **Document as not admitted.** The documentation names `-m "$(cat <<'EOF' ... EOF)"` and `-F - <<'EOF'`. |
| D6 | `#` comment desynchronization | (a) fix here by adding `#` to the outside-quote set, zero lines, with a fail-before deny test; (b) record as follow-up only | **(a).** D1-A is sound only with this fix, and AC3 cannot be met with a known chaining bypass. The PR reports the bypass as pre-existing. |
| D7 | Code placement | (a) in place in helpers, net-zero lines; (b) new dot-sourced file | **(a).** Option (b) would require four new copies, manifest and runsettings entries, and a closure update, and it collides with #707's write set. |
| D8 | Test layout | (a) one new file under `tests/scripts/claude-hooks/` covering both runtimes; (b) one file per runtime | **(a)**, following #710 D3. The existing suites are not extended; they have 13 and 6 lines of headroom. |
| D9 | Deny-assertion level | decision-level with epic-scope mocks; predicate-level | **Predicate-level.** It gives merge-order independence from #707 (which adds the epic-scope leg to the Codex gate) and #709 (which adds epic-state mocks). |
| D10 | Deny-reason hint in the gate | add; leave | **Leave.** The reason string is pinned by the EpicScope suite and reused by #707, and the Codex gate has zero line headroom. |
| D11 | Documentation targets | the four Integration Commit Form sections plus the helpers header comments; wider | **The Integration Commit Form sections of `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/epic-plan/SKILL.md`, their two bundle mirrors, and the helpers comments.** Document: the `--trailer` form; the one-paragraph multi-`-m` form; the quoting rules; the non-admitted heredoc and `-F` forms. The `.agents/skills/epic-plan/SKILL.md` gap is a follow-up. |
| D12 | Batching under the 3-production-file cap | one batch; two batches | **Two batches.** Batch 1: the `.claude` and `.codex` helpers copies plus the new suite. Batch 2: the two bundle helpers copies plus the skill documentation. Clarification: the Parity suite is expected to fail between the batches, so parity is asserted only after batch 2 (AC6). |
| D13 | Fail-before scope | claim fail-before for every AC; scope it | **Scope it.** The inline `Co-Authored-By: Name <email>` case was fixed by #663 and cannot fail before on this base. Fail-before evidence covers the single-quoted `$` and backtick rows, the `--trailer` rows, and the `#` bypass row. The multi-`-m` allow and the double-quoted interpolation denies are pass-before pins. |

## Merge-Order Independence

Siblings in the same parallel run are #707, #708, #709 and #710. None is assumed to merge first.

- **Anchors.** Every edit is located by function name and text anchor. No plan step or test cites a line number.
- **Line ceiling.**
  - The helpers file measures 497 lines on this branch. #710 edits only `Split-OrchestrationCommandLine` and keeps the file line-neutral.
  - This change must be net zero or negative in lines in the helpers file, so every touched file stays at or under 500 lines whether or not #710 has merged.
  - If a line-neutral edit proves impossible, the executor extracts the logic to a new file and does not exceed the ceiling. That route triggers the D7(b) obligations and must be recorded as a deviation.
  - The new test file is at or under 500 lines.
  - Each SKILL.md is Markdown and exempt from the cap.
- **Parity at execution time.** Mirror-parity checks compare the four helpers copies with each other, and each skill document with its mirror, as they exist on disk when the check runs. No check compares against `origin/main` or against a sibling's intermediate state.
- **After any rebase.** Re-copy the canonical helpers file to the three mirrors, re-copy the two skill documents to their mirrors, and rerun Parity, legacy Codex contracts, push-down contracts, and the line-count check.
- **#710 contract.** The escaped-quote and backslash-in-double-quote checks and the #710-cited docstring sentences are not modified.
- **#707 contract.** No decision-level Codex deny test is written, and no assertion inspects the gate reason text beyond the `PREIMPLEMENTATION_GATE_BLOCKED` prefix.

## Assumptions, Constraints, Dependencies

- **Assumptions.**
  - The executor host's git supports `git commit --trailer`. The research did not verify the minimum git version, so the plan records `git commit -h` output from the executor host as evidence.
  - Tests do not invoke git, so this assumption affects only the documentation claim.
- **Constraints.**
  - 500-line cap per code file.
  - PowerShell 7+.
  - Per-batch cap of three production files.
  - CI runs Pester on `windows-latest` only.
- **External dependencies.** None added.

## Data / API / Config Impact

- **User-facing changes.** Planner and housekeeping agents gain two documented trailer forms. Unquoted `#` in a staging command is now denied.
- **Data or migration.** None.
- **Logging/telemetry.** None.
- **Compatibility.** Gate interfaces, hook registration, manifests and runsettings are unchanged.

## Test Strategy

**New suite:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`.

- **Structure.**
  - `Describe -ForEach` runs over two runtime descriptors:
    - the Claude gate, with a `{tool_name, tool_input}` envelope builder;
    - the Codex gate, with a mapped `{command}` builder.
  - Each descriptor has its own `BeforeAll` that dot-sources its gate. Paths are resolved from `$PSScriptRoot` with forward-slash joins.
  - Running both descriptors executes the changed lines in both canonical helpers copies, which the coverage gate requires.
  - Data-driven `-ForEach` tables are used, with Arrange-Act-Assert inside each `It`.
- **Positive (allow) rows.** Decision level: call `Invoke-OrchestrationPreimplementationGateDecision` with an explicitly not-ready `-CheckpointRaw`. Allow decisions return before the epic-scope read, so they read no local epic state.
  1. `--trailer 'Co-Authored-By: C <n@a.com>'` with a single-quoted subject and `-- docs/features/active/x/plan.md`.
  2. `--trailer=` form.
  3. Two `--trailer` options (`Co-Authored-By` and `Claude-Session`).
  4. Multi-`-m`: subject in the first `-m`; both trailers in one single-quoted second `-m`, separated by a literal LF. Build the LF with `[char]10` or a double-quoted `` `n `` string, not a here-string.
  5. A single-quoted subject containing a backtick.
  6. A single-quoted subject containing `$` and `$(x)`.
  7. A chained `git add docs/features/active/x/a.md && git commit -m '<s>' --trailer '<t>' -- docs/features/active/x/a.md`.
  8. A `-C /repo/wt` selector variant carrying a `--trailer` value. The value is POSIX-rooted, with no drive letter.
  9. `#` inside a single-quoted and inside a double-quoted message.
- **Negative / bypass (deny) rows.** Predicate level: assert `Test-ExemptOrchestrationStagingCommand` returns `$false` and `Test-ImplementationCommand` returns `$true`. The decision seam is not called, so no epic-scope resolver runs.
  1. Unquoted `>` after a single-quoted `$` message.
  2. `$(...)` in an operand.
  3. `$VAR` in an operand.
  4. `$` inside double quotes.
  5. `$(...)` inside double quotes.
  6. A backtick inside double quotes.
  7. The Claude Code `-m "$(cat <<'EOF' ... EOF)"` recipe.
  8. `$'...'` ANSI-C quoting.
  9. `&&` chaining to a non-exempt `git add src/x.ts`.
  10. `;` chaining to a non-git command.
  11. A non-exempt pathspec with `--trailer`.
  12. A pathless commit carrying only `-m` and `--trailer`.
  13. `git add --trailer 'x' -- docs/features/active/x/a.md`.
  14. A dangling trailing `--trailer`.
  15. `-F docs/features/active/x/msg.txt`.
  16. `--file=docs/features/active/x/msg.txt`.
  17. `-F - <<'EOF'` with body lines.
  18. The S4 `#'` desynchronization line, built with `[char]10`.
  19. `git add docs/features/active/x/a.md # note`.
  20. Mid-word `#` in an exempt operand such as `docs/features/active/x#y/a.md` (documents the accepted over-strictness).
- **Edge cases.**
  - An empty single-quoted `--trailer ''` value followed by an exempt operand. Expected: allow, because the value is message text.
  - An unbalanced single quote around a `$`. Expected: deny, via the Balanced flag.
  - `\'` near a `$`. Expected: deny, via the escaped-quote check.
- **Fail-before rows (D13).**
  - Allow rows 1, 2, 3, 5, 6, 7 and 8.
  - Deny rows 18 and 20. Both are expected to be admitted on base.
  - Evidence: run the new suite against the unmodified helpers and record the failing rows, then run it after the fix and record the pass. Write both outputs under `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/`.
- **Pass-before pins.**
  - Allow row 4 (multi-`-m`) and allow row 9.
  - Deny rows 1 to 17 and 19.
  - The inline angle-bracket case, which #663 already fixed.
- **Hygiene constraints.** The tests use:
  - no temporary files;
  - no `git` process;
  - no `origin/main` reference (CI checkout is depth 1);
  - no gitignored state such as `artifacts/orchestration/*.json`;
  - no Windows-only paths or drive letters (Windows-looking text may appear only as command-text literals where a row needs it; none is planned).
- **Existing suites rerun.**
  - Both CommandExemption suites: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`.
  - `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
  - `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`.
  - The Claude and Codex trigger-scoping and mode suites.
  - `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. It can fail locally on gitignored `.claude/state/*` files (#510), which is not a regression; CI is authoritative for it.
- **PowerShell toolchain (in order, restart on any failure or auto-fix).**
  1. PoshQC format: `mcp__drm-copilot__run_poshqc_format`.
  2. PoshQC analyze: `mcp__drm-copilot__run_poshqc_analyze`.
  3. Pester with coverage: `mcp__drm-copilot__run_poshqc_test`, using `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
  - Both canonical helpers copies are already in `CodeCoverage.Path`.
  - PoshQC MCP results may carry no child output (see project memory). If so, capture coverage figures by invoking the self-hosted module directly, and record them under `evidence/qa-gates/`.
- **Coverage target.** Line coverage of 85% or more for the helpers file, with no regression on changed lines. PowerShell has no branch-coverage gate.
- **Python toolchain.** Only the push-down contract test is rerun; no Python file is written.

## Acceptance Criteria

Traceability to issue.md: issue AC1 maps to AC1 and AC2; issue AC2 to AC3 and AC8; issue AC3 to AC4 and AC5; issue AC4 to AC6; issue AC5 to AC9 and AC10. AC7 and AC11 are additional.

- [ ] **AC1** With no ready feature checkpoint, a pathspec-scoped commit whose attribution trailers are supplied through `--trailer 'Co-Authored-By: Name <email>'` (separate-value and `--trailer=` forms, one or more occurrences, on `git commit` only) is admitted by both the Claude gate and the Codex gate at the decision seam (no `PREIMPLEMENTATION_GATE_BLOCKED` denial), pinned by the allow rows of `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`.
- [ ] **AC2** With no ready feature checkpoint, the multi-`-m` form, in which the subject is in the first `-m` and every trailer is in one single-quoted second `-m` value separated by a literal newline, is admitted by both gates at the decision seam and pinned by a test row (pass-before pin per D13).
- [ ] **AC3** `$` and backtick inside a single-quoted span no longer cause a denial on their own. `<` and `>` inside single- or double-quoted spans remain admitted (#663). `$` and backtick inside double quotes remain denied, per D2, which narrows issue AC2's "inside a quoted commit-message argument" to single quotes for these two characters.
- [ ] **AC4** The relaxation opens no bypass. Each of the following remains denied at predicate level (`Test-ExemptOrchestrationStagingCommand` false and `Test-ImplementationCommand` true), with one regression test row each:
  - redirection outside quotes;
  - command substitution and variable expansion outside quotes or inside double quotes, including the Claude Code `$(cat <<'EOF' ...)` recipe and `$'...'`;
  - chaining to a non-exempt or non-git segment;
  - non-exempt pathspecs with `--trailer`;
  - pathless commits;
  - `git add --trailer`;
  - a dangling `--trailer`;
  - `-F`, `--file=` and `-F - <<'EOF'`.
- [ ] **AC5** The pre-existing `#` comment bypass is closed. The `#'` desynchronization line in the Security Argument (S4) and an unquoted `# note` suffix are denied at predicate level. The fail-before run records the desynchronization row as admitted on the unmodified helpers, and the evidence identifies the bypass as pre-existing. A `#` inside single or double quotes remains admitted.
- [ ] **AC6** After the change, the four helpers copies (`.claude/hooks/`, `.codex/hooks/`, and the two `extensions/drm-copilot/resources/.../hooks/` mirrors) are byte-identical by SHA256, measured on the files as they exist at execution time. `enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `legacy-codex-hook-contracts.Tests.ps1` pass. Each edited skill document is text-identical to its bundle mirror, and `test_push_down_claude_resource_contracts.py` passes in CI.
- [ ] **AC7** The canonical helpers file is at or under 500 lines and not longer than its line count measured immediately before the edit, whether or not #710 has merged. Its diff touches only the constants block, `Test-OrchestrationCommandTextUnresolvable`, `Test-ExemptOrchestrationSegmentToken`, and optionally the comments of `Test-ExemptOrchestrationStagingCommand`. `Split-OrchestrationCommandLine` and both gate files are unmodified. The new test file is at or under 500 lines.
- [ ] **AC8** The Integration Commit Form sections of `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/epic-plan/SKILL.md`, and of their mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`, document:
  - the `--trailer` form;
  - the one-paragraph multi-`-m` form, including the rule that separate `-m` trailer values do not form one trailer block;
  - the single-quote rule for `$` and backtick;
  - the unquoted `#` denial;
  - the non-admitted heredoc (`$(cat <<'EOF' ...)`, `-F - <<'EOF'`) and `-F`/`--file` forms.

  The helpers constants comment and the `Test-OrchestrationCommandTextUnresolvable` docstring state the new rules.
- [ ] **AC9** Fail-before and pass-after evidence is recorded under `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/`:
  - The new suite fails on the unmodified helpers for the single-quoted `$` and backtick rows, the `--trailer` rows, and the `#` desynchronization and mid-word `#` rows.
  - The same suite passes after the fix.
  - Per D13, the evidence states that the inline `Co-Authored-By: Name <email>` angle-bracket case cannot fail before on this base, because #663 already admits it, and that it is carried as a pass-before pin.
- [ ] **AC10** The PowerShell toolchain passes in a single pass: PoshQC format, PoshQC analyze with zero findings, and Pester with coverage, with line coverage of 85% or more on the helpers file and no regression on changed lines. The existing suites listed under Test Strategy pass unchanged. Results are recorded under `evidence/qa-gates/`.
- [ ] **AC11** The new suite satisfies the hygiene constraints: no temporary files, no `git` process, no `origin/main` reference, no gitignored state, and no Windows-only paths or drive letters. Its deny rows assert at predicate level and do not call the decision seam.

## Risks & Mitigations

- **Risk: #710 textual conflict in the helpers file.** The hunks sit in different functions, at least six unchanged lines apart. Mitigation: anchor-based edits, a rebase before the PR, re-copying mirrors, and rerunning parity.
- **Risk: the unquoted-`#` denial rejects a legitimate form** (for example a pathspec containing `#`). Mitigation: accepted fail-closed over-strictness. The denial restores base behaviour for that line and does not create a bypass.
- **Risk: residual trailer command execution.** A repository or user `trailer.<key>.cmd` or `.command` configuration would run a command during `git commit --trailer`, and the deprecated `.command` form substitutes the value into a shell string. Mitigation: the admitted line cannot set that configuration (`git -c` is not admitted), and the risk depends on pre-existing configuration outside the gate's control. The plan records that the repository ships no `trailer.*` configuration, as a one-time evidence check, not a test.
- **Risk: the PoshQC MCP summary carries no child output.** Mitigation: capture coverage from a direct module invocation.
- **Risk: git version.** An old host git may lack `--trailer`. Mitigation: record `git commit -h` on the executor host. The multi-`-m` form remains available as a fallback.

## Rollout & Follow-up

- **Release.** Standard PR against `main` after rebase. The PR description names the `#` bypass as pre-existing and closed by this change.
- **Follow-ups (to be filed, not implemented here).**
  - Add an Integration Commit Form section, with the trailer forms, to `.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror.
  - Optionally, model heredoc-fed messages if demand appears (D5).
- **Links.** Issue #713; related #663 (PR #700), #710, #707, #709, #539, #671.
