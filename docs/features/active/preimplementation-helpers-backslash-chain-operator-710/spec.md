# preimplementation-helpers-backslash-chain-operator (Spec)

- **Issue:** #710
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-26T23-30
- **Status:** Approved (autonomous mode; no further approvals required per user instruction)
- **Version:** 1.0
- **Work Mode:** full-bug (acceptance-criteria source: this `spec.md` only)
- **Branch:** `bug/preimplementation-helpers-backslash-chain-operator-710`
- **Requirements inputs:** `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/issue.md`, `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md`

## Context
- Summary: `Split-OrchestrationCommandLine` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and its three byte-identical copies) treats an unquoted `\;`, `\&` or `\|` as a chain operator. A POSIX shell treats each as a literal character. The scanner therefore reports more segments than the shell executes. Origin: #663 `evidence/other/follow-ups.md`, item 8.
- Observed environment(s): any host running the Claude or Codex preimplementation gate (PowerShell 7+). The defect is in pure string-scanning logic and is platform-independent.
- Customer impact and severity: Low. The mismatch fails toward deny. When a Bash command such as `git commit -m fix\;done -- docs/features/active/x/spec.md` is issued with no ready checkpoint, the staging exemption returns false and the gate denies a command the shell would run as a single exempt `git commit`. No allow-side bypass results from the defect.
- First observed date and version(s) impacted: recorded during #663 review; present on base `origin/main` 218b518e (extension 1.1.12).

## Repro & Evidence
- Steps to reproduce: call `Split-OrchestrationCommandLine -CommandText 'find . -exec cmd {} \; -print'` after dot-sourcing `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Alternatively issue the Bash command `git commit -m fix\;done -- docs/features/active/x/spec.md` while the preimplementation gate is active without a ready checkpoint.
- Expected vs actual behavior: expected one segment (`find . -exec cmd {} \; -print`); actual two segments (`find . -exec cmd {} \` and ` -print`). For the commit example, expected `Test-ExemptOrchestrationStagingCommand` returns `$true`; actual `$false`, because the second segment `done -- docs/...` is not a git invocation.
- Logs/screenshots/error snippets: none captured; the defect is shown by code reading of lines 93-98 (research section 1.3) and by the analytical trace in research section 1.4.
- Frequency / determinism: deterministic for any unquoted backslash-escaped `;`, `&` or `|` followed by further non-whitespace text. A trailing `\;` (for example `find . -exec cmd {} \;`) does not change the segment count before or after the fix, because the empty trailing segment is dropped; only the segment text differs.

## Scope & Non-Goals
- In scope:
  - Adding POSIX backslash-escape tracking to `Split-OrchestrationCommandLine` in `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`.
  - Byte-copying the edited file to `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`.
  - Creating the regression suite `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`.
  - Writing evidence artifacts under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/<kind>/`.
- Out of scope / non-goals:
  - Any change to `Test-OrchestrationCommandTextUnresolvable`, `ConvertTo-OrchestrationCommandToken`, `Test-ExemptOrchestrationOperand`, `Test-ExemptOrchestrationSelector`, `Test-ExemptOrchestrationSegmentToken`, or `Test-ExemptOrchestrationStagingCommand` (D2).
  - The pre-existing unquoted-operand gap `docs/features/active/.\./.\./.\./src/x.ps1` (D7).
  - Modelling of comments (`#`), heredoc bodies, or `$'...'` quoting in the scanner.
  - Any edit to the gate files, the epic-scope module, pack manifests, or Pester runsettings.
- Explicitly excluded systems, integrations, or datasets: `.claude/hooks/hook-command-scanner.ps1` (used as precedent only; not edited); the existing CommandExemption suites (not edited; D3).

