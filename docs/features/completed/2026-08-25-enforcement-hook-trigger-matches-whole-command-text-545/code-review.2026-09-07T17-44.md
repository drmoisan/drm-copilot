# Code Review: enforcement-hook-trigger-matches-whole-command-text (#545)

**Review Date:** 2026-09-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Feature Folder Selection Rule:** The `-545` suffix matches the issue number in the branch name `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3`, and it is the folder carrying the primary changed scoping documents (`spec.md`, `plan.2026-08-25T08-13.md`) and all 100 evidence artifacts.
**Base Branch:** `epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
**Head Branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r3` @ `77cb427df4e219dc2603fad791b8669eaf96629b`
**Review Type:** Initial review

---

## Executive Summary

This change replaces raw-whole-command-text trigger matching in nine PowerShell enforcement hooks
with a shared, pure command-line parser delivered as two dot-sourced `.ps1` files across four copy
locations. `hook-command-scanner.ps1` (450 lines) performs a single left-to-right scan producing one
record per shell segment, masking quoted spans and attached heredoc bodies while keeping wrapper-led
and live-substitution segments on raw text. `hook-command-invocation.ps1` (483 lines) answers,
structurally rather than by adjacency, whether a segment *invokes* a named command word with a named
subcommand path, and retrieves that invocation's operands and flag values from the matched segment
only. Eleven independent regexes across nine hooks and two runtimes now delegate to this one
implementation.

The design is deliberately conservative and reads as such. Every ambiguity resolves toward
classification: an unresolvable segment classifies, a wrapper-led segment classifies on raw text, an
unmodeled dash-leading token between the command word and the subcommand classifies. The reasoning
for each choice is written into the code rather than left implicit — the `$script:CommandLineStandaloneFlagNames`
comment explains that omitting `--force` would break acceptance case AT-7; the dot-source placement
in `enforce-parallel-abandon-gate.ps1` is annotated to explain it sits below the token assignments so
lines 41–42 keep their line numbers; `Get-BlockedPatternMatch`'s help explains why leg 1 must complete
in full before leg 2 runs. This is good engineering communication.

Evidence quality is high and, where this reviewer could re-derive it independently, it held: coverage
figures, byte parity across all 18 canonical/bundle pairs, Claude↔Codex parser byte identity, line
counts, evidence locations, protected-literal preservation, test locations, and temp-file absence all
checked out against the branch diff directly rather than against the executor's summaries.

**What changed:**

Four new production files (two parser files × two runtimes, byte-identical), 14 modified production
hook files, 18 byte-identical bundle mirrors, 25 new and 3 modified Pester suites, 14 registration
entries across five registry files, additive annotations to issue #539's spec at five locations, and
two new `docs/features/potential/` entries for the D11.6 deferrals. Four classes of genuine bypass
newly deny (global-option relocation, subshell/group openers, command substitution, adjacency-defeating
options on `npx`/`gh`); quoted-prose and heredoc mentions in non-wrapper segments newly allow.

**Top 3 risks:**

1. **`validate-bash.ps1` lost the wrapper carve-out for its denylist literals.** Leg 1 compares
   against `$segment.Tokens`, never `$segment.ScanText`, so `bash -c "rm -rf /tmp/x"` allows where it
   denied before. Unpinned by any test. This is the one finding that should be closed before merge.
2. **An absolute-path spelling of a listed wrapper escapes classification.** `/bin/bash -c 'git add .'`
   is not wrapper-led under exact-membership matching, so its argument is masked and no hook
   classifies. Spec-conformant, but a residual the spec's own D4.3 justification does not cover.
3. **Fail-closed over-classification on unbalanced quotes.** Any unclosed quote anywhere in a command
   line causes every gated hook to classify. Correct direction, documented in D12, but it means a
   benign apostrophe forces a checkpoint consultation on every hook.

