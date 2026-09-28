# Research: preimplementation gate blocks attribution trailers (#713)

- Issue: #713
- Branch: `bug/preimplementation-gate-blocks-attribution-trailers-713`
- Complexity band: C3 (preparation mode; no code changes)
- Researched: 2026-09-27T00-30
- Method: code reading with Read/Grep/Glob in this worktree, plus git and POSIX documentation fetched on 2026-09-27. No shell was available to this researcher, so **no Pester run, hash, or `git` command was executed**. Every behavioural statement below is an analytical trace of the cited code. The plan must confirm each trace with a fail-before run.

## 0. Summary

1. The issue's premise is partly stale on the current tree. Issue #663 (PR #700) already narrowed D4 row 12: `<` and `>` are now rejected only **outside** quotes (`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:30-36,154-157`). A quoted `Co-Authored-By: Name <email>` no longer causes a denial on its own. Two existing tests cover this case (`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:432-465` and the Codex twin at `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1:439-472`).
2. Those #663 fixtures put the trailer **inline in a one-line subject**, which git does not parse as a trailer (section 3.2). The option loop already admits multiple `-m` options (`helpers:384-421`), so a *functional* trailer form (`-m '<subject>' -m '<trailer paragraph>'`) should be admitted today. No test pins it and no skill documents it.
3. Several forms are still denied: `$` or backtick **inside single quotes** (over-strict, because POSIX preserves every character literally there), `--trailer`, `-F <file>`, and both heredoc forms, including Claude Code's default `-m "$(cat <<'EOF' ... EOF)"` recipe.
4. **New finding: a pre-existing bypass.** The exemption does not model the `#` comment introducer. A `#'` at the start of a word desynchronizes the quote tracker from bash, and a later line can then run arbitrary commands, including `git add <production path>`, while the gate allows the line (section 1.5). The finding comes from analysis and was not executed.
5. **Recommendation:** make an in-place, net-zero-line edit to the four byte-identical helpers copies only. The edit (a) treats `$` and backtick as literal inside single quotes, (b) admits `--trailer` as a message-class option on `git commit`, and (c) treats an unquoted `#` as unresolvable. Also pin the multi-`-m` form with tests, and document the admitted forms in the two planner skills and their bundle mirrors. Do not edit either gate file, the pack manifests, the runsettings, or the existing suites. The file set is then disjoint from #707, #708 and #709 and shares only the helpers files with #710, in different functions.

## 1. Current State (file:line, re-derived on this tree)

### 1.1 Call path for a Bash `git commit` with no ready checkpoint

- The Claude gate is registered on `Bash`, `Write|Edit` and `Agent` only (`.claude/settings.json:90-108,150-153,183-186`). Bash semantics govern the command leg.
- `Invoke-OrchestrationPreimplementationGateDecision` reads `command` and calls `Test-ImplementationCommand` (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:362-366`).
- `Test-ImplementationCommand` (`gate:126-161`) scans per-segment `ScanText` from the shared scanner `Read-CommandLineSegment`. Quoted spans and non-wrapper heredoc bodies are masked there (`.claude/hooks/hook-command-scanner.ps1:303-483`, masking at `365-406` and `436-450`). Pattern index 0, `(^|\s)git\s+(add|commit)\b`, is the only leg the exemption can clear (`gate:137,150-157`).
- The exemption `Test-ExemptOrchestrationStagingCommand` (`helpers:438-497`) does **not** use the shared scanner. It runs its own pipeline on the **raw whole command text**:
  1. `Test-OrchestrationCommandTextUnresolvable` (`helpers:110-161`), called at `helpers:469`.
  2. `Split-OrchestrationCommandLine` (`helpers:58-108`), called at `helpers:473`. It splits on `;` `&` `|` LF CR outside quotes (`helpers:93-98`).
  3. `ConvertTo-OrchestrationCommandToken` (`helpers:163-218`) and `Test-ExemptOrchestrationSegmentToken` (`helpers:339-436`) for every segment.
- If the exemption returns true, the command is not implementation and the gate allows at `gate:375-377`, **before** the epic-scope lookup at `gate:389-394`. If it returns false, the command leg consults `Get-OrchestrationEpicScopeDecision` (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:88-127`), which reads local worktree and epic state (`epic-scope:116-117`). Otherwise it falls through to the single-feature deny at `gate:429`.

