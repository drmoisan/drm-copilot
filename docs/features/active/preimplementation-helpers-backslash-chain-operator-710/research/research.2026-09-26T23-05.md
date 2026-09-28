# Research: preimplementation-helpers-backslash-chain-operator (#710)

- Issue: #710
- Branch: bug/preimplementation-helpers-backslash-chain-operator-710
- Base: origin/main 218b518e (worktree `agent-a878156ba992c808e`)
- Timestamp: 2026-09-26T23-05
- Requirements source: `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/issue.md`
- Origin: #663 `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md` item 8 (line 25)

All findings below were verified by reading the cited files in this worktree. Behavioural statements about shell semantics and about inputs that were not executed are marked as analytical. No command was executed in this session (the research agent has read-only file tools), so no evidence artifact under `evidence/` was produced.

## 1. Current State

### 1.1 The four copies

| Path | Lines |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 |

All four exist and report the same line count and the same function line numbers (grep hits at 58, 110, 163, 438, 469, 473, 488 in every copy). Byte identity is asserted by SHA256 in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:31-42`; the last recorded hash evidence is `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/qa-gates/rem1-mirror-parity.md` (all four `5bb872e2...81d7f`). Byte identity was not re-hashed in this session.

**Headroom constraint (load-bearing):** each copy is 497 lines against the 500-line cap, which is asserted by the Parity test (`...Parity.Tests.ps1:44-53`) and by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:93-106` (the helpers file is in `SharedModuleNames`, line 30). The fix has at most 3 lines of net growth available.

### 1.2 Functions in the helpers file

| Function | Lines | Role |
| --- | --- | --- |
| `Split-OrchestrationCommandLine` | 58-108 | Chain scanner (D4 row 13). **Defect site.** |
| `Test-OrchestrationCommandTextUnresolvable` | 110-161 | D4 row 12 as narrowed by #663: `$`/backtick anywhere, `<`/`>` outside quotes, `\"` or `\'` anywhere (line 131), `\` inside a double-quoted span (line 148) all return true. |
| `ConvertTo-OrchestrationCommandToken` | 163-218 | Whitespace tokenizer with quote stripping; no escape handling. |
| `Test-ExemptOrchestrationOperand` | 220-276 | Row 18 normalizes `\` to `/` (line 246) before prefix tests. |
| `Test-ExemptOrchestrationSelector` | 278-337 | LACS L1-L8 (#671). |
| `Test-ExemptOrchestrationSegmentToken` | 339-436 | Per-segment git add/commit recognizer. |
| `Test-ExemptOrchestrationStagingCommand` | 438-497 | Entry predicate: Unresolvable (469) then Split (473) then per-segment tokenize and classify (486-495). |

### 1.3 The scanner's state machine (defect)

`Split-OrchestrationCommandLine` (lines 74-107) holds one state variable, `$openQuote` (`[char]0`, `'`, or `"`):

- Inside a quote (79-85): only the matching quote character is significant; everything else is appended. Backslash is not examined, so `"a\"b"` closes at the escaped quote.
- Outside quotes (87-91): `'` or `"` opens a span. A preceding backslash is not examined, so an unquoted `\"` or `\'` opens a span the shell never opens.
- Outside quotes (93-98): `;`, `&`, `|`, LF, CR each end a segment. A preceding backslash is not examined. **This is the reported defect**: unquoted `\;`, `\&`, `\|` split.
- Backslash-newline (line continuation) splits on the newline.
- `Balanced` is `$openQuote -eq [char]0` at end of scan (105). Empty and whitespace-only segments are dropped (106).