**PR readiness recommendation:** **Conditional Go** — the implementation, tests, coverage, parity, and
evidence are all strong, and one concrete deny-side regression (CR-1) plus one specification
amendment (CR-2) should be closed first.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Major | `.claude/hooks/validate-bash.ps1`, `.codex/hooks/validate-bash.ps1` (+2 bundle mirrors) | `Get-BlockedPatternMatch`, lines 146–151 | **CR-1.** Leg 1 tests the six denylist literals against `$segment.Tokens` only. `ConvertTo-CommandLineToken` collapses a quoted span into one token, so a multi-token literal can never form a contiguous run inside a wrapper's quoted argument. `bash -c "rm -rf /tmp/x"`, `sh -c 'rm -rf /'`, and `pwsh -Command "Remove-Item -Recurse -Force x"` returned a literal before this change and return `$null` after it. The wrapper carve-out is computed correctly into `ScanText` but leg 1 never reads that field. | Add a second comparison for wrapper-led and live-substitution segments: when `$segment.IsWrapperLed -or $segment.HasLiveSubstitution`, additionally test `$segment.ScanText.Contains($pattern)` (the pre-change primitive, now scoped to segments the design already keeps on raw text). Keep leg-1 ordering so `git push origin --force` still returns its own literal. Add three pinning cases per side: `bash -c "rm -rf x"` → `'rm -rf'`, `sh -c 'git reset --hard'` → `'git reset --hard'`, `pwsh -Command "Remove-Item -Recurse -Force x"` → `'Remove-Item -Recurse -Force'`. | This is a measurable loss of an existing denial on the repository's destructive-command denylist, reachable by an ordinary rather than adversarial spelling. Spec D3 rows 2 and 4 state these forms stay `neutral` because the "wrapper carve-out scans raw"; validate-bash does not honour that because D11.3 specified `Tokens` without re-deriving the D3 guarantee. It is not covered by D4's accepted residuals: D4.1 is about over-match, D4.2 about obfuscated respellings, D4.3 about *unlisted* wrappers — and `bash`, `sh`, `pwsh` are all listed members. | Code trace in policy-audit §8 G-1. Pre-change primitive was `$Command.Contains($pattern)`. Grep for `bash -c\|sh -c\|pwsh -Command\|pwsh -NoProfile` across all four `validate-bash` suites → **no matches**, so the gap is unpinned as well as unfixed. |
| Minor | `docs/features/active/…-545/spec.md` | AC-07 (line ~1481) vs D12 call-site table (line ~1179) vs AC-31 | **CR-2.** AC-07 requires the pr-author `gh pr create` / `gh pr edit` regex expressions be byte-unchanged. D12's call-site rewrite table directs those exact call sites to `Test-CommandLineInvocation`, which takes no pattern operand; AC-31 independently requires the same for `Test-EpicBaseBranchOverride`. The three literals are consequently deleted. The two readings cannot both hold. | Amend AC-07 to record that its pr-author clause is superseded by the D12 call-site table and AC-31, and that the byte-unchanged obligation survives for the other four literal groups. Do not change code. | The conflict is **internal to the spec**, not between spec and implementation. D12 marks four other rows explicitly "**byte-unchanged**" and pointedly does not so mark the pr-author rows — that asymmetry is deliberate drafting, and it makes D12 the later, more specific statement. Leaving AC-07 unamended leaves a permanently unsatisfiable criterion in the record. | Diff lines 397/398, 3430/3431 (`enforce-pr-author-skill-helpers.ps1`) and 441/3474 (`enforce-pr-author-skill.epic-base-branch.ps1`) remove the literals. All four other groups verified byte-unchanged against merge-base `6dff80ed`: no `-` line in the full diff removes any of them. `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` §4. |
| Minor | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` L161–172, `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` L91–102 | `Get-EpicWorktreeRemovalCommandPath` / `Get-ParallelWorktreeRemovalCommandPath` | **CR-3.** The two function bodies are now byte-identical, and the second file's own docstring says so: "This body is identical to `Get-EpicWorktreeRemovalCommandPath`". The change reconciled two *divergent* regexes into two *identical copies* rather than into one implementation. | Extract the shared body into `hook-command-invocation.ps1` as e.g. `Get-WorktreeRemovalTargetPath -CommandText <text>`, and have both hook functions become one-line delegations. Their names, signatures, and `$null`-on-miss contracts stay intact, so the pinning cases at `enforce-epic-worktree-removal-gate.Tests.ps1:136,141` and `enforce-parallel-worktree-removal-gate.Tests.ps1:78` are unaffected. | `.claude/rules/general-code-change.md` design principle 2: "Factor out logic that is clearly reusable. Avoid copy-paste; share behavior via composition or helper methods." The pre-existing divergence between these two implementations is exactly what the epic is trying to eliminate; two identical copies will drift again the moment one is edited. | Diff of both files; the acknowledging docstring is in the `enforce-parallel-worktree-removal-gate.ps1` hunk. |
| Minor | `.claude/hooks/validate-bash.ps1` | line 204 | **CR-4.** `$script:CdChainedReadCommandPattern` is now write-only. `Get-CdChainedReadCommandMatch` was rewritten to walk the segment list using the parallel constant `$script:CdChainedReadCommandWords`, and the regex is referenced nowhere and pinned by no test. It is retained solely so AC-07's byte-unchanged obligation is visibly discharged. | Add a Pester case that derives the command-word set from the retained pattern and asserts it equals `$script:CdChainedReadCommandWords`, so the two cannot drift. If AC-07 is amended per CR-2, deleting the constant is the alternative. | A declared-but-unread constant next to a live parallel constant is a drift hazard: a future editor updating one has nothing forcing them to update the other, and the regex is the one a reader will assume is authoritative because it is the older and more specific artifact. | `grep -n 'CdChainedReadCommandPattern'` across both hook copies and all `validate-bash` test suites returns exactly one hit — the declaration itself. |
| Minor | `.claude/hooks/hook-command-scanner.ps1`, `.claude/hooks/hook-command-invocation.ps1` | `$script:CommandLineWrapperNames`; `Resolve-CommandLineInvocation` token loop | **CR-5.** Wrapper membership is exact string equality on the `CommandWord` token, so `/bin/bash -c 'git add .'` and `/usr/bin/env git add .` are not wrapper-led: their argument is masked and no hook classifies. Pre-change the raw-text regexes matched inside them. | File a follow-up to add leaf-of-path resolution — compare `Split-Path -Leaf $commandWord` against the wrapper and transparent-wrapper sets — and amend D2 Piece 2 and AC-05 in the same change so the constant, the test, and the spec continue to agree. Do not change it here: AC-05 pins **exact** membership of the 14-name set, so an unilateral change would break a checked criterion. | Same class as accepted residual D4.3, but D4.3's justification ("no such wrapper appears in any repository skill, rule, or test") does not hold for an absolute-path spelling of a wrapper that *is* in the set. `/bin/bash` and `/usr/bin/env` are ordinary spellings. | Traced against `Resolve-CommandLineInvocation`: `CommandWord` for `/bin/bash -c '…'` is `/bin/bash`, which is in neither set, so `IsWrapperLed` is `$false` and the structural loop never reaches `git`. |
| Minor | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | `Get-ParallelAbandonNormalizedCommand` → `Test-ParallelAbandonCommandInScope` | **CR-6.** Normalization (`-replace '\s+', ' '`) runs **before** segmentation, so newlines are collapsed to spaces before `Read-CommandLineSegment` sees the text. This hook therefore loses newline-based segment delimiting and cannot recognise a heredoc terminator line. | Pass the raw `CommandText` to `Read-CommandLineSegment` and keep the normalized form only for the callers that need it, or document the ordering as intentional in the function help. | The consequence is safe-direction — a flattened heredoc never terminates, so the segment is `Unbalanced` and falls back to a raw scan — but it silently reduces the over-match fix's benefit for this one hook, and the reason is not written down anywhere. | `Get-ParallelAbandonNormalizedCommand` is unchanged by this branch; the new per-segment calls consume its output. |
| Info | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle mirror | whole file | **CR-7.** Both sit at **exactly 500 lines**, the policy cap, with zero headroom. D12 names this hook family as the subject of imminent edits by epic children D and G. | Before the next edit to this file, extract a helper (the mode-routing or the exemption-consultation block are natural seams) so the child work is not blocked by the cap. | The next additive change to this file, however small, breaches `.claude/rules/general-code-change.md`'s 500-line limit. Better to surface it now than to discover it mid-child. | `wc -l` over all 63 changed `.ps1` files; the two 500-line rows are the maxima. |
| Info | `.claude/hooks/hook-command-invocation.ps1` | `Resolve-CommandLineInvocation`, first rule | **CR-8.** An `Unbalanced` segment returns a match for **any** `CommandWord` / `SubcommandPath`, so `echo don't` causes every gated hook to classify and consult its checkpoint. | No change. Recorded so the behaviour is not rediscovered as a defect. | The direction is fail-closed, which is correct for this hook family, and D12 states the rule explicitly. The cost is over-classification on benign apostrophes — an acceptable trade that reviewers should know is intentional. | D12 fail-closed rule 3; implementation at the top of the per-segment loop. |
| Info | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` (unmodified by this branch) | line 142, `Context 'allowed commands'` | **CR-9.** The `BeforeEach` at lines 127–140 mocks five collaborators but not `Get-PrAuthorCheckpointContent`, whereas three sibling contexts mock it at lines 297, 317, 363. The case therefore reads the real gitignored `artifacts/orchestration/orchestrator-state.json` and fails locally when that file carries `epic_mode: true`. | File a follow-up adding `Mock -CommandName Get-PrAuthorCheckpointContent -MockWith { $null }` to that `BeforeEach`. Correctly left unfixed here — the suite is outside the nine-hook scope D11 defines. | Independently confirmed **not** change-caused: the pre-#545 code path yields the identical deny for the identical ambient state, because the old `-match '(?i)\bgh\s+pr\s+create\b'` classifies this fixture exactly as `Test-CommandLineInvocation` does, and the old `-cnotmatch [regex]::Escape("--base …")` returns `EPIC_BASE_BRANCH_MISMATCH` for a command with no `--base` exactly as `Get-CommandLineFlagValue` returning `$null` does. | Reproduced locally: `Expected: 'allow' / But was: 'deny'` at line 145. `git check-ignore -v artifacts/orchestration/orchestrator-state.json` → `.gitignore:6`. Checkpoint carries `"epic_mode": true`. |
| Info | epic amendment EA-3 | `Test-ChildCheckpointAllowsEpicMerge`, `Test-CodexCheckpointAllowsMerge` | **CR-10.** Both take only a `$Checkpoint` parameter and are consulted first, so an `epic_mode` / `step9_status: passed` checkpoint authorizes merging any PR. Phase 9 found the Codex sibling shares the shape, so a fix needs both copies. | Ensure EA-3 is carried into the epic's follow-up register rather than resting only in this spec, since its scope grew during execution. Correctly deferred here. | A pre-existing authorization hole that #545 neither introduces nor widens. Fixing it would exceed the nine-hook scope. The risk is that a deferral whose scope doubled mid-execution gets lost if it lives only in a spec that is about to be archived. | Surfaced by the orchestrator; consistent with the D11 scope boundary. |

No Blocker findings. One Major finding (CR-1).

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- **The parser is genuinely pure.** Neither `hook-command-scanner.ps1` nor `hook-command-invocation.ps1`
  reads stdin, touches disk, starts a process, reads a clock, or references `$env:CLAUDE_*` — verified
  by grep, not just by the docstring claim. That purity is what makes 96.77–100% line coverage
  achievable on files this size without a single mock, and it is the single best structural decision in
  the change.
- **Fail-closed rules are explicit and individually commented.** `Resolve-CommandLineInvocation`
  implements D12's four rules as four early returns, each annotated with the reason it exists rather
  than with what it does. A reader can audit the fail-closed argument against D3 without leaving the
  file.
- **Constants are exposed through getters, not as bare script variables.** `Get-CommandLineWrapperName`,
  `Get-CommandLineTransparentWrapperName`, and `Get-CommandLineGlobalOption` give the R6 membership
  tests a public surface to pin. `Get-CommandLineGlobalOption` returning an empty-arrays record for an
  unrecognized command word is the right default: every dash-leading token for an unmodeled command
  then counts as unmodeled and therefore classifies, which is the fail-closed direction.
- **The `#591` fix is structural rather than patched.** Taking operands from the *matched segment only*
  fixes both the false-block (`cd .../2026-08-29T00-11 && gh pr merge --merge 688` yielding `2026`) and
  the false-allow (`cd /repo/worktrees/501 && gh pr merge --merge 777` yielding `501` and authorizing
  777) in one move, and the deleted unanchored digit-scan branch is documented in the function help with
  both failure directions spelled out. That comment is the clearest artifact in the change.