### 1.2 Which check rejects each character, and why

| Character | Rejecting check | Quote state in which it rejects | Bypass it guards against |
| --- | --- | --- | --- |
| `$` | `helpers:140-142` (`$script:InterpolationCommandCharacters`, `helpers:35`) | **every** state, including single quotes | Parameter expansion (`$VAR`, `${...}`), command substitution (`$(...)`), arithmetic (`$((...))`), and the `$'...'`/`$"..."` quoting forms. Any of these can make an operand or a whole segment differ from the literal text. |
| backtick | same, `helpers:35,140` | every state | Legacy command substitution: a nested command runs and its output is spliced into the line. |
| `<` | `helpers:156-157` (`$script:RedirectionCommandCharacters`, `helpers:36`) | outside quotes only (since #663) | Input redirection, here-documents (`<<`), here-strings (`<<<`), process substitution `<(...)`. |
| `>` | same | outside quotes only | Output redirection, which can write an arbitrary file as a side effect of an allowed line. |
| `\"`, `\'` anywhere; `\` inside `"..."` | `helpers:131-133,148-150` | as stated | An escaped quote moves a span boundary the tracker does not model (#663 CR-1, CR-3). |

The backtick is also PowerShell's escape character. That is irrelevant to this gate because it evaluates Bash commands only (settings matcher above). Test fixtures written as PowerShell single-quoted literals carry `$` and backtick verbatim.

### 1.3 Option table of `Test-ExemptOrchestrationSegmentToken`

`helpers:395-416`: before `--`, a dash-leading token on `git add` denies (`399-401`). On `git commit`, only `-m`/`--message` (value = next token, `402-409`) and `--message=`/attached `-m<text>` (`410-414`) are modelled. Every other option denies (`415`), including `-F`, `--file`, `--trailer`, `-a`, `--amend`. At least one operand is required (`425-427`, D4 row 4), and every operand must be exempt (`430-434`, D4 row 19). The loop repeats per token, so **any number of `-m` options is admitted**.

### 1.4 Heredoc behaviour ("the gate matches whole command text")

- Trigger side: heredoc bodies attached to a non-wrapper segment are masked (#545; `hook-command-scanner.ps1:436-450`; pinned by `CommandExemption.Tests.ps1:245-295`).
- Exemption side: the raw text is scanned, so the issue's statement is accurate for this leg. `git commit -F - <<'EOF' ... EOF` is denied three times over: `<` outside quotes (`helpers:156`), the unmodelled `-F` (`helpers:415`), and body lines that `Split` turns into separate non-git segments (`helpers:93-94`). `git commit -m "$(cat <<'EOF' ... EOF\n)"` is denied at `helpers:140` (`$`).

### 1.5 New finding: `#` comment desynchronization (pre-existing, analytical)

POSIX 2.3 rule 9: a `#` that begins a word starts a comment that runs to the next newline. None of `Test-OrchestrationCommandTextUnresolvable`, `Split-OrchestrationCommandLine`, `ConvertTo-OrchestrationCommandToken` or `Read-CommandLineSegment` models `#` (searches for `'#'` and "comment" in `hook-command-invocation.ps1` and the scanner found no handling). Trace of:

```
git commit -m #'
git add src/prod.ts && git commit -m x
' -- docs/features/active/x/a.md
```

- Gate trace: no `$`, backtick, redirection, or escaped quote, so Unresolvable returns false. `Split` treats `'...'` as one span containing both newlines, so there is one balanced segment. The tokens are `git`, `commit`, `-m`, `#<LF>git add src/prod.ts && git commit -m x<LF>`, `--`, `docs/features/active/x/a.md`. `-m` consumes the long token and the operand is exempt, so the exemption returns true and the gate **allows** (`gate:155-156,375-377`). The trigger scanner also masks line 2 as quoted text.
- Bash trace: line 1 is `git commit -m` plus a comment, so git fails with "switch `m' requires a value". Line 2 is a complete list and **runs**: it stages and commits a production file with no ready checkpoint. Line 3 opens an unterminated quote and raises a syntax error only after line 2 has already run.
- Neither #663's follow-up list (`docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md`) nor #710's spec records this. #710 lists comment modelling as out of scope.
- Relevance to #713: option A below admits `$`/backtick only inside tracker-single-quoted spans. That is sound only if the tracker's quote state equals bash's quote state, and `#` is the remaining unmodelled construct that breaks that equality (section 4.2). The bypass already admits arbitrary commands without `$`, so A does not create it. However, AC3 ("the relaxation opens no bypass ... chaining ... remain denied") cannot honestly be checked off while the bypass exists.

### 1.6 Surface copies and parity enforcement

| File | Copies | Relation | Enforced by |
| --- | --- | --- | --- |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | `.claude/hooks`, `.codex/hooks`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks` | byte-identical (4) | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1:31-53` (SHA256 across all four; <= 500 lines each); `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30,93-117` (`.codex` root vs bundle SHA; parse; <= 500 lines) |
| `enforce-orchestration-preimplementation-gate.ps1` (Claude vs Codex) | 2 roots + 2 bundles | **runtime-adapted**: Codex adds `apply_patch` marker legs (`.codex/...gate.ps1:137-148`), uses `codex-pretooluse-file-mapping.ps1` (`:11`) and consumes mapped `tool_input` | Claude root vs bundle: decoded-text equality in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` (all `.claude/**`). Codex root vs bundle: SHA in `legacy-codex-hook-contracts.Tests.ps1:111-117` plus text equality in `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-229` |
| `.claude/skills/{parallel-plan,epic-plan}/SKILL.md` | root + Claude bundle | text-identical | `test_push_down_claude_resource_contracts.py:118-143` |

Pack manifests list paths only: Claude `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:36-39`, Codex `.../codex-and-agents-customizations/pack-manifests/core.json:41-42,53`. A new hook file would additionally have to appear in a manifest (`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139`, `test_push_down_codex_and_agents_pack_manifest_completeness.py:218`) and in the Codex dot-source closure (`tests/scripts/dev_tools/test_codex_core_manifest_closure.py:277`). It would also need registering in `CodeCoverage.Path` of both runsettings copies (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:139-147,233-243`; bundle copy checked by `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`). **The recommended design adds no file, so none of these change.** Both canonical helpers copies are already in `CodeCoverage.Path` (`runsettings:143,237`).

### 1.7 Line counts (from Read line numbering in this worktree; the plan must re-measure at edit time)

| File | Lines | Headroom to 500 |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` (and 3 byte copies) | 497 | 3 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 483 | 17 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 487 | 13 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 494 | 6 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 127 | n/a (not edited) |

### 1.8 Existing exemption test structure

Both suites dot-source their gate in `BeforeAll` and drive the pure seam `Invoke-OrchestrationPreimplementationGateDecision` with an explicitly not-ready `-CheckpointRaw` (Claude `CommandExemption.Tests.ps1:16-61`; Codex `...command-exemption.Tests.ps1:22-65`). The Claude suite passes a full `{tool_name, tool_input}` envelope; the Codex suite passes mapped `{command}` JSON (`codex:9-14,27-36`). Both use `-ForEach` data tables and assert `permissionDecision` plus the `PREIMPLEMENTATION_GATE_BLOCKED` prefix. Deny rows reach the epic-scope read path unmocked; #663 follow-up item 6 and sibling #709 own that defect. Neither suite has room for a new context.

### 1.9 Documentation that describes the admitted commit form

- `.claude/skills/parallel-plan/SKILL.md:545-571` and `.claude/skills/epic-plan/SKILL.md:180-~205` ("Integration Commit Form (issue #539)"), plus their bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/skills/`. Neither section mentions trailers, multiple `-m`, quoting, or heredocs.
- A search for "Integration Commit Form"/"pathspec-bearing" outside `docs/features/**` found only those four files and the two test suites. `.agents/skills/epic-plan/SKILL.md` has no such section (Codex-surface documentation gap; out of scope).
- No skill, agent, rule, or `.github` file tells agents to omit `Co-Authored-By`. The single-feature deny reason (`gate:429`) is pinned verbatim by `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, and #707 plans to reuse it.

## 2. External Semantics Relied On (verified by documentation fetch, 2026-09-27)

- POSIX Shell Command Language 2.2.2: single quotes "preserve the literal value of each character within the single-quotes". Inside them, `$`, backtick and backslash are literal. 2.2.3: inside double quotes, `$`, backtick and backslash (before `$`, backtick, `\`, newline, `"`) keep their special meaning. 2.3 rule 9: `#` starts a comment to the next newline. Source: pubs.opengroup.org, utilities/V3_chap02.html.
- `git commit`: "If multiple -m options are given, their values are concatenated as separate paragraphs." `-F <file>`/`--file=<file>`, where `-` means stdin. `--trailer <token>[(=|:)<value>]` adds a trailer. Source: git-scm.com/docs/git-commit. The minimum git version for `git commit --trailer` was **not verified** here; the plan should record `git commit -h` output from the executor host.
- `git interpret-trailers`: the trailer group "must be preceded by one or more empty (or whitespace-only) lines" and must be at the end of the input. `trailer.<key>.cmd` runs a configured shell command. Source: git-scm.com/docs/git-interpret-trailers.

Consequences:

1. A one-line `-m "subject ... Co-Authored-By: X <e>"` produces **no** trailer, because nothing precedes the line with a blank line. The #663 fixtures prove the character handling, not attribution.
2. `-m s -m 'Co-Authored-By: X <e>' -m 'Claude-Session: Y'` makes only `Claude-Session` a trailer, because each `-m` is its own paragraph and only the last paragraph is the trailer group. Both trailers must share **one** `-m` value separated by a literal newline, or be supplied as `--trailer` options.

## 3. Behaviour Before the Fix (analytical)

| # | Command shape (all with `-- docs/features/active/x/plan.md` unless noted) | Current decision | Deciding line |
| --- | --- | --- | --- |
| B1 | `git commit -m '<s>' -m 'Co-Authored-By: C <n@a.com>'<LF>'Claude-Session: https://...'` (both trailers inside one single-quoted `-m`, with a literal newline) | allow | passes `helpers:469-496` |
| B2 | `git commit -m "<s> Co-Authored-By: C <n@a.com>"` (inline, not a real trailer) | allow | pinned `CommandExemption.Tests.ps1:437-447` |
| B3 | `git commit -m 'fix `Foo` handling'` | **deny** | `helpers:140` (backtick) |
| B4 | `git commit -m 'costs $5'` | **deny** | `helpers:140` |
| B5 | `git commit -m '<s>' --trailer 'Co-Authored-By: C <n@a.com>'` | **deny** | `helpers:415` |
| B6 | `git commit -F docs/features/active/x/msg.txt` | **deny** | `helpers:415` |
| B7 | `git commit -m "$(cat <<'EOF' ... EOF)"` (Claude Code default recipe) | **deny** | `helpers:140` |
| B8 | `git commit -F - <<'EOF' ... EOF` | **deny** | `helpers:156` |
| B9 | the section 1.5 `#'` desync line | **allow (bypass)** | no deny path |

## 4. Candidate Approaches

### 4.1 Options evaluated

**(A) Quote-aware interpolation.** Treat `$`/backtick as literal inside single-quoted spans. Keep them unresolvable outside quotes and inside double quotes.
- Bypass analysis: sound when the tracker's quote state equals bash's (section 4.2). Inside double quotes, bash expands `$`/backtick (POSIX 2.2.3), so they stay denied. `$'...'` and `$"..."` put the `$` outside the quote, so they stay denied.
- Cost: one condition at `helpers:140` (`if ($openQuote -ne "'" -and $script:InterpolationCommandCharacters -contains $character)`), plus rewording of the constants comment (`helpers:30-34`) and the docstring (`helpers:115-120`). Net line delta 0 is achievable.
- #710 interaction: a different function (`Unresolvable`, not `Split`). #710's D2 relies on `Unresolvable` still denying `\"`, `\'` and backslash inside double quotes. A must keep those checks unchanged.
- Selected. It is required for the `$`/backtick clause of issue AC2.

**(B) Multiple `-m`.**
- Already admitted (`helpers:384-421`, section 3 row B1). No code change.
- Bypass: none new. Every value is a quoted message token.
- Cost: tests and documentation only.
- Selected as the pinned, documented form. The documentation must state the one-paragraph rule for multiple trailers (section 2, consequence 2).

**(C) `-F <exempt-path>`.**
- Bypass: the message file is data, but `-F -` needs a pipe or redirection (still denied). The path would need modelling as a non-pathspec operand with `-`, `--file`, `--file=` and `-F<path>` variants.
- Cost: about +4 to +6 lines in `Test-ExemptOrchestrationSegmentToken`, which exceeds the headroom without a new file. It also requires a Write step for the message file. Under an exempt tree the file can be staged by accident; outside the repo the path is absolute and host-dependent.
- Rejected. B and D cover attribution without a side file.

**(D) `--trailer`.**
- Bypass: the value is trailer text and never a pathspec. `git add --trailer` still denies (`helpers:399`). The only execution path is a pre-existing repository or user `trailer.<key>.cmd` configuration, which the command line cannot set, because `git -c` is rejected by LACS (`helpers:302-305`).
- Cost: extend `helpers:402` to `-cin @('-m', '--message', '--trailer')` and `helpers:410` with `$candidate.StartsWith('--trailer=')`, then reword the comment at `396-398`. Net line delta 0 is achievable.
- Selected. It is the only single-line form, and git places the trailers correctly, which removes the paragraph-placement error described in section 2.

**(E) Heredoc-body awareness.**
- Bypass analysis: it would have to admit `<<` redirection, distinguish quoted from unquoted delimiters (an unquoted delimiter expands `$`/backtick in the body), and model `-F -`. The `$(cat <<'EOF' ...)` variant would also require admitting a command substitution.
- Cost: large. It needs a new file and re-plumbing of `Split` against #710's concurrent edit.
- Rejected. The heredoc forms are documented as not admitted.

**Deny-reason hint** (append the admitted form to `gate:429`): rejected. The full string is pinned by the EpicScope suite and reused by #707, and the Codex gate has zero headroom.

### 4.2 Why A is sound only together with the `#` fix

With the fix, every construct that can change bash's quote state relative to the tracker is either modelled or denied:

| Construct | Status |
| --- | --- |
| `'`, `"` | modelled |
| `\"`, `\'`, `\` inside `"` | denied (`helpers:131-133,148-150`) |
| unquoted `\X` | cannot change quote state |
| `$'`, `$"`, `${`, `$(` | `$` outside quotes denied |
| backtick outside quotes | denied |
| `<<`, `<<<`, `<(` | `<` outside quotes denied |
| `#` comment | **currently unmodelled; proposed denied** |

History expansion (`!`) is off in non-interactive bash.

Adding `'#'` to the outside-quote character set (`helpers:36`, rejected at `helpers:156-157`) closes the last gap at zero lines. It is fail-closed and over-strict for a mid-word `#` (for example `x#y`), which is accepted. Rename `$script:RedirectionCommandCharacters` to a neutral name such as `$script:OutsideQuoteCommandCharacters`. It is referenced only at `helpers:36,156` in each copy, so the rename is safe.

### 4.3 Recommended design

In-place edits to `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, byte-copied to its three mirrors. The edits are anchored by name, not line number:

1. **Constants block** (the comment above `$script:InterpolationCommandCharacters` and the two `[char[]]` declarations): add `'#'` to the outside-quote set and reword the comment. Net 0 lines.
2. **`Test-OrchestrationCommandTextUnresolvable`**: skip the interpolation check when the open quote is `'`. Update the docstring (keep the backslash sentences verbatim). Net 0 lines.
3. **`Test-ExemptOrchestrationSegmentToken`**: admit `--trailer <value>` and `--trailer=<value>` on `commit` only, alongside `-m`/`--message`, and reword the three-line comment. Net 0 lines.

Nothing else changes. `Split-OrchestrationCommandLine` (owned by #710), both gate files, modes, epic-scope, manifests and runsettings are untouched.

## 5. Behaviour Semantics After the Fix

- **Admitted** (with no ready checkpoint and every operand under the five exempt trees):
  - one or more `-m`/`--message`/`--message=` values;
  - one or more `--trailer`/`--trailer=` values on `git commit`;
  - `$`, backtick, `<`, `>` inside single-quoted spans;
  - `<`, `>` inside double-quoted spans.
- **Denied** (unchanged or newly):
  - `$`/backtick outside quotes or inside double quotes;
  - `<`/`>`/`#` outside quotes;
  - escaped quotes, and backslash inside double quotes;
  - unbalanced quotes;
  - any segment that is not an all-exempt `git add`/`git commit`;
  - pathless commits;
  - `--trailer` on `git add`;
  - a trailing `--trailer` with no value (index guard, `helpers:405-407`);
  - `-F`/`--file`; heredoc forms; every previously denied D4 row.
- **Ordering:** `Unresolvable` runs before `Split`, which runs before tokenization. The first false result denies. Allow decisions return before any epic-scope read (`gate:375-377`).

## 6. Requirements Mapping (issue AC to design)

| Issue AC | Mapping | Note for spec |
| --- | --- | --- |
| AC1 trailer admitted | `--trailer` form (D) plus multi-`-m` one-paragraph form (B), decision-level, both runtimes | Name the exact fixtures; do not reuse the inline #663 fixture as proof of attribution |
| AC2 forms documented; `<`,`>`,`$`,backtick inside quotes not denied on their own | `<`/`>`: already true (#663). `$`/backtick: true **inside single quotes only** | Spec must narrow AC2's wording: double-quoted `$`/backtick remain denied (POSIX 2.2.3). Record this as a decision, not a deviation |
| AC3 no bypass | Predicate-level deny table (section 7), including the `#` desync and heredoc rows | The `#` row is a fail-before case, because the bypass exists on base |
| AC4 mirrors byte-identical | 4 helpers copies, SHA256 | Parity + legacy Codex suites; skill docs text-parity via the Python push-down test |
| AC5 fail-before, toolchain | Fail-before exists for A, D and `#`. The `<email>` inline case already passes on base (#663) and cannot fail before | State this explicitly; fail-before evidence under `evidence/regression-testing/` |

Proposed additional AC: the helpers line count after the edit is <= 500 and not greater than the count measured immediately before the edit. The diff of the canonical helpers file touches only the constants block, `Test-OrchestrationCommandTextUnresolvable` and `Test-ExemptOrchestrationSegmentToken`.

## 7. Testing Implications (strategy only)

- **New suite:** `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`, one file following #710 D3's precedent, since the unit is the shared byte-identical helper. It uses `Describe -ForEach` over two runtime descriptors: Claude gate plus envelope builder, and Codex gate plus mapped-`tool_input` builder. Each has its own `BeforeAll` dot-source, resolved from `$PSScriptRoot` with forward-slash joins. This executes the changed lines in both canonical copies, which the coverage gate needs.
- **Allow rows (decision level, not-ready `-CheckpointRaw`):**
  - `--trailer` (separate and `=` forms, two trailers);
  - multi-`-m` with both trailers in one single-quoted paragraph containing a literal newline (use `"...`n..."` or `[char]10`, not here-strings);
  - single-quoted backtick and `$` subjects;
  - a chained `git add ... && git commit ... --trailer ...`;
  - a `-C <absolute>` variant.

  Allow decisions return before the epic-scope read, so they read no local epic state.
- **Deny rows (predicate level):** assert `Test-ExemptOrchestrationStagingCommand` returns `$false` and `Test-ImplementationCommand` returns `$true`, without calling the decision seam. This avoids the unmocked epic-scope resolver (the #709 defect class) and does not depend on whether #707 has added `Get-OrchestrationEpicScopeDecision` to the Codex gate, because Pester cannot `Mock` a command that does not exist. Rows:
  - unquoted `>` after a single-quoted `$` message;
  - `$(...)` and `$VAR` in an operand;
  - `$`, `$(...)` and backtick inside double quotes, including the Claude Code `-m "$(cat <<'EOF' ... EOF)"` recipe;
  - `$'...'`;
  - chaining to a non-exempt segment;
  - a non-exempt pathspec with `--trailer`;
  - a pathless commit with `--trailer`;
  - `git add --trailer`;
  - a dangling `--trailer`;
  - `-F <path>`, `--file=`, `-F - <<'EOF'`;
  - the section 1.5 `#'` desync line;
  - `git add <exempt> # note`.
- **Fail-before rows:** backtick and `$` in single quotes, all `--trailer` allows, and the `#` desync deny. **Pass-before pins:** the multi-`-m` allow and the double-quoted interpolation denies.
- **Constraints:** no temporary files, no `origin/main`, no `git` process, no gitignored state, no Windows-only paths (Windows-looking strings only as command-text literals). CI Pester runs on `windows-latest` only (#710 D6).
- **Existing suites to rerun:** both CommandExemption suites, Parity, `legacy-codex-hook-contracts`, the EpicScope and TriggerScoping suites, the Codex trigger-scoping/mode suites, and `test_push_down_claude_resource_contracts.py`. That last test can fail locally on gitignored `.claude/state/*` files (#510), which is not a regression. The searches in section 1 found no existing fixture that places `$`, backtick, `#`, `--trailer` or `-F` in a position whose outcome changes.

## 8. Sibling Contention

Minimal write set for #713:

- the 4 helpers copies;
- `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/epic-plan/SKILL.md` and their 2 bundle mirrors;
- 1 new test file;
- evidence under the feature folder.

| Sibling | Its write set (from its plan/spec) | Overlap with #713 | Keeping #713 merge-order independent |
| --- | --- | --- | --- |
| #710 | 4 helpers copies (`Split-OrchestrationCommandLine` only, net-zero lines); new `...-helpers.ChainEscape.Tests.ps1` | **Same 4 files, different functions.** #710's hunks lie in `helpers:58-108`; #713's in `30-36`, `110-161`, `395-416`. The two regions are at least 6 unchanged lines apart, so a 3-way merge should apply both | Anchor edits by function name. Re-measure line count at edit time; both items net 0 (ceiling 500). After any rebase, re-copy the canonical file to the 3 mirrors and rerun Parity. Do not relax `\"`/`\'`/backslash-in-`"` checks, which #710 D2 relies on. Keep the #710-cited docstring sentences |
| #707 | Codex gate (3 regions), 2 new Codex siblings, Codex `core.json`, both runsettings, Codex suites incl. `legacy-codex-hook-contracts` | **None** under the recommended design, which adds no file and edits no gate, manifest, runsettings or legacy suite | Avoid decision-level Codex deny tests (they would change behaviour once #707 adds the epic-scope leg). Do not assert the gate reason string beyond the prefix |
| #708 | Completion-consistency hook and suites | None (its spec cites the gate and helpers paths; plan phase 0 should confirm no helpers edit) | Re-read #708's final diff at rebase |
| #709 | Claude gate suites incl. the `CommandExemption` suite (adds epic-state mocks) | None. #713 does not edit existing suites | The new suite must itself avoid unmocked epic-state reads (predicate-level denies) |

General rules:

- Use text anchors rather than line numbers.
- Never assert a sibling's intermediate state.
- Parity tests compare copies with each other at execution time.
- Rebase on `main` before the PR and rerun Parity, legacy Codex, bundle-parity and line-cap checks after every rebase.

## 9. Decision List

- **D1: which forms to admit.** Options: A, B, C, D, E (section 4.1). **Recommended: A + D, with B pinned and documented. C and E rejected.**
- **D2: quote scope for `$`/backtick.** Options: (a) single quotes only; (b) single and double quotes. **Recommended: (a).** Bash expands both characters inside double quotes. The spec narrows issue AC2's wording to match.
- **D3: `--trailer` admission.** Options: (a) admit on `commit` only, net-zero lines; (b) defer. **Recommended: (a).** It gives a single-line form, and git places trailers correctly.
- **D4: `-F <file>`.** Options: admit / reject. **Recommended: reject** (side file, line budget, no attribution benefit over D).
- **D5: heredoc forms.** Options: model / document as not admitted. **Recommended: document as not admitted,** naming the Claude Code `$(cat <<'EOF' ...)` recipe and `-F - <<'EOF'`.
- **D6: `#` comment desync.** Options: (a) fix here by adding `#` to the outside-quote set, 0 lines, plus a fail-before deny row; (b) record as follow-up only. **Recommended: (a).** A's soundness depends on it, and AC3 cannot be checked off with a known chaining bypass. Report it as pre-existing in the PR.
- **D7: code placement.** Options: (a) in place in helpers, net-zero; (b) new dot-sourced file. **Recommended: (a).** Option (b) requires 4 new copies, 2 manifest entries, 2 runsettings entries, a `SharedModuleNames` entry and a closure update, and collides with #707's write set.
- **D8: test layout.** Options: (a) one new file under `tests/scripts/claude-hooks/` over both runtimes; (b) one file per runtime. **Recommended: (a)**, following #710 D3's precedent. Existing suites are not extended (487 and 494 lines).
- **D9: deny-assertion level.** Options: decision-level with mocks / predicate-level. **Recommended: predicate-level**, for merge-order independence from #707 and #709.
- **D10: deny-reason hint.** Options: add / leave. **Recommended: leave** (the reason string is pinned by the EpicScope suite and reused by #707; the Codex gate has 0 headroom).
- **D11: documentation targets.** **Recommended:** the "Integration Commit Form" sections of `.claude/skills/parallel-plan/SKILL.md` and `.claude/skills/epic-plan/SKILL.md` plus both bundle mirrors, plus the helpers header comments. Document the `--trailer` form, the one-paragraph multi-`-m` form, the quoting rules, and the non-admitted heredoc forms. The Codex `.agents/skills/epic-plan/SKILL.md` gap is a follow-up.
- **D12: batching.** **Recommended: two batches** under the 3-production-file cap: `.claude` + `.codex` helpers plus the new suite, then the two bundle copies (#710 D8 precedent).
- **D13: fail-before scope.** **Recommended:** record that the `<email>` inline case was fixed by #663 and cannot fail before on this base. Fail-before evidence covers the `$`/backtick, `--trailer` and `#` rows.

## Numeric Derivation Evidence

### N1: number of `enforce-orchestration-preimplementation-gate-helpers.ps1` surface copies (proposed AC: "all four copies byte-identical")

- Complete Family: every file in the repository that defines the preimplementation staging-exemption helpers module.
- Exhaustive Search Scope: the whole worktree, all directories.
- Inclusion Rules: a file named `enforce-orchestration-preimplementation-gate-helpers.ps1`, or a file defining `Test-OrchestrationCommandTextUnresolvable`.
- Exclusion Rules: test files and documents that only mention the name.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate*.ps1`, filtered to the `-helpers.ps1` name.
- Primary Member Set: `.claude/hooks/...-helpers.ps1`; `.codex/hooks/...-helpers.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/...-helpers.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/...-helpers.ps1`.
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: Grep `^function Test-OrchestrationCommandTextUnresolvable` (files_with_matches), whole worktree.
- Cross-check Member Set: the same four paths.
- Cross-check Count: 4
- Member-set Comparison: identical after normalizing to repo-relative paths. The `HelpersSurfaceRoots` list in `Parity.Tests.ps1:18-23` names the same four roots.

### N2: number of callers of `Test-OrchestrationCommandTextUnresolvable` per copy (proposed claim: the change affects only the staging-exemption entry predicate)

- Complete Family: every invocation of `Test-OrchestrationCommandTextUnresolvable` in production PowerShell, TypeScript, or Python.
- Exhaustive Search Scope: the whole worktree excluding `docs/**`.
- Inclusion Rules: a call site (not the definition).
- Exclusion Rules: the `function` definition line.
- Primary Search Strategy or Query Expression: Grep `CommandTextUnresolvable`, glob `!docs/**`, content mode.
- Primary Member Set: `helpers:469` in each of the four copies (definitions at `:110` excluded).
- Primary Count: 1 per copy (4 total).
- Cross-check Search Strategy or Query Expression: Grep `Test-OrchestrationCommandTextUnresolvable|Split-OrchestrationCommandLine|ConvertTo-OrchestrationCommandToken|Test-ExemptOrchestrationStagingCommand` over `{.claude/**,.codex/**,scripts/**}`, plus Grep `Unresolvable` over `extensions/drm-copilot/src` (0 files).
- Cross-check Member Set: `.claude` and `.codex` helpers `:469` (bundle copies outside that glob, byte-identical per N1); no TypeScript port.
- Cross-check Count: 1 per canonical copy.
- Member-set Comparison: agree. The epic-scope module calls `Split` and `ConvertTo-...Token` only (`epic-scope:77,81`), never `Unresolvable`.

### N3: number of documentation files carrying the "Integration Commit Form" section (proposed AC: docs updated in all four)

- Complete Family: every non-feature-folder file containing the section.
- Exhaustive Search Scope: the whole worktree excluding `docs/features/**`.
- Inclusion Rules: SKILL documents containing the heading.
- Exclusion Rules: the test suites that contain the phrase "pathspec-bearing" in an `It` name.
- Primary Search Strategy or Query Expression: Grep `Integration Commit Form|pathspec-bearing`, files_with_matches, glob `!docs/features/**`.
- Primary Member Set: `.claude/skills/parallel-plan/SKILL.md`, `.claude/skills/epic-plan/SKILL.md`, and their two `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...` mirrors (the two test suites excluded).
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: Glob `**/{parallel-plan,epic-plan}/SKILL.md` (6 files), then inspect which carry the section.
- Cross-check Member Set: the same four. `.agents/skills/epic-plan/SKILL.md` and its Codex bundle mirror lack the heading (absent from the primary grep).
- Cross-check Count: 4
- Member-set Comparison: identical.