Observation relevant to regression-test design (analytical): a *trailing* `\;` does not increase the segment count, because the empty segment after it is dropped by line 106. `find . -exec cmd {} \;` yields one segment both before and after the fix (only the segment text differs: `find . -exec cmd {} \` versus `find . -exec cmd {} \;`). A fail-before test must use a mid-line escape (for example `find . -exec cmd {} \; -print`, 2 segments before, 1 after) or assert segment text.

### 1.4 Callers of `Split-OrchestrationCommandLine` and their decisions

| Caller | Location | Decision made from the segments |
| --- | --- | --- |
| `Test-ExemptOrchestrationStagingCommand` | helpers:473 (all four copies) | Allow-side exemption only. Guarded by `Test-OrchestrationCommandTextUnresolvable` at 469. Unbalanced -> false (474-477); zero segments -> false; every segment must tokenize to an all-exempt `git add`/`git commit` invocation. A false result leaves the gate's staging trigger in force. Consumed by `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:155` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:170` (and the two bundle mirrors of those gates). |
| `Get-OrchestrationEpicScopeSelector` | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:77` (and its bundle mirror) | Returns the `-C` value of the first segment, or `$null` if unbalanced or empty (78-80). Not guarded by the Unresolvable check. Feeds `Resolve-EpicScopeCheckpoint -WorktreeSelector` (line 117), which selects epic scope versus the single-feature path. No Codex epic-scope sibling exists on origin/main. |

No test calls `Split-OrchestrationCommandLine` directly (grep over `tests/` for the function name: 0 matches).

Observable impact today (analytical): `git commit -m fix\;done -- docs/features/active/x/spec.md` passes the Unresolvable check (no `$`, backtick, quote escape, or unquoted redirection), is split into `git commit -m fix\` and `done -- docs/...`, the second segment is not a git invocation, the exemption returns false, and the staging trigger denies when no ready checkpoint exists. The shell executes one `git commit` whose message is `fix;done`. This is the spurious deny.

## 2. POSIX Semantics to Adopt

Rules (POSIX Shell Command Language 2.2.1-2.2.3; bash follows them for these cases):

1. Unquoted `\X`: the backslash quotes the next character, which becomes literal. `\;`, `\&`, `\|`, `\"`, `\'` are literals and neither split nor open a span.
2. Unquoted `\<newline>`: line continuation; both characters are removed and nothing splits.
3. Inside single quotes: backslash is literal; the next `'` closes the span. `'a\'` is closed.
4. Inside double quotes: backslash escapes only `$`, backtick, `"`, `\`, newline; before any other character both are literal. For the scanner's purposes (quote tracking and splitting) consuming the following character as a pair is equivalent to the POSIX rule, because only `"` and `\` affect state inside a double-quoted span and no split occurs inside a span.
5. Trailing lone backslash at end of input: literal (bash `-c` behaviour, analytical). It affects neither splitting nor balance.

Required no-bypass cases (AC-2):

| Input | Shell segments | Required scanner result |
| --- | --- | --- |
| `a\; b` | 1 | 1 |
| `a\\; b` | 2 (`\\` is a literal backslash, `;` is live) | 2 |
| `a\\\; b` | 1 | 1 |
| `a\&& b` | 2 (literal `&` then background `&`) | 2 (lone `&` splits) |
| `a\|| b` | 2 | 2 |
| `'a\'; b` | 2 | 2 |
| `"a\"; b"` | 1 | 1, Balanced |
| `a\` + LF + `b` | 1 | 1 |
| `a\` (end) | 1 | 1, Balanced |

Pairwise consumption (a backslash outside single quotes consumes the next character unconditionally) produces every row above. A lookbehind rule of the form "operator preceded by `\` is literal" does not: it keeps `a\\; b` as one segment, where the shell runs two commands. That is why the fix must track escape state rather than inspect the previous character.

No-bypass argument (analytical). After the fix the scanner and the shell agree on quote state and segment boundaries for every input except constructs the scanner still does not model (comments `#`, heredoc bodies, `$'...'`). In each of those the scanner splits more, or reports unbalanced, never less. Where the new scanner stops splitting (an escaped operator), the shell also does not split, so the extra words are operands of the same `git` invocation and row 19 (all operands must be exempt) still applies: for example `git add docs/features/active/x \&\& touch src/y` tokenizes to operands `\&\&` (normalized to `/&/&`, rooted, denied), `touch`, and `src/y`, so the line is denied.

Interaction with the Unresolvable check (analytical). The Unresolvable check returns true for every input containing `\"`, `\'`, or a backslash inside a double-quoted span. On every input where it returns false, the only backslashes left are unquoted `\X` with X not a quote, or backslashes inside single quotes; neither changes quote state in either machine. So on every input that reaches line 473, the escape-aware splitter and the escape-unaware Unresolvable scan agree on quote state. The Unresolvable docstring sentence "Quote state is tracked with the same state machine as Split-OrchestrationCommandLine" (lines 115-116) stays accurate in effect and does not need editing. Leaving it alone matters for merge-order independence (section 6).

## 3. Precedent in Other Scanners

- `.claude/hooks/hook-command-scanner.ps1` `Read-CommandLineSegment` (lines 303-483) is the escape-aware precedent: inside double quotes a backslash plus the next character is consumed as a pair (375-381); outside quotes likewise (391-397); inside single quotes no escape handling (365-372); a trailing lone backslash (`$next -eq [char]0`) falls through as a literal. `.codex/hooks/hook-command-scanner.ps1` carries the same lines (375, 391). The fix should mirror these semantics.
- `hook-command-scanner.ps1:73` is precedent for a one-line `if (...) { ...; ... }` block in these hooks passing PoshQC format and analyze. `scripts/powershell/PoshQC/settings/pssa.settings.psd1` enables no line-length rule.
- The gate already uses `Read-CommandLineSegment` for the trigger scan (`enforce-orchestration-preimplementation-gate.ps1:143`), so after the fix the trigger scan and the exemption scan agree on escaped operators.
- `ConvertTo-CommandLineToken` in the scanner (49-97) copies the helpers tokenizer and also has no escape handling, so leaving the helpers tokenizer unchanged keeps the two tokenizers consistent.
- `.claude/hooks/validate-bash.ps1`, `hook-command-invocation.ps1`, and `enforce-promotion-mcp-only.ps1` contain no backslash-escape handling (grep for `-eq '\'` across `.claude/`: only helpers:148 and scanner:375/391).

## 4. Tests, Parity Enforcement, and What Must Be Updated

### 4.1 Existing suites that exercise the helpers

| Suite | Lines | Relevance |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 487 | Dot-sources the Claude gate. Row 18 allow (line 100-102, unquoted `docs\features\...`), rows 16b/16c (230-231, unquoted `C:\...` and `\\server\...`), LACS allow 3 (304, `git -C C:\repo\wt ...`), #663 escaped-quote denies (467-486). No room for new cases. |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 494 | Codex mirror of the above (row 18 at 104, 16b/16c at 234-235, LACS allow 3 at 311). No room for new cases. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | 54 | SHA256 identity of all four copies, and the 500-line cap. |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | - | Parse, 500-line cap, and root/bundle hash identity for the two Codex copies (lines 93-114, `SharedModuleNames` line 30). |
| `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | - | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (118-143): every `.claude` file must equal its bundle copy as decoded text. Known local-only failure from gitignored `.claude/state/*` files (issue #510). |
| `...EpicScope.Tests.ps1`, `...TriggerScoping.Tests.ps1`, `...Tests.ps1`, and the Codex trigger-scoping, mode-resolution, and mode-routing suites | - | Reach the helpers through the gate; must stay green. |

Existing rows that contain backslashes (row 18, 16b, 16c, LACS allow 3, and the #663 escaped-quote rows) keep their outcomes under the recommended fix (analytical): none has a backslash before `;`, `&`, `|`, or a line break, and the escaped-quote rows are denied by the Unresolvable check before the splitter runs. The `'it'\''s ...` idiom row changes from unbalanced to balanced inside the splitter (which matches the shell) but is still denied at line 469.

### 4.2 Parity mechanics and regeneration

- Pack manifests (`extensions/drm-copilot/resources/*/pack-manifests/core.json`) list paths only. Grep for `sha256|hash` across `pack-manifests/*.json`: 0 matches. **No manifest regeneration is required**, and no manifest entry changes because no file is added or renamed.
- No repo-to-bundle sync script exists. `scripts/dev_tools/push_down_claude_customizations.py` publishes *from* the bundle *to* a destination workspace (header lines 1-16, `BUNDLE_ROOT_RELATIVE_DIR` line 67-69). Mirrors are updated by a byte copy of the edited canonical file over the other three, for example `Copy-Item -LiteralPath .claude/hooks/<file> -Destination <each mirror path>`, followed by `Get-FileHash -Algorithm SHA256` over all four. This is the procedure recorded in #663 `rem1-mirror-parity.md`.
- `.gitattributes` line 1 is `* text=auto eol=lf`, so checkout does not change line endings across platforms.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` need no change (section 5).

## 5. Pester Coverage and How to Run

- `CodeCoverage.Path` is an explicit per-file allow-list. It already lists `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (line 143) and `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (line 237). The bundle mirror runsettings carries the same two entries at the same lines. Bundle copies are not measured; they are guarded by byte identity (comment at runsettings 283-285).
- Coverage output: `artifacts/pester/powershell-coverage.xml` (CoverageGutters), JUnit at `artifacts/pester/pester-junit.xml`. Evidence copies belong under `docs/features/active/preimplementation-helpers-backslash-chain-operator-710/evidence/<kind>/`.
- Because both canonical copies are measured by path, the new lines in *each* canonical copy need test execution. Existing row-18 and 16b/16c cases already drive unquoted backslashes through both copies' splitter; the new suite should still exercise both canonical copies directly (section 8, D-c).
- Direct invocation, following the CI step at `.github/workflows/_poshqc.yml:38-42`: `Import-Module <worktree>/scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root <worktree>` (the default `-SettingsPath` is the repository runsettings; `PoshQC.Testing.psm1:151-159`). This uses the worktree's own settings, unlike the MCP runner, which team notes report reads the installed extension's settings. A focused run is `Invoke-Pester -Path <test file>`; it does not produce the canonical coverage artifact.
- CI: Pester runs only in `_poshqc.yml`, on `windows-latest` (line 10), invoked from `ci.yml:23-24`. No workflow runs Pester on Linux: the `ubuntu-latest` jobs are Python quality checks, shell coverage (bats/kcov), and the TypeScript and extension tests. See section 7.

## 6. Sibling Interaction and Merge-Order Independence

Sibling documents for #707, #708, #709, and #713 are not present in this worktree (glob over `docs/features/**` found none), so the statements below are inferences from issue titles and from the #663 follow-ups list.

- **#713 (attribution trailers: `<`, `>`, `$`, backtick, heredoc in commit messages).** The function it would most plausibly touch is `Test-OrchestrationCommandTextUnresolvable` (110-161): the `$`/backtick rule (140-142), the escaped-quote early return (130-133), and the double-quote backslash rule (147-150). Heredoc-form commit messages (`-F - <<'EOF'` or `-m "$(cat <<'EOF' ...)"`) contain newlines, so #713 may also change the newline delimiter in `Split-OrchestrationCommandLine` (93-94) or add heredoc state, and may touch `ConvertTo-OrchestrationCommandToken`. It may also change the gate file (`enforce-orchestration-preimplementation-gate.ps1`).
- **#707 (Codex gates 4-5 epic scope).** The #663 follow-ups item 1 names `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and the Codex completion hooks. A Codex epic-scope sibling modelled on the Claude one would call `Split-OrchestrationCommandLine` and would pick up the fixed behaviour unchanged. A helpers edit by #707 is not expected.
- **#708 and #709.** Unknown scope; no local artifacts.

Structuring #710 for merge-order independence:

1. Confine the production hunk to `Split-OrchestrationCommandLine`: one line added after line 76 (`$escaped = $false`) and one line added as the first statement of the loop body (after line 78). Do not touch lines 79-107 (the quote branch, operator branch, and return), so a #713 edit to the operator or newline branch at 93-98 is at least about 14 lines away from this hunk.
2. Update the splitter docstring *in place* (lines 63-66: replace "Quote state is tracked while scanning so a chain operator inside a quoted span does not split." with an equal-length sentence covering backslash escapes) rather than adding lines. Do not edit the Unresolvable function or its docstring (section 2 shows its wording stays accurate).
3. No reformatting of unrelated lines; run PoshQC format only on the touched file and confirm the diff contains only the intended hunk.
4. The line cap is the real cross-item contention. #710 as recommended takes the file from 497 to 499 lines. If #713 also adds lines to the helpers file, the second item to merge can exceed 500 even though both pass alone; the Parity and legacy-codex cap assertions will fail on the rebased branch. Tell the #713 planner that the helpers file has 1 line of headroom after #710 (3 before), so #713 either stays net-neutral or relocates code to a new dot-sourced sibling (the precedent in the gate file header, lines 11-24).
5. Textual conflicts, if any, occur identically in all four copies. Resolve the conflict once in `.claude/hooks/...-helpers.ps1`, byte-copy the result over the other three, and re-run the Parity test. There are no manifest hashes to conflict.
6. Regression tests go in a new file (D-c), so they cannot conflict with #713 edits to the existing CommandExemption suites.

## 7. Linux and CI Portability

- Test only the pure helpers (`Split-OrchestrationCommandLine`, `Test-ExemptOrchestrationStagingCommand`) by dot-sourcing the helpers file. It has no imports and no I/O (header lines 5-10). Do not drive deny assertions through `Invoke-OrchestrationPreimplementationGateDecision`: its deny path reaches `Get-OrchestrationEpicScopeDecision`, which reads gitignored `artifacts/orchestration/epic-orchestrator-state.json` through the unmocked resolver (#663 follow-ups item 6, CR-4).
- Resolve paths with `$PSScriptRoot`-relative forward-slash joins, as in the Parity test (lines 16-28). Windows-looking strings such as `C:\repo\wt` are acceptable as command-text literals only; never as filesystem paths.
- Build newline cases with explicit "`n" in double-quoted PowerShell strings, or with `[char]10`, not here-strings. This keeps fixtures independent of line endings even though `.gitattributes` forces LF.
- Use single-quoted PowerShell literals for backslash fixtures. PowerShell does not treat `\` as an escape, so `'a\\; b'` is the four-character prefix `a`, `\`, `\`, `;`.
- No dependency on `origin/main`, `git`, or the network. The Parity test reads the four files only.
- AC-4 says "Pester on both Windows and Linux CI". No Linux Pester job exists (section 5). With the constraints above the suite is platform-neutral, but the Linux half of AC-4 can be met only by a local or WSL run, not by an existing CI job. The planner should either reword AC-4 or state how Linux execution is evidenced.

## 8. Design Decisions

### D-a: Where to implement escape handling

- Option A (recommended): add escape state to `Split-OrchestrationCommandLine` itself, mirroring `hook-command-scanner.ps1:375-397`.
- Option B: replace the splitter with `Read-CommandLineSegment` from `hook-command-scanner.ps1`. Rejected: that scanner also treats `(`, `)`, `{`, `}`, backtick, and `$(` as delimiters, so it would change D4 row outcomes (for example `{}` in `find` arguments), and it would add a cross-file dependency to a module whose header declares it self-contained.
- Option C: pre-process the command text by removing escapes before splitting. Rejected: the result is lossy, and it changes the text seen by the tokenizer and by operand normalization (row 18).

**Recommendation: Option A.** Proposed shape (unverified draft, +2 lines):

```powershell
    $openQuote = [char]0
    $escaped = $false

    foreach ($character in $CommandText.ToCharArray()) {
        if ($escaped -or ($character -eq '\' -and $openQuote -ne "'")) { $escaped = -not $escaped; [void]$current.Append($character); continue }
        if ($openQuote -ne [char]0) {
```

The escaped character and the backslash are both appended, so segment text is unchanged and later stages still see the original characters. `Balanced` is unchanged: `$escaped` does not feed it, so a trailing backslash stays balanced (rule 5).

### D-b: Scope of escape modelling

- Option A (recommended): model escapes structurally in the splitter only, for all characters (unquoted and double-quoted pairs, none in single quotes). Leave `ConvertTo-OrchestrationCommandToken`, `Test-OrchestrationCommandTextUnresolvable`, and `Test-ExemptOrchestrationOperand` unchanged.
- Option B: special-case only `\;`, `\&`, `\|`. Rejected: an operator-only rule cannot handle `\\;` (section 2), and it leaves `\"` or `\'` desynchronizing quote state in the epic-scope selector path.
- Option C: POSIX escape removal in the tokenizer as well. Rejected for #710: it flips existing contract rows. Row 18 (`git add docs\features\active\...`, CommandExemption:100-102) would tokenize to `docsfeaturesactive...` and deny, and LACS allow 3 (`git -C C:\repo\wt`) would lose its rooted drive form. Both are allow rows in both runtimes.

**Recommendation: Option A.**

**Pre-existing out-of-scope finding (analytical, not executed; recommend a separate issue).** Because the tokenizer keeps backslashes and row 18 normalizes them to `/`, the unquoted operand `docs/features/active/.\./.\./.\./src/x.ps1` normalizes to `docs/features/active/./././././src/x.ps1`. That contains no `..` segment, so it passes the row 15c/17 test (helpers:258) and the tree prefix test, and `Test-ExemptOrchestrationStagingCommand` returns true. Bash removes the escapes and stages `docs/features/active/../../../src/x.ps1`, which is `src/x.ps1`. This is an allow-side gap on origin/main that #710 does not widen or close. Possible fix for the follow-up: reject `.` segments in `Test-ExemptOrchestrationOperand`, matching LACS L5 in `Test-ExemptOrchestrationSelector` (line 327), or treat an unquoted backslash adjacent to `.` as unresolvable. The follow-up should confirm the behaviour with a test before choosing.

### D-c: Test placement

- Option A (recommended): a new file `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1`. It dot-sources the helpers file directly and runs the same cases against both canonical copies (`.claude/hooks` and `.codex/hooks`) using a `Describe -ForEach` with a per-block `BeforeAll` dot-source. This follows the Parity-test precedent of one claude-hooks suite covering the Codex copy. Bundle copies are covered by hash identity.
- Option B: extend the two CommandExemption suites. Rejected: they are at 487 and 494 of 500 lines, and they are the files #713 is most likely to edit.
- Option C: separate Claude and Codex test files. Acceptable, but it duplicates fixtures for no behavioural gain.

**Recommendation: Option A.** Minimum case set:

- Splitter, positive (escaped is literal): `find . -exec cmd {} \; -print`, `a\&b c`, `a\|b c`, `a\` + LF + `b`. Each gives 1 segment, and the segment text equals the input.
- Splitter, unchanged splitting: `a; b`, `a && b`, `a || b`, `a | b`, `a & b`. Each gives 2 segments.
- Splitter, no-bypass: `a\\; b` gives 2 segments; `a\\\; b` gives 1; `a\&& b` gives 2; `'a\'; b` gives 2.
- Splitter, quote state: `"a\"; b"` gives 1 segment and Balanced; `a\"` gives Balanced true (previously false); a trailing `a\` gives Balanced true.
- Entry predicate, fail-before and pass-after: `git commit -m fix\;done -- docs/features/active/x/spec.md` returns true. Deny control: `git commit -m fix\\; touch src/x -- docs/features/active/x/spec.md` returns false.
- Each fail-before case must be one that differs on origin/main. Section 1.3 explains why a trailing `\;` does not.

### D-d: Mirror sync mechanism

- Option A (recommended): edit `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, byte-copy it over the three mirrors, record four SHA256 values (and optionally `git hash-object`) in an evidence artifact under `evidence/qa-gates/`, and run the Parity test, the legacy-codex contract test, and `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Account for the #510 gitignored-state false failure before reading a local failure as a regression.
- Option B: add a sync script. Rejected: out of scope, and no precedent exists for this file set.

**Recommendation: Option A.** No pack-manifest or runsettings edits are required.

## 9. Required File Changes

| File | Change |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | +2 lines in `Split-OrchestrationCommandLine`; in-place docstring sentence edit (lines 63-66). Result: 499 lines. |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | Byte copy. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | Byte copy. |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | Byte copy. |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1` | New suite (D-c). |

The four production copies are one logical edit, but under the PowerShell change-budget rule (`.claude/rules/powershell.md`: at most 3 production files per batch) they count as 4 files. The planner should either record an explicit override for mirror copies or split the work into two batches: the canonical pair, then the bundle pair.

`quality-tiers.yml` does not exist at the repository root (glob returned no match), so the tier for this hook, and with it any property-test obligation, cannot be confirmed. PowerShell has no property-test library in the approved toolchain. The table-driven equivalence cases in D-c are the proposed substitute.

## Numeric Derivation Evidence

### N1: "four byte-identical copies" (AC-3)

- Complete Family: every tracked file named `enforce-orchestration-preimplementation-gate-helpers.ps1` in the repository.
- Exhaustive Search Scope: the whole worktree, all directories.
- Inclusion Rules: exact file-name match.
- Exclusion Rules: none. Documentation mentions are not files with this name.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate*.ps1`, filtered to the `-helpers.ps1` name.
- Primary Member Set: `.claude/hooks/...`, `.codex/hooks/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...`
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: Grep pattern `^` in count mode with glob `**/enforce-orchestration-preimplementation-gate-helpers.ps1` (a line-content search reporting per-file line counts).
- Cross-check Member Set: the same four paths, each reporting 497 lines.
- Cross-check Count: 4
- Member-set Comparison: after normalizing separators the two sets are identical. A third independent enumeration, `HelpersSurfaceRoots` in `...Parity.Tests.ps1:18-23`, lists the same four roots.

### N2: call sites of `Split-OrchestrationCommandLine`

- Complete Family: every invocation, excluding the function definition, in any `.ps1` file under the worktree.
- Exhaustive Search Scope: the whole worktree, including `tests/`, excluding `docs/`.
- Inclusion Rules: a call expression. Exclusion Rules: the `function` definition and comment or docstring mentions.
- Primary Search Strategy or Query Expression: Grep `Split-OrchestrationCommandLine` (glob `!docs/**`), keeping only lines where the name is a call.
- Primary Member Set: helpers:473 in four copies; epic-scope:77 in two copies (`.claude/hooks` and the claude-customizations mirror).
- Primary Count: 6 call sites, which are 2 distinct canonical callers.
- Cross-check Search Strategy or Query Expression: Grep `\$split\s*=` over `*.ps1` (an assignment-target search), filtered to right-hand sides naming the function.
- Cross-check Member Set: the same six lines. The `$split = $current.IndexOf('=')` hits in `hook-command-invocation.ps1` and the Mermaid tests are unrelated and excluded.
- Cross-check Count: 6
- Member-set Comparison: identical. Test call sites: 0 in both searches.

## Rejected Alternatives (summary)

- Reusing `Read-CommandLineSegment` for the exemption: its delimiter set differs from D4 row 13.
- Operator-only special case: breaks on `\\;`.
- Tokenizer escape removal: flips row 18 and LACS allow 3 contract rows.
- Adding cases to the existing CommandExemption suites: no headroom, and #713 is likely to edit them.