- **Real cross-runtime divergence was closed, not papered over.** `Get-ParallelWorktreeRemovalCommandPath`
  and `Get-EpicWorktreeRemovalCommandPath` had already drifted apart from the Codex copy; both now return
  `/repo/worktrees/item-a-101` for `git worktree remove --force /repo/worktrees/item-a-101` where both
  previously returned the literal `--force` (AT-7). The `$script:CommandLineStandaloneFlagNames` table
  exists precisely to make that work, and says so.
- **Line-number-preserving edits where a seam test depends on them.** The dot-source in
  `enforce-parallel-abandon-gate.ps1` is placed *below* the two token assignments so lines 41–42 keep
  their line numbers and `test_parallel_abandon_token_seam.py` keeps passing. The comment explains both
  the placement and why it is still correct (the file executes top to bottom before any function runs).
  That is careful work.
- **`Test-ParallelAbandonSegmentDisposition` restates neither literal.** It derives the option name and
  value by splitting `$script:AbandonDispositionToken`, preserving the seam test's single-source-of-truth
  property while adding the equals-joined spelling. This is the right way to extend a constant-pinned
  behaviour.

#### API and safety notes

- All 15 parser functions and every added hook function are advanced functions with `[CmdletBinding()]`
  and `[OutputType(...)]`. Approved verbs throughout (`Read-`, `Test-`, `Get-`, `ConvertTo-`, `Resolve-`,
  `Skip-`), singular nouns, consistent `CommandLine` noun prefix.