## Root Cause Analysis
- Confirmed root cause: `Split-OrchestrationCommandLine` (helpers lines 58-108) holds a single state variable, `$openQuote`. Outside quotes it splits on `;`, `&`, `|`, LF and CR (lines 93-98) without examining a preceding backslash. POSIX Shell Command Language 2.2.1 defines an unquoted backslash as quoting the next character, so `\;`, `\&` and `\|` are literals to the shell.
- Signals/evidence supporting it: research section 1.3 (code reading of lines 74-107); research section 2 (POSIX rules and the required case table); research section 1.4 (analytical trace of the spurious deny through `Test-ExemptOrchestrationStagingCommand`).
- Affected components/modules: the four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` (research Numeric Derivation Evidence N1). Callers affected by the behaviour change: `Test-ExemptOrchestrationStagingCommand` (helpers line 473) and `Get-OrchestrationEpicScopeSelector` (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` line 77 and its bundle mirror). Neither caller file is edited.

## Proposed Fix

### Design summary (what changes where):
Add one boolean escape-state variable to `Split-OrchestrationCommandLine`. A backslash encountered outside a single-quoted span sets the escape state; the next character, whatever it is, is appended to the current segment without being evaluated as a quote or operator. Both the backslash and the escaped character remain in the segment text. The `Balanced` result continues to depend only on `$openQuote`. The semantics mirror `Read-CommandLineSegment` in `.claude/hooks/hook-command-scanner.ps1` (lines 365-372 single-quote branch without escape handling, lines 375-381 double-quote escape pair, lines 391-397 unquoted escape pair).