- Parameter validation is deliberate rather than reflexive: `[ValidateNotNullOrEmpty()]` where a value is
  required, `[AllowEmptyString()]` / `[AllowNull()]` / `[AllowEmptyCollection()]` where the empty case is
  a defined input with defined behaviour. `Read-CommandLineSegment` returning an empty array for null,
  empty, or whitespace-only input is stated in the help and matches D12.
- The `Get-CommandLineOperand` contract — "Callers receive the result through the `@(...)` array form
  used at every call site, so the no-operand case arrives as an empty array rather than as `$null`" — is
  stated in the help and honoured at every call site inspected.
- Two behavioural tightenings are in the deny direction and both are documented:
  `Test-ParallelAbandonCommandConfirmed` now requires the confirmation marker in the **same segment** as
  the disposition (previously anywhere in the string); `Get-CdChainedReadCommandMatch` widens the
  delimiter set from `&&`/`;` to every segment delimiter. Both are safe-direction and explained in the
  function help, including the one intended narrowing (a cd-then-read phrase occurring only inside a
  quoted span now allows).
- Minor API observations, not findings: `Test-CommandLineFlag` and `Get-CommandLineFlagValue` scan the
  matched segment's tokens from index 0 rather than from the operand position, so a token that happens to
  equal the flag name before the subcommand would match. In practice a flag before the subcommand is
  either a modeled global option (absorbed) or unmodeled (classifies), so the exposure is negligible —
  recorded for completeness only.

#### Error handling and logging

- No broad `catch`. The parser has no failure mode other than returning a defined empty/`$null` value,
  and every such value is specified in the function help.
- The hooks retain their existing reason codes verbatim. `enforce-promotion-mcp-only.ps1` keeps
  `$script:PromotionMcpOnlyBlockedReason` and `$script:PromotionMcpOnlyGhIssueBlockedReason` unchanged;
  `enforce-pr-author-skill.epic-base-branch.ps1` keeps the `EPIC_BASE_BRANCH_MISMATCH` message text
  byte-for-byte, including its backtick formatting, and preserves the case-sensitive branch-name
  comparison (`-cne`) that the previous `-cnotmatch` provided. Preserving case sensitivity there was easy
  to miss and was not missed.
- No `Write-Host` in any library path; the parser returns values only.

---

## Test Quality Audit

Twenty-five new suites and three modified ones, all under `tests/scripts/claude-hooks/` and
`tests/scripts/codex-hooks/`, mirroring the production tree. No colocation, no temporary files, no
sleeps, no wall-clock reads. Regression-first discipline was followed and is evidenced in both
directions: seven `[expect-fail]` artifacts, each paired with a pass-after run, zero unpaired.

The suite decomposition is the notable design choice. Rather than one large per-hook suite, the work
splits along concerns — `hook-command-scanner.Tests.ps1` for segmentation, `hook-command-invocation.Tests.ps1`
for structural matching, `*.TriggerScoping.Tests.ps1` for each hook's scope filter,
`*-decision-surface.Tests.ps1` for each hook's decision, and one consolidated
`hook-command-parser.AcceptanceCases.Tests.ps1` holding AT-1 through AT-7 plus four paired negatives so
that a fail-open regression surfaces in a single place (AC-27's explicit intent). Test names carry the
spec row they discharge, so traceability is readable from the test list without a mapping document.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` (347 lines) — all seven heredoc rules of D2
  Piece 1 as named cases, plus the exact 14-member wrapper set. Thorough; the unterminated-body and
  non-literal-delimiter cases are the ones most likely to be skipped and both are present.
- `tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1` (330 lines) — the six numbered steps of
  D2 Piece 3, including the `git log --grep add` negative that distinguishes structural matching from
  adjacency. Signature and `OutputType` pinning per D12.
- `tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1` (228 lines) — AT-1…AT-7 plus
  paired negatives; 11 tests, 0 failures.
- `tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1` (329 lines) — good token-run
  coverage (`rm -rf build`, `git status && rm -rf node_modules`) but **no wrapper form**, which is the
  test-surface half of CR-1.
- `evidence/qa-gates/deny-preservation-audit.2026-09-07T16-11.md` — the strongest artifact in the set. It
  enumerates every existing denial assertion by name with its observed result, confirms only the two
  intended assertion reversals occurred, and does not overclaim: the one failure is decomposed rather
  than absorbed into a summary.
- `evidence/qa-gates/final-per-file-coverage.2026-09-07T17-13.md` — states its measurement route, its
  selection method (package-qualified, because ten filenames exist under both `.claude/hooks` and
  `.codex/hooks`), and why the MCP runner was *not* used. The disambiguation problem is real and the
  stated solution is correct.
- `evidence/qa-gates/coverage-delta.2026-09-07T17-00.md` — notably honest: it explains both negative
  deltas as ratio decreases with rising covered counts, then explicitly declines to claim that no
  individual line lost coverage, because it compares counts across two runs. That restraint is the right
  call and makes the artifact more trustworthy, not less.
- `evidence/qa-gates/trigger-literals-byte-unchanged.2026-09-07T15-50.md` — records the AC-07 exception in
  full in §4 rather than burying it, including a before/after table of the removed expressions and the
  occurrence counts. Referring it up rather than resolving it in the executor's own favour was correct.

### Quality assessment prompts

- **Determinism:** Strong. The parser is pure, so the new suites need no mocks at all; the hook suites
  mock only at the I/O boundary (`Get-*CheckpointContent`, `Get-PrContextArtifactExistence`,
  `Get-PrBodyFileBytes`). No sleeps, no RNG, no wall-clock. The only nondeterminism in the repository's
  local run comes from two *pre-existing, unmodified* suites reading gitignored ambient state (CR-9 and
  its `codex-pretooluse-integration.Tests.ps1` sibling), both green on a clean CI checkout.
- **Isolation:** Strong. Each new test drives one function with one literal command string and makes one
  assertion. Data-driven rows use `-ForEach` tables, so a table row failure names the row.
- **Speed:** Strong. Pure string logic, no I/O. The local partial run executed 1520 cases in a single
  invocation; the full CI run completed and was watched to a zero exit status.
- **Diagnostics:** Good. The one observed failure produced `Expected: 'allow' / But was: 'deny'` with file
  and line — enough to localise without re-running. Test names name the spec row, so a failure identifies
  the violated obligation, not just the violated assertion.

### Coverage gap

The only material test gap this review found is the absence of any wrapper-form fixture in the four
`validate-bash` suites (CR-1). Everything else the spec's Test Strategy requires is present and named.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential, token, key, or `.env` introduced anywhere in the 168-file diff. |
| No unsafe subprocess or command construction | ✅ PASS | The parser classifies text and starts no process. No `Invoke-Expression`, no dynamic script block construction, no string-built command execution in any changed file. |
| Input validation at boundaries | ✅ PASS | Every public parser function declares mandatory, typed parameters with explicit null/empty allowances. `Read-CommandLineSegment` returns an empty array for null, empty, or whitespace-only input rather than throwing or returning `$null`. |
| Error handling remains explicit | ✅ PASS | Four fail-closed rules as explicit early returns, each commented with the rule it discharges. No broad `catch`. `$null`-on-missing-value contract for `Get-CommandLineFlagValue` is pinned by paired negatives. |
| Configuration / path handling is safe | ✅ PASS | Dot-sourcing uses `. (Join-Path $PSScriptRoot '<name>')` throughout — no relative-path or working-directory dependence. Helper files are dot-sourced in both the parent hook and the helper file itself so a test can dot-source either directly. |
| **Deny-side behavioral preservation** | ❌ **FAIL** | CR-1. `bash -c "rm -rf /tmp/x"` denied before this change and allows after it, in all four `validate-bash` copies, unpinned by any test. |
| Fail-closed direction elsewhere | ✅ PASS | Unbalanced → classify; wrapper-led → raw scan; unmodeled option → classify; unknown command word → empty option table → every dash-leading token unmodeled → classify. Every ambiguity resolves toward the checkpoint check. |
| Policy files untouched | ✅ PASS | Zero changed paths under `.claude/rules/`, `.github/instructions/`, or `.github/copilot-instructions.md`. |
| Scope confined to the nine hooks + parser | ✅ PASS | Exactly 11 canonical `.claude/hooks/` and 7 canonical `.codex/hooks/` files changed; no hook outside the D11 list of nine. |

---

## Research Log

No external research was required. All evidence came from the branch diff, the feature folder's spec
and 100 evidence artifacts, the PR-context artifacts, direct inspection of the changed source, and
locally executed verification (`git diff`, `cmp`, `wc -l`, `grep`, `poetry run pytest`, and Python
parsing of `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml`).

`pwsh`, `powershell`, and `cmd` are refused by the session runtime guard, and the `mcp__drm-copilot__*`
tools are not exposed to this reviewer, so no PowerShell stage could be re-executed. Review artifact
templates were read from `extensions/drm-copilot/resources/templates/policy_audit/` — the exact path
`resolveBundledPolicyAuditTemplateAsset` resolves for the `template`, `code-review-template`, and
`feature-audit-template` selectors — rather than through the MCP resolver. Both substitutions are
recorded in the policy audit's Appendix B rather than taken silently.

---

## Verdict

This is careful, well-evidenced work on a subtle problem. Replacing eleven raw-text regexes across nine
hooks and two runtimes with one pure, well-tested parser is a real reduction in duplicated risk, and the
change closes four classes of genuine bypass while eliminating the over-match that motivated the issue.
The fail-closed argument is written down form by form, the residuals are named rather than hidden, and
the evidence chain survives independent re-derivation on every dimension this reviewer could check. Two
judgment calls the orchestrator referred up rather than resolving in its own favour — the AC-07 literal
conflict and the AC-22 PR-body dependency — were both correctly characterized, and its diagnosis of the
ambient `enforce-pr-author-skill.Tests.ps1` failure was verified accurate, including the corrected
attribution away from the baseline set.

One finding should be closed before merge. **CR-1** is a concrete loss of an existing denial on the
repository's destructive-command denylist, reachable by an ordinary spelling (`bash -c "rm -rf …"`),
present in all four copies, and pinned by no test. The fix is small and local: give leg 1 a `ScanText`
comparison for the segments the design already keeps on raw text, and add three pinning cases per side.
It is worth the delay — the hook family is a policy deterrent rather than a security boundary, but a
deterrent that silently stops deterring the most common wrapper spelling is worse than one that never
claimed to.

**CR-2** needs a specification amendment only, and should be made in the same change so AC-07 stops
being unsatisfiable. **CR-3** through **CR-7** are worth addressing but need not block: CR-3 and CR-5 in
particular are best filed as follow-ups, since CR-5 cannot be fixed without simultaneously amending
AC-05 and D2 Piece 2.

**PR readiness: Conditional Go** — merge after CR-1 is fixed and pinned, and CR-2 is recorded.