### Boundaries and invariants to preserve:
- Unescaped `;`, `&&`, `||`, `|`, `&`, LF and CR outside quotes split exactly as before.
- An escaped backslash followed by an operator (`\\;`) still splits.
- Inside single quotes a backslash is literal; `'a\'; b` still yields two segments.
- Segment text is unchanged for every input: no characters are removed or rewritten.
- A trailing lone backslash does not affect `Balanced`.
- Every existing CommandExemption contract row (row 18, rows 16b/16c, LACS allow 3, #663 escaped-quote denies) keeps its outcome (research section 4.1).
- The helper file keeps the same line count as on the base immediately before editing, and never exceeds 500 lines (D5).

### Dependencies or blocked work:
- Sibling #713 may edit the same helper file, most plausibly `Test-OrchestrationCommandTextUnresolvable`. D5 keeps this change net-zero in lines and confined to `Split-OrchestrationCommandLine` so that merge order does not matter.
- No dependency on #707, #708 or #709 was identified (research section 6; sibling documents were not present in the worktree).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
Files this change writes:
- `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (canonical edit).
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy of the canonical file).
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy).
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (byte copy).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` (new).
- Evidence artifacts under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/` (for example `evidence/qa-gates/` for the SHA256 parity record and line-count record, `evidence/coverage/` for coverage, `evidence/regression/` for fail-before and pass-after results).

No other file is written.

#### Functions/classes/CLI commands impacted:
- Edited: `Split-OrchestrationCommandLine` only (body and its own comment-based help).
- Behaviour observed through, but not edited: `Test-ExemptOrchestrationStagingCommand`, `Get-OrchestrationEpicScopeSelector`.

#### Data flow and validation changes:
- Before: every unquoted `;`, `&`, `|`, LF, CR ends a segment.
- After: an unquoted or double-quoted `\X` pair is appended as two literal characters; X never ends a segment and never opens or closes a quote. Backslash-newline therefore no longer splits (POSIX line continuation). An unquoted `\"` or `\'` no longer opens a quote span, which aligns the scanner with the shell; inputs containing `\"` or `\'` are still denied upstream by `Test-OrchestrationCommandTextUnresolvable` before the scanner runs on the staging path.

#### Error handling and logging updates:
None. The function returns a hashtable and has no logging; no new error paths are introduced.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the single commit range, followed by re-copying the canonical file to the three mirrors and re-running the Parity test.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Signature unchanged: `Split-OrchestrationCommandLine -CommandText <string>` returning `@{ Balanced = <bool>; Segments = <string[]> }`.
- Required results (research section 2 and D3):

| Input (PowerShell single-quoted literal unless noted) | Segments | Balanced |
| --- | --- | --- |
| `find . -exec cmd {} \; -print` | 1 (text equals input) | true |
| `a\&b c` | 1 | true |
| `a\|b c` | 1 | true |
| `"a\`n" + 'b'` built as `a\` + LF + `b` | 1 | true |
| `a; b`, `a && b`, `a \|\| b`, `a \| b`, `a & b` | 2 each | true |
| `a\\; b` | 2 | true |
| `a\\\; b` | 1 | true |
| `a\&& b` | 2 | true |
| `'a\'; b` (text contains single quotes) | 2 | true |
| `"a\"; b"` (text contains double quotes) | 1 | true |
| `a\"` | 1 | true (was false) |
| `a\` (trailing lone backslash) | 1 | true |

- `Test-ExemptOrchestrationStagingCommand -CommandText 'git commit -m fix\;done -- docs/features/active/x/spec.md'` returns `$true` (was `$false`).
- `Test-ExemptOrchestrationStagingCommand -CommandText 'git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md'` returns `$false`.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
Public function names, parameters and return shape are unchanged. Behaviour changes only for inputs containing a backslash outside single quotes, and only in the direction of matching POSIX shell segmentation.

#### Performance constraints (latency/throughput/memory):
One additional boolean check per character; linear time is preserved. No measurable constraint applies.

## Design Decisions

### D1: Where to implement escape handling
- Options considered: (A) add escape state to `Split-OrchestrationCommandLine`; (B) replace the scanner with `Read-CommandLineSegment` from `.claude/hooks/hook-command-scanner.ps1`; (C) strip escapes from the command text before splitting.
- Adopted: A. A backslash outside single quotes consumes the next character; both characters stay in the segment text; the `Balanced` result is unchanged in definition. This mirrors `.claude/hooks/hook-command-scanner.ps1` `Read-CommandLineSegment` lines 375-381 (double-quoted pair), 391-397 (unquoted pair) and 365-372 (no escape handling in single quotes).
- Rationale: B changes the delimiter set (`(`, `)`, `{`, `}`, backtick, `$(`), which would alter D4 row outcomes such as `{}` in `find` arguments, and adds a cross-file dependency to a module declared self-contained. C is lossy and changes the text seen by the tokenizer and by row 18 operand normalization.

### D2: Scope of escape modelling
- Options considered: (A) model all unquoted and double-quoted backslash escapes structurally in the scanner only; (B) special-case only `\;`, `\&`, `\|`; (C) also remove escapes in `ConvertTo-OrchestrationCommandToken`.
- Adopted: A. `ConvertTo-OrchestrationCommandToken`, `Test-OrchestrationCommandTextUnresolvable` and `Test-ExemptOrchestrationOperand` are not changed.
- Rationale: B cannot handle `\\;` correctly (a lookbehind rule keeps `a\\; b` as one segment where the shell runs two commands) and leaves `\"`/`\'` desynchronizing quote state on the epic-scope selector path. C flips two existing allow rows in both runtimes: row 18 (`git add docs\features\active\...`) would tokenize to `docsfeaturesactive...` and deny, and LACS allow 3 (`git -C C:\repo\wt ...`) would lose its rooted drive form. On every input that reaches the scanner on the staging path, the escape-unaware Unresolvable scan and the escape-aware scanner agree on quote state (research section 2), so the Unresolvable docstring remains accurate.

### D3: Test placement and case design
- Options considered: (A) a new suite dot-sourcing the `.claude` and `.codex` helper copies and calling the pure functions directly; (B) extend the two existing CommandExemption suites; (C) separate Claude and Codex test files.
- Adopted: A, at `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, using a `Describe -ForEach` over the two canonical copies with a per-block `BeforeAll` dot-source resolved from `$PSScriptRoot` with forward-slash joins. The suite does not call `Invoke-OrchestrationPreimplementationGateDecision` or any gate-decision path, reads no gitignored state, uses no `origin/main` ref, no `git`, no network, and no Windows-only filesystem path. Windows-looking strings appear only as command-text literals. Backslash fixtures use single-quoted PowerShell literals; newline fixtures use "`n" or `[char]10`, not here-strings.
- Fail-before cases use a mid-line escape (for example `find . -exec cmd {} \; -print`), because a trailing `\;` yields one segment both before and after the fix. Required cases: mid-line `\;`, `\&`, `\|` literal; backslash-newline continuation; `\\;` still splits; `\\\;` does not split; `\&&` splits on the lone `&`; single-quoted backslash (`'a\'; b`) splits; double-quoted backslash (`"a\"; b"`) does not split and is balanced; trailing lone backslash is balanced; unescaped `;`, `&&`, `||`, `|`, `&` each still split; entry-predicate allow and deny controls listed under Technical specifications.
- Rationale: B is rejected because the suites are at 487 and 494 of 500 lines and are the files #713 is most likely to edit. C duplicates fixtures with no behavioural gain. Bundle copies are covered by SHA256 identity in the existing Parity test.

### D4: Mirror synchronization
- Options considered: (A) edit the `.claude/hooks` copy and byte-copy it over the three mirrors; (B) add a sync script.
- Adopted: A. Edit `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, then byte-copy it to `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`. Record the SHA256 of all four files in `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/qa-gates/`. No pack-manifest regeneration: `pack-manifests/core.json` files hold paths only and no file is added or renamed.
- Rationale: this is the procedure recorded by #663 (`rem1-mirror-parity.md`); no sync-script precedent exists for this file set.

### D5: Merge-order independence and the 500-line cap
- Options considered: (A) accept the +2 line growth recommended by research (497 to 499), leaving 1 line of headroom for #713; (B) net-zero line delta by condensing the edited function's own comment-based help in place; (C) move code to a new dot-sourced sibling file.
- Adopted: B. The added escape-tracking lines are offset by condensing the `.DESCRIPTION` text of `Split-OrchestrationCommandLine` (lines 63-66 on base) in place, so the helper file's line count after the edit equals its line count immediately before the edit. All edits stay inside `Split-OrchestrationCommandLine` (its help block and body); no other function is reformatted or touched, and the Unresolvable function and its docstring are not edited.
- Detection step required in the plan: immediately before editing, measure the line count of `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` on the current base (497 on 218b518e, but the value measured at edit time governs, because #713 may have merged first). After editing, assert that the post-edit count equals the pre-edit count and is <= 500. Record both counts in `evidence/qa-gates/`.
- Rationale: A leaves the cap contention with whichever of #710 and #713 merges second; B removes #710 from that contention regardless of merge order. C adds a file and a dot-source edit, which is disproportionate for a two-line change.

### D6: CI platform wording
- Options considered: (A) keep the issue's implication that Pester runs on Linux CI; (B) state the actual CI surface.
- Adopted: B. Pester runs in CI only on `windows-latest` through `.github/workflows/_poshqc.yml` (invoked from `ci.yml`); no Linux Pester job exists. The new suite must nonetheless be platform-neutral by construction (D3 constraints), which is verified by inspection of the test file, not by a Linux CI run.
- Rationale: evidence-first wording; an acceptance criterion that names a non-existent CI job is unsatisfiable.

### D7: Out-of-scope operand finding
- Options considered: (A) fix the `docs/features/active/.\./.\./.\./src/x.ps1` unquoted-operand gap here; (B) record it as a follow-up.
- Adopted: B. The gap (row 18 normalizes `\` to `/`, producing `./` segments with no `..`, while bash removes the escapes and stages `src/x.ps1`) is recorded as a follow-up to be filed separately. #710 neither widens nor closes it: the scanner change does not alter tokenization or operand normalization.
- Rationale: the gap is an allow-side defect in `Test-ExemptOrchestrationOperand`, a different function with different risk, and its fix needs its own test-first confirmation (research D-b).

### D8: Batching under the PowerShell per-batch cap
- Options considered: (A) record an explicit override for four mirror copies in one batch; (B) split into two batches.
- Adopted: B. Batch 1: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`. Batch 2: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`.
- Rationale: `.claude/rules/powershell.md` caps each batch at 3 production files; repository precedent splits mirror sets rather than overriding the cap. The Parity test is expected to fail between batches and must pass after batch 2.

### D9: Tier classification
- Options considered: (A) assign a tier by judgement; (B) apply the uniform gates only.
- Adopted: B. `quality-tiers.yml` is absent at the repository root, so the hook's tier cannot be confirmed. Uniform gates apply: format pass, 0 lint errors, line coverage >= 85% for the changed canonical files, and no coverage regression on changed lines. PowerShell has no branch-coverage gate. The table-driven cases in D3 stand in for property tests, for which PowerShell has no approved library.
- Rationale: tier-dependent obligations cannot be asserted without the source-of-truth file.

## Assumptions, Constraints, Dependencies
- Assumptions: the four helper copies are byte-identical on the base (asserted by the existing Parity test; not re-hashed during research). `.gitattributes` (`* text=auto eol=lf`) keeps line endings stable across platforms.
- Constraints: 500-line cap per file (Parity test and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`); net-zero line delta for the helper file (D5); at most 3 production files per batch (D8); PowerShell 7+ compatibility.
- External dependencies: none. Pester 5.x and PoshQC are already part of the toolchain.

## Data / API / Config Impact
- User-facing or API changes: none beyond the corrected segmentation. Commands with a mid-line escaped operator that were spuriously denied become eligible for the staging exemption when every segment is otherwise exempt.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: no change to CLI flags, config schemas, pack manifests, or `pester.runsettings.psd1`. `CodeCoverage.Path` already lists both canonical helper copies.

## Test Strategy
- Regression tests to add: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, run against both `.claude/hooks` and `.codex/hooks` copies. Proposed `It` names:
  - `treats a mid-line escaped semicolon as literal` (`find . -exec cmd {} \; -print` gives 1 segment equal to the input)
  - `treats an escaped ampersand as literal` (`a\&b c`)
  - `treats an escaped pipe as literal` (`a\|b c`)
  - `treats backslash-newline as a line continuation`
  - `still splits on unescaped <operator>` for `;`, `&&`, `||`, `|`, `&` (data-driven)
  - `still splits after an escaped backslash` (`a\\; b` gives 2)
  - `does not split after an odd run of backslashes` (`a\\\; b` gives 1)
  - `splits on the unescaped ampersand after an escaped one` (`a\&& b` gives 2)
  - `keeps backslash literal inside single quotes` (`'a\'; b` gives 2)
  - `consumes an escaped double quote inside double quotes` (`"a\"; b"` gives 1, Balanced)
  - `does not open a quote on an unquoted escaped double quote` (`a\"` Balanced)
  - `treats a trailing lone backslash as balanced` (`a\`)
  - `exempts a commit whose message contains an escaped semicolon` (entry predicate returns `$true`)
  - `does not exempt a chained command after an escaped backslash` (entry predicate returns `$false`)
- Fail-before evidence: run the new suite against the base helper file before the production edit and record the failing cases in `evidence/regression/`; the mid-line escape cases, backslash-newline, `a\\\; b`, `a\"`, and the commit allow case are expected to fail on base.
- Unit tests: Pester 5.x only; no pytest changes.
- Edge cases and negative scenarios: `\\;`, odd backslash runs, trailing lone backslash, empty string, escapes inside single and double quotes.
- Error handling and logging verification: not applicable (no error paths added).
- Coverage impact and targets: every added line in both canonical copies must be executed; line coverage for `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` >= 85% with no regression on changed lines. Coverage evidence copied to `evidence/coverage/`.
- Toolchain commands: PoshQC format (`mcp__drm-copilot__run_poshqc_format`), PoshQC analyze (`mcp__drm-copilot__run_poshqc_analyze`), then Pester through `Import-Module scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree>` so the worktree's own runsettings are used. Also run `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, both CommandExemption suites, the EpicScope and TriggerScoping suites, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (a local failure caused by gitignored `.claude/state/*` files is the known issue #510 and is not a regression).
- Manual validation steps: inspect the diff of the canonical helper file to confirm the hunk is confined to `Split-OrchestrationCommandLine`; confirm the four SHA256 values are equal.

## Acceptance Criteria
- [x] AC-1: `Split-OrchestrationCommandLine` treats an unquoted backslash-escaped `;`, `&` or `|` as a literal character: `find . -exec cmd {} \; -print`, `a\&b c` and `a\|b c` each return exactly one segment whose text equals the input, verified by the `treats a mid-line escaped semicolon as literal`, `treats an escaped ampersand as literal` and `treats an escaped pipe as literal` tests in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`, and those tests fail against the base helper file (fail-before evidence recorded under `evidence/regression/`).
- [x] AC-2: `Test-ExemptOrchestrationStagingCommand` returns `$true` for `git commit -m fix\;done -- docs/features/active/x/spec.md`, verified by the `exempts a commit whose message contains an escaped semicolon` test in the same file.
- [x] AC-3: Unescaped chain operators continue to split exactly as before: `a; b`, `a && b`, `a || b`, `a | b` and `a & b` each return two segments, verified by the data-driven `still splits on unescaped <operator>` tests.
- [x] AC-4: The fix introduces no bypass: `a\\; b` returns two segments, `a\&& b` returns two segments, `'a\'; b` returns two segments, and `Test-ExemptOrchestrationStagingCommand` returns `$false` for `git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md`, verified by the `still splits after an escaped backslash`, `splits on the unescaped ampersand after an escaped one`, `keeps backslash literal inside single quotes` and `does not exempt a chained command after an escaped backslash` tests.
- [x] AC-5: Quote-state and boundary cases behave per POSIX: `a\\\; b` returns one segment; `"a\"; b"` returns one segment with `Balanced` true; `a\"` and a trailing `a\` return `Balanced` true; backslash-newline returns one segment, verified by the corresponding tests in the same file.
- [x] AC-6: The fix is applied identically to all four copies: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` have equal SHA256 values recorded under `evidence/qa-gates/`, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` pass.
- [x] AC-7: The helper file's post-edit line count equals its line count measured on the current base immediately before editing and is <= 500, with both counts recorded under `evidence/qa-gates/`; the diff of the canonical file touches only `Split-OrchestrationCommandLine`.
- [ ] AC-8: The regression suite passes under Pester locally and in the CI PoshQC Pester job (`.github/workflows/_poshqc.yml`, `windows-latest`), and by inspection it depends on no gitignored state, no `origin/main` ref, no gate-decision path, and no Windows-only filesystem path.
- [x] AC-9: Existing suites that reach the helpers stay green: both CommandExemption suites, the EpicScope and TriggerScoping suites, and the Codex trigger-scoping, mode-resolution and mode-routing suites.
- [x] AC-10: Full PowerShell toolchain passes in a single pass (PoshQC format, PoshQC analyze with 0 findings, Pester), and line coverage for both canonical helper copies is >= 85% with no regression on changed lines, recorded under `evidence/coverage/`.
- [x] AC-11: The out-of-scope operand gap (`docs/features/active/.\./.\./.\./src/x.ps1`, D7) is recorded as a follow-up to be filed separately, and no edit is made to `Test-ExemptOrchestrationOperand`.

## Risks & Mitigations
- Technical risk: an escape rule that is too broad could merge segments the shell executes separately (an allow-side bypass). Mitigation: pairwise consumption rather than lookbehind; AC-4 no-bypass cases; operands of a merged segment remain subject to row 19 (every operand must be exempt).
- Technical risk: line-cap or textual conflict with #713. Mitigation: net-zero line delta and hunk confined to `Split-OrchestrationCommandLine` (D5); conflicts, if any, are resolved once in the canonical file and re-copied to the three mirrors.
- Operational risk: mirror drift between batches. Mitigation: the Parity test is run after batch 2 and SHA256 values are recorded.
- Rollback: revert the change and re-run the Parity test.

## Rollout & Follow-up
- Release/rollout steps: merge to `main`; the bundle mirrors ship with the next extension release.
- Post-fix tasks: file a separate issue for the D7 operand gap; notify the #713 planner that #710 leaves the helper file's line count unchanged.
- Links: issue #710; origin #663 `evidence/other/follow-ups.md` item 8; research `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/research/research.2026-09-26T23-05.md`.
