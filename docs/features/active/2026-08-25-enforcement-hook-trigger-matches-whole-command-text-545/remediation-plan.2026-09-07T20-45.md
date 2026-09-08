# Remediation Plan — enforcement-hook-trigger-matches-whole-command-text (#545) — cycle 2

**Timestamp:** 2026-09-07T20-45
**Authored by:** atomic-planner
**Feature Folder:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
**Work Mode:** `full-bug` (resolved from `issue.md`, `- Work Mode: full-bug`)
**Remediation inputs:** `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/remediation-inputs.2026-09-07T20-45.md`
**Working branch:** `bug/enforcement-hook-trigger-matches-whole-command-text-545-r4`
**Cycle:** 2 of a hard cap of 3. Exit gate: `blocking_count == 0` on the next `feature-review` reaudit.

## Diff anchors — there are two, and they are not interchangeable

- **Feature-wide anchor:** `6dff80ed4596bec088d548b23013e6077e32c484`, the epic base
  (`origin/epic/cleanup-merged-worktrees-hardening-integration`). Used by the frozen-literal
  removal check in `[P5-T5]` and by the whole-feature `--stat` summary in `[P0-T3]`, and by nothing
  else. It is the only correct base for the question "was any frozen literal deleted anywhere in
  this feature", because a literal deleted earlier in the #545 work does not appear as a removed
  line against any later base.
- **Cycle-scope anchor:** `26dba29533ba70f6cd80d14ac3c87ac24ca82aca`, the committed head of the
  working branch at the point this cycle's plan was committed.
  `26dba29533ba70f6cd80d14ac3c87ac24ca82aca` is the parent of the plan commit
  `459d245f893f3337d61496b2602830e381d1d7a3` and is confirmed by
  `git rev-parse 459d245f893f3337d61496b2602830e381d1d7a3^`. Do not read it from a branch ref: both
  `…-545-r3` and `…-545-r4` now point at the plan commit. Used by the changed-file scope
  assertion in `[P5-T4]`, and by nothing else. It is the only correct base for the question "what
  did cycle 2 change", because the branch already carries the entire #545 change and the cycle-1
  remediation.

Every task below that runs `git diff` names which anchor it uses. Neither substitutes for the
other. A scope assertion anchored at the feature-wide commit enumerates the whole feature and can
never report the twenty-one-path cycle scope; a frozen-literal check anchored at the cycle-scope commit
cannot see a deletion made earlier in the feature and would pass vacuously.

---

## Scope

This plan implements **R-2 only**, in its four enumerated instances. R-2 is one root cause:
`ConvertTo-CommandLineToken` collapses a balanced quoted span into ONE token, so on a segment the
scanner reads raw (wrapper-led, live substitution, or unbalanced) every token-based flag read
reports the flag absent. Call sites that read absence as **missing authorization** stay fail-closed
and are correct. Call sites that read absence as **out of scope** fail open. The four below are the
complete set of the latter.

| Instance | Regressing command | At `6dff80ed` | At `26dba295` | Fix location |
|---|---|---|---|---|
| R-2.a | `bash -c "gh pr merge --merge 688"` | denies `EPIC_MERGE_GATE_BLOCKED` | allows | `enforce-epic-merge-gate.ps1` scope filter, both runtimes |
| R-2.b | `bash -c "python … --disposition abandon"` | denies `PARALLEL_ABANDON_BLOCKED` | allows | `enforce-parallel-abandon-gate.ps1`, Claude only |
| R-2.c | `bash -c "gh pr edit 42 --body 'x'"` | denies `PR_AUTHOR_SKILL_BLOCKED` (Case A) | allows | `enforce-pr-author-skill-helpers.ps1`, Claude only |
| R-2.d | `bash -c "cd /x && head f"` | denied by the `cd`-chain pattern | allows | `validate-bash.ps1` `Get-CdChainedReadCommandMatch`, Claude only |

R-2.d is additionally a deviation from the normative D12 call-site rewrite table at `spec.md`
line 1198, which directs `validate-bash.ps1 L105` to "the `cd`-chained pattern evaluated per segment
against `ScanText`". Implementing it un-orphans `$script:CdChainedReadCommandPattern`, which
`.claude/hooks/validate-bash.ps1` line 222 assigns and which no line in either Claude copy reads,
closing code-review finding C-3 as a side effect with no separate task.

### Explicitly out of scope

- **Follow-ups F-1 through F-7**, filed at
  `docs/features/potential/2026-09-07-issue-545-feature-review-follow-ups.md`. No task here fixes
  any of them. F-3 (the orphaned pattern constant) closes incidentally through R-2.d.
- **Code-review C-2 (`rm -rfv`) and C-4 (the 500-line file).** Follow-up candidates, not cycle-2
  work.
- **The two ambient-state failures in unmodified suites**, named in the table below. They are not
  fixed here and are named in every test-bearing acceptance condition so their presence cannot mask
  an R-2 regression.
- **`.codex/hooks/validate-bash.ps1`.** It carries no `cd`-chain rule — `grep` over the whole
  repository returns `CdChainedReadCommandPattern` only in `.claude/hooks/validate-bash.ps1` line
  222 and its bundle mirror line 222. Do not add one. It is therefore also **not** a coverage-carrying
  file for this cycle.
- **AC-22.** Closes on the PR body; the orchestrator carries it. No task here addresses it.
- **No policy edits.** No file under `.claude/rules/` or `.github/instructions/` is modified.

### The binding prohibition

**Do not change `Test-CommandLineFlag` or `Get-CommandLineFlagValue`.** Both iterate
`@($resolved.Segment.Tokens)` unconditionally — `.claude/hooks/hook-command-invocation.ps1` line 449
and line 400 respectively. Adding a raw-containment fallback inside either function would silently
change every call site, including the six that are correctly fail-closed today, and would make
`Get-CommandLineFlagValue` return a value it cannot parse from a nested command line. The fix
belongs at the call sites. A shared helper is permitted only as a **new, separately named
predicate**, which is what `[P1-T4]` introduces.

### The fail-closed-correct call sites that must NOT change

The remediation inputs state "four". Re-derived against the current tree, the complete set of
`Test-CommandLineFlag` and `Get-CommandLineFlagValue` consumers whose flag-absence path is
fail-closed-correct is **six call sites across five files in the two canonical runtimes**, and
twelve counting the bundle mirrors, which are byte-identical copies. The count is recorded here
because a later reviewer will check that this plan left them untouched.

| # | Call site | Reader | Why absence is fail-closed today |
|---|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:164` | `Test-CommandLineFlag '--force'` | `$null` path → checkpoint lookup matches no recorded `worktree_path` → deny |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:94` | `Test-CommandLineFlag '--force'` | identical body to #1 |
| 3 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1:58` | `Test-CommandLineFlag '--force'` | identical body to #1 |
| 4 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:109` | `Get-CommandLineFlagValue '--base'` | `$null -eq $baseValue` → `EPIC_BASE_BRANCH_MISMATCH` deny (line 110) |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1:169` | `Get-CommandLineFlagValue '--merge'` | `$null` → no explicit PR number → parallel branch denies |
| 6 | `.codex/hooks/enforce-epic-merge-gate.ps1:61` | `Get-CommandLineFlagValue '--merge'` | identical to #5 |

Sites 5 and 6 sit in files this plan edits. The plan edits the **scope filter** in those files
(line 397 Claude, line 131 Codex) and does not touch the PR-number resolver. `[P0-T10]` records the
pre-edit body of all six; `[P5-T3]` re-verifies that all six are byte-unchanged.

---

## Standing constraints carried into every task

1. **Copy-set parity.** Every `.claude/**` edit mirrors byte-identically into
   `extensions/drm-copilot/resources/claude-customizations/.claude/**`; every `.codex/**` edit into
   `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/**`. Re-verify with
   `cmp -s` after each pair and after any stage that may rewrite a file.
2. **Literal text is frozen.** No reason-code string changes and no denylist literal changes. Rule
   R2 governs the literal text; only the comparison primitive and its operand may change. The frozen
   set is: the six `Get-BlockedBashPattern` literals, the five preimplementation trigger patterns,
   the promotion hook's four forbidden tokens, its two `gh` expressions and its
   `$ghApiIssuesPostPattern` declaration line, `$script:CdChainedReadCommandPattern`, and the two
   abandon token constants at `.claude/hooks/enforce-parallel-abandon-gate.ps1` lines 41 and 42.
3. **The abandon token seam.** `tests/scripts/dev_tools/test_parallel_abandon_token_seam.py`
   function `test_hook_states_each_token_exactly_once` asserts
   `read_text(HOOK_PATH).count(token) == 1` for each of the two tokens, over the whole file text of
   `.claude/hooks/enforce-parallel-abandon-gate.ps1`. **A comment counts.** Neither literal may be
   restated anywhere in that file — not in code, not in a comment, not in a doc-comment. Derive the
   option name and value by splitting `$script:AbandonDispositionToken`, exactly as
   `Test-ParallelAbandonSegmentDisposition` already does at lines 118–124, and reference the
   confirmation token only through `$script:AbandonConfirmToken`. Both assignments stay at lines 41
   and 42 in their existing single-assignment form.
4. **Every touched file stays at or under 500 lines.**
   `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at exactly 500 with zero
   headroom. R-2 does not touch it and no task here may. Current counts of the files this plan does
   touch, measured in the current tree: `.claude/hooks/hook-command-scanner.ps1` 450,
   `.codex/hooks/hook-command-scanner.ps1` 450,
   `.claude/hooks/enforce-epic-merge-gate.ps1` 472 as `wc -l` reports it — the file has no trailing
   newline, so it carries 473 lines of content and 28 lines of `wc -l` headroom,
   `.codex/hooks/enforce-epic-merge-gate.ps1` 174,
   `.claude/hooks/enforce-parallel-abandon-gate.ps1` 331,
   `.claude/hooks/enforce-pr-author-skill-helpers.ps1` 240, `.claude/hooks/validate-bash.ps1` 420.
   The two tightest are the scanner pair (50 lines of headroom each) and the Claude merge gate
   (28 lines by `wc -l`, 27 lines of content). Edit 2 adds 14 lines, so the post-edit count of
   `.claude/hooks/enforce-epic-merge-gate.ps1` is 486 by `wc -l`. Where an edit would exceed 500,
   shorten the added comment prose; do not delete the comment-based help block and do not drop a
   code line.
5. **Evidence paths are non-overridable.** Every artifact this plan names resolves under
   `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`.
   No `artifacts/` sub-path is a valid evidence destination. If any caller supplies one, reject it,
   substitute the canonical path, and record
   `EVIDENCE_LOCATION_OVERRIDE_REJECTED: <supplied path> replaced with <canonical path>`.
6. **Artifact schema.** Every task that names an evidence artifact path writes exactly one artifact
   carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. Where a non-zero exit is
   the expected outcome the artifact additionally carries `ExpectedExitCode: <int>`. `<capture-timestamp>`
   is the executor's own `yyyy-MM-ddTHH-mm` capture time.
7. **PowerShell batch budget.** The cap is 3 production plus 3 test PowerShell files per batch.
   The session id is resolved at runtime, not stated here:
   `.claude/hooks/enforce-powershell-batch-budget.ps1` derives it from `CLAUDE_SESSION_ID`, then
   `<root>/.claude/state/current-session-id`, then its fallback, so it is worktree-specific and the
   cycle-1 value `worktree-agent-a478b73e41951af31-e3281c7b` does not apply to this relaunch. Each
   batch **opens** with a reset task that lists `.claude/state/`, records every
   `powershell-batch-budget.*.json` name observed together with its contents, deletes every such
   file with `rm -f`, then lists the directory again. Bundle mirrors are written with `cp`, which
   does not pass through the PreToolUse hook and therefore consumes no slot. Batch composition, all
   four within the cap:

   | Batch | Production files (canonical) | Test files |
   |---|---|---|
   | A | 2 scanner copies | 2 scanner suites |
   | B | 2 merge-gate copies | 2 merge-gate suites |
   | C | abandon gate, pr-author helpers | 2 suites |
   | D | `validate-bash.ps1` | 1 suite |
8. **Toolchain reality.** `pwsh`, `powershell`, and `cmd` are NOT invocable in this session from any
   context; the runtime guard refuses them. Format is `mcp__drm-copilot__run_poshqc_format`, lint is
   `mcp__drm-copilot__run_poshqc_analyze`, Pester is `mcp__drm-copilot__run_poshqc_test` with
   `scan_folders`, with per-suite and per-case results read from `artifacts/pester/pester-junit.xml`.
   Every test-bearing evidence artifact carries a `TOOLCHAIN_SUBSTITUTION` note naming the substitute
   route actually used. Do not silently skip a stage. The `workspace_root` for every MCP call is
   `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`. Before the
   first MCP call, confirm with `git rev-parse --show-toplevel` that the executing worktree is that
   path; if it is not, record the observed path and stop with `BLOCKED` rather than passing a path
   from another worktree.
9. **Coverage route.** The MCP test runner must NOT be used for any coverage figure: it resolves
   runsettings from the installed VS Code extension and cannot see this branch's `CodeCoverage.Path`
   entries. Coverage comes from a `workflow_dispatch` of `.github/workflows/_poshqc.yml`. **The
   executor has no `gh` in its tool allowlist. The dispatch and the figure-reading are ORCHESTRATOR
   work; the executor consumes supplied figures only.** See `[P0-T9]` and `[P5-T7]`.
10. **Observed success-case output of each tool**, taken from the recorded runs of cycle 1 in the
    cycle-1 worktree rather than from documentation. The run has since relaunched into
    `agent-ae0df3e53c9c9883f`; these are observations of tool behaviour, not of that checkout, so
    they carry over unchanged:
    - `mcp__drm-copilot__run_poshqc_format` exits 0 whether or not it rewrote a file. Its exit code
      alone gates nothing, so every format task additionally records a `git status --porcelain`
      capture before and after plus the SHA-256 of each in-scope file before and after, and states
      the set-difference count between the two porcelain captures.
    - `mcp__drm-copilot__run_poshqc_analyze` prints `ok: true` on a clean run and reports no
      diagnostic count, so `ok: true` is the value asserted.
    - `mcp__drm-copilot__run_poshqc_test` exits with the folder-wide failed-test count, which is
      non-zero in both hook test folders because of the two pre-existing ambient failures. Acceptance
      is therefore stated on per-suite `<testsuite>` counts and per-case `status` attributes read
      from `artifacts/pester/pester-junit.xml`, never on the tool's exit code.
11. **No assertion reversal.** Do not weaken, delete, or reverse any existing test assertion. The
    only reversal authorized by this feature is the single heredoc `It` per side already delivered
    in cycle 1.

### The two pre-existing failures that are tolerated and must not grow

Neither reproduces on a clean CI checkout; both were independently confirmed not change-caused.
They are named here so that "zero failures other than these two" is a condition that can fail.

| # | Suite file | It name |
|---|---|---|
| 1 | `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | `allows gh pr create --body-file artifacts/pr_body_12.md when context exists` |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `allows every registered handler for every tool name its own matcher admits` |

---

## The six edits, stated once

All six are stated here so no task restates them. Each task below names the block it applies.

### Edit 1 — the new shared predicate

New function in `.claude/hooks/hook-command-scanner.ps1` and `.codex/hooks/hook-command-scanner.ps1`,
inserted between the closing brace of `ConvertTo-CommandLineSegmentRecord` (current line 163) and
`function Read-CommandLineHeredocHeader` (current line 165), separated by one blank line on each
side. Its three disjuncts are set-identical with the scanner's own `ScanText` selection clause at
`hook-command-scanner.ps1` line 151, which is what makes the guard exact rather than approximate.

```powershell
function Test-CommandLineSegmentRawScan {
    <#
    .SYNOPSIS
        Report whether the scanner selected RawText as this segment's ScanText.
    .DESCRIPTION
        The three disjuncts below are the same three clauses ConvertTo-CommandLineSegmentRecord
        applies when it selects ScanText, so a caller that guards a raw-text read with this
        predicate reads raw on exactly the segments the scanner already scans raw, and on no
        others.

        It exists for one fail-open class the token readers cannot close by themselves.
        ConvertTo-CommandLineToken collapses a balanced quoted span into ONE token, so a flag
        carried inside a wrapper's quoted argument never appears as a token and every
        token-based flag read reports it absent. A call site that reads flag absence as OUT OF
        SCOPE therefore allows a command the pre-parser whole-text scan denied. A call site
        that reads flag absence as MISSING AUTHORIZATION is already fail-closed and must not
        use this predicate.
    .PARAMETER Segment
        One segment record produced by Read-CommandLineSegment.
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $Segment)

    if ($null -eq $Segment) {
        return $false
    }

    return ([bool]$Segment.IsWrapperLed -or [bool]$Segment.HasLiveSubstitution -or [bool]$Segment.Unbalanced)
}
```

### Edit 2 — `.claude/hooks/enforce-epic-merge-gate.ps1`, current lines 392–400

Replace the existing four-line comment plus three-line scope filter with the block below. The
`$isMergeInvocation` line, the `$hasMergeFlag` line, and the `if (-not $isMergeInvocation …)` guard
are byte-unchanged; the only additions are the comment continuation and the fallback loop.

```powershell
    # Only a gh pr merge invocation carrying --merge is in scope for this gate; every
    # other Bash command is unaffected. Both legs are read structurally from the segment
    # that invokes the command, so a quoted mention of the phrase and a --merge token
    # belonging to some other segment no longer bring a command into scope.
    #
    # The flag leg needs a raw-scan fallback: a wrapper's quoted argument collapses into ONE
    # token, so a flag inside it is never read as a token, and the token-only read took
    # bash -c "gh pr merge --merge 688" out of scope. The fallback reads only the segments the
    # scanner already scans raw, so a masked mention in a non-wrapper segment stays out.
    $isMergeInvocation = Test-CommandLineInvocation -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
    $hasMergeFlag = Test-CommandLineFlag -CommandText $commandText -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if (-not $hasMergeFlag) {
        foreach ($segment in @(Read-CommandLineSegment -CommandText $commandText)) {
            if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
                $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasMergeFlag = $true
                break
            }
        }
    }
    if (-not $isMergeInvocation -or -not $hasMergeFlag) {
        return Get-EpicMergeGateAllowDecision
    }
```

`Get-EpicMergeGateCommandPrNumber` is **not** changed. It returns `$null` for a wrapper-led segment
because `OperandIndex = -1` yields no operands and the flag value is unreadable; that is already the
fail-closed direction and the parallel branch denies on `$null`.

### Edit 3 — `.codex/hooks/enforce-epic-merge-gate.ps1`, current lines 128–134

The same change, against the Codex idiom. `$command` replaces `$commandText`; the allow return is
`$null`.

```powershell
    # Both legs are read structurally from the segment that invokes the command, so a
    # quoted mention of the phrase no longer brings a command into scope. The flag leg needs
    # a raw-scan fallback: a wrapper's quoted argument collapses into ONE token, so a flag
    # inside it is never read as a token, and the token-only read took
    # bash -c "gh pr merge --merge 688" out of scope.
    $isMergeInvocation = Test-CommandLineInvocation -CommandText $command -CommandWord 'gh' -SubcommandPath @('pr', 'merge')
    $hasMergeFlag = Test-CommandLineFlag -CommandText $command -CommandWord 'gh' -SubcommandPath @('pr', 'merge') -FlagName '--merge'
    if (-not $hasMergeFlag) {
        foreach ($segment in @(Read-CommandLineSegment -CommandText $command)) {
            if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
                $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasMergeFlag = $true
                break
            }
        }
    }
    if (-not $isMergeInvocation -or -not $hasMergeFlag) {
        return $null
    }
```

### Edit 4 — `.claude/hooks/enforce-parallel-abandon-gate.ps1`

Three coordinated changes. **Neither token literal may appear anywhere in the new text.**

**4a.** `Test-ParallelAbandonSegmentDisposition` (current lines 95–138) takes the segment record
instead of its token list. Change the parameter block from
`param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token)` to
`param([Parameter(Mandatory)][AllowNull()] $Segment)`, add `$token = @($Segment.Tokens)` above the
existing loop, rename the loop's `$Token` references to `$token`, and append the raw-scan leg after
the loop, replacing the trailing `return $false`:

```powershell
    if (-not (Test-CommandLineSegmentRawScan -Segment $Segment)) {
        return $false
    }

    # A wrapper's quoted argument is a nested command line and collapses into ONE token, so
    # neither the adjacent pair nor the equals-joined token can form inside it. Both accepted
    # spellings are reconstructed from the split constant rather than restated, so the
    # single-source-of-truth seam test still finds each literal exactly once in this file.
    $scanText = [string]$Segment.ScanText
    $comparison = [System.StringComparison]::OrdinalIgnoreCase
    return ($scanText.IndexOf($joined, $comparison) -ge 0 -or
        $scanText.IndexOf(($optionName + ' ' + $optionValue), $comparison) -ge 0)
```

Extend the function's `.DESCRIPTION` by one sentence naming the raw-scan leg. The function's
comment-based help currently declares `.SYNOPSIS`, `.DESCRIPTION`, and `.OUTPUTS` and carries no
`.PARAMETER` entry at all — re-derived against `.claude/hooks/enforce-parallel-abandon-gate.ps1`
lines 96–113 — so add a `.PARAMETER Segment` entry rather than renaming an existing `.PARAMETER
Token` entry, which does not exist.

**4b.** `Test-ParallelAbandonCommandInScope` line 166: replace
`if (Test-ParallelAbandonSegmentDisposition -Token @($segment.Tokens)) {` with
`if (Test-ParallelAbandonSegmentDisposition -Segment $segment) {`.

**4c.** `Test-ParallelAbandonCommandConfirmed` lines 200–208: replace the loop body with

```powershell
    foreach ($segment in @(Read-CommandLineSegment -CommandText $NormalizedCommand)) {
        $tokens = @($segment.Tokens)
        if (-not (Test-ParallelAbandonSegmentDisposition -Segment $segment)) {
            continue
        }
        if ($tokens -contains $script:AbandonConfirmToken) {
            return $true
        }
        if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
            ([string]$segment.ScanText).IndexOf($script:AbandonConfirmToken, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            return $true
        }
    }
```

The same-segment requirement is preserved: both the disposition and the confirmation marker must be
found in the same segment record, so an acknowledgement echoed in an unrelated segment still does
not confirm.

### Edit 5 — `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, inserted after line 190

```powershell

    # Raw-scan fallback for a wrapper-led, live-substitution, or unbalanced segment. A
    # wrapper's quoted argument collapses into ONE token, so both flags read absent there and
    # the gh pr edit no-body branch below allowed bash -c "gh pr edit 42 --body 'x'". The
    # --body-file test runs first and wins, so a --body-file carried inside a wrapper is never
    # misread as an inline body. That ordering restores the pre-parser routing, in which one
    # whole-text --body-file match set $hasBodyFile for exactly this input.
    if (-not $hasBodyFile -and -not $hasInlineBody) {
        $comparison = [System.StringComparison]::OrdinalIgnoreCase
        foreach ($segment in @(Read-CommandLineSegment -CommandText $CommandText)) {
            if (-not (Test-CommandLineSegmentRawScan -Segment $segment)) {
                continue
            }
            if ($segment.ScanText.IndexOf('--body-file', $comparison) -ge 0) {
                $hasBodyFile = $true
            } elseif ($segment.ScanText.IndexOf('--body', $comparison) -ge 0) {
                $hasInlineBody = $true
            }
        }
    }
```

Nothing else in this file changes. No `PR_*` reason-code string, no receipt-verification logic, no
orchestrator-state preflight, and no `--body-file` path-value extraction is touched; AC-12 pins all
four as unchanged.

**The `--body-file`-before-`--body` ordering is load-bearing and is not a behaviour weakening.** At
the feature-wide anchor the flag reads were `$hasBodyFile = $CommandText -match '(?i)--body-file\b'`
and `$hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'`, both over the whole raw text
(recorded verbatim at
`research/2026-09-06T23-30-command-word-parser-rederivation-research.md` lines 395–396). For
`bash -c "gh pr create --body-file artifacts/pr_body_545.md"` the base therefore set `$hasBodyFile`
and routed to Case C and receipt verification; the current head sets neither flag and routes to
Case B. The fallback restores the base routing exactly. `[P3-T8]` records this derivation so the
reaudit sees it as intentional.

### Edit 6 — `.claude/hooks/validate-bash.ps1`, inserted in `Get-CdChainedReadCommandMatch` after
the existing `$segments = @(Read-CommandLineSegment -CommandText $Command)` at line 274

```powershell

    # D12 call-site row for line 105: the retained pattern, evaluated per segment against
    # ScanText. Complementary to the CommandWord walk below rather than a replacement for it.
    # '&&' and ';' delimit segments, so an unquoted chain never puts both halves in one
    # segment and only the walk can see it; a wrapper-led chain sits entirely inside one
    # segment whose command word is the wrapper, and only this leg can see that. Restricting
    # the leg to segments the scanner already scans raw preserves the intended narrowing:
    # echo "cd /x && head f" is masked and still allows.
    foreach ($segment in $segments) {
        if ((Test-CommandLineSegmentRawScan -Segment $segment) -and
            $segment.ScanText -match $script:CdChainedReadCommandPattern) {
            return ($Matches[2] -replace '\s+', ' ')
        }
    }
```

Group 2 of the pattern is the read-command alternation, so `$Matches[2]` is `grep`, `cat`, `head`,
`tail`, `less`, `more`, `awk`, or a `sed`-plus-`-n` run; the `-replace` normalizes the last of those
to the single-spaced `sed -n` the existing walk and the existing reason-string interpolation both
use. `$script:CdChainedReadCommandPattern` at line 222 stays byte-unchanged, and
`$script:CdChainedReadCommandWords` and the walk below stay as they are. Extend the function's
`.DESCRIPTION` by two sentences naming the new leg and its ordering.

---

### Phase 0 — Baseline capture (cycle 2)

- [x] [P0-T1] Read the repository policy files in the order defined by `policy-compliance-order`:
      `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`,
      `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`, `.claude/rules/powershell.md`,
      `.claude/rules/python.md`. Write
      `evidence/remediation-baseline/phase0-instructions-read.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries `Timestamp:`, a `Policy Order:` section listing the seven
      paths in the order above, `Command:`, `EXIT_CODE: 0`, and `Output Summary:`. Each of the seven
      paths appears in the artifact exactly as written above. A missing path fails this task.

- [x] [P0-T2] Read the four cycle-2 review artifacts and this plan's inputs:
      `remediation-inputs.2026-09-07T20-45.md`, `code-review.2026-09-07T20-45.md`,
      `policy-audit.2026-09-07T20-45.md`, `feature-audit.2026-09-07T20-45.md`, all in the feature
      folder root. Write
      `evidence/remediation-baseline/phase0-remediation-documents-read.<capture-timestamp>.md`.
      **Acceptance:** the artifact lists all four paths, restates the four R-2 instance identifiers
      `R-2.a`, `R-2.b`, `R-2.c`, `R-2.d`, and restates the three prohibitions this cycle carries:
      no change to `Test-CommandLineFlag` or `Get-CommandLineFlagValue`; no F-1 through F-7 fix; no
      attempt to fix the two ambient-state failures. `EXIT_CODE: 0`.

- [x] [P0-T3] Capture the git baseline. Run, in this order:
      `git rev-parse HEAD`;
      `git merge-base --is-ancestor 26dba29533ba70f6cd80d14ac3c87ac24ca82aca HEAD`;
      `git status --porcelain`;
      `git diff --stat 6dff80ed4596bec088d548b23013e6077e32c484 -- .`.
      Write `evidence/remediation-baseline/baseline-git-state.<capture-timestamp>.md`.
      **Acceptance:** the recorded `git rev-parse HEAD` output is the 40-character string
      `459d245f893f3337d61496b2602830e381d1d7a3`, the commit that added this plan, and
      `git merge-base --is-ancestor 26dba29533ba70f6cd80d14ac3c87ac24ca82aca HEAD` exits 0,
      confirming the cycle-scope anchor is reachable. If either check fails, record the observed
      values and stop with `BLOCKED`. The artifact also records the `git status --porcelain` line
      count and the final `N files changed` summary line of the feature-wide `--stat`.
      `EXIT_CODE: 0`.

- [x] [P0-T4] Capture the formatting baseline. Run `mcp__drm-copilot__run_poshqc_format` with
      `workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
      and no `scan_folders` argument, with a `git status --porcelain` capture immediately before and
      immediately after. Write
      `evidence/remediation-baseline/baseline-poshqc-format.<capture-timestamp>.md`.
      This is the first MCP call of the run, so standing constraint 8's worktree confirmation is
      discharged here: run `git rev-parse --show-toplevel` before the formatter and record its
      output.
      **Acceptance:** the recorded `git rev-parse --show-toplevel` output resolves to
      `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`; if it does
      not, record the observed path and stop with `BLOCKED` without issuing the MCP call. The
      artifact records both porcelain captures verbatim and the set-difference
      count of paths present after and absent before, computed with `comm -13` over the two sorted
      captures. That count must be `0`. `EXIT_CODE: 0`. Recording the exit code alone does not
      satisfy this task, because the formatter exits 0 whether or not it rewrote a file.

- [x] [P0-T5] Capture the lint baseline. Run `mcp__drm-copilot__run_poshqc_analyze` with the same
      `workspace_root` and no `scan_folders` argument. Write
      `evidence/remediation-baseline/baseline-poshqc-analyze.<capture-timestamp>.md`.
      **Acceptance:** the artifact records the literal result value `ok: true`. Any other value is a
      baseline that must be reported and not worked around. `EXIT_CODE: 0`.

- [x] [P0-T6] Capture the Claude hook-suite baseline. Run `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders=["tests/scripts/claude-hooks"]` and read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/remediation-baseline/baseline-claude-hooks-pester.<capture-timestamp>.md`.
      **Acceptance:** the artifact records the folder-wide `tests`, `failures`, `errors`, and
      `skipped` totals, and a per-suite row for each of the five suites this cycle will edit or
      depend on: `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`,
      `enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`,
      `enforce-pr-author-skill.TriggerScoping.Tests.ps1`, `validate-bash.TriggerScoping.Tests.ps1`,
      `hook-command-scanner.Tests.ps1`. Every one of those five rows must record `failures` 0 and
      `errors` 0. The artifact names each folder-wide failure by suite and `It` name; every such
      name must be row 1 of the tolerated-failures table. `ExpectedExitCode: 1`, and the observed
      `EXIT_CODE:` is recorded as the folder-wide failed-test count.

- [x] [P0-T7] Capture the Codex hook-suite baseline. Run `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders=["tests/scripts/codex-hooks"]`. Write
      `evidence/remediation-baseline/baseline-codex-hooks-pester.<capture-timestamp>.md`.
      **Acceptance:** as `[P0-T6]`, with per-suite rows for
      `enforce-epic-merge-gate-trigger-scoping.Tests.ps1`, `hook-command-scanner.Tests.ps1`,
      `legacy-codex-hook-contracts.Tests.ps1`, and `enforce-epic-merge-gate-decision-surface.Tests.ps1`,
      each recording `failures` 0 and `errors` 0. Every folder-wide failure named must be row 2 of
      the tolerated-failures table. `ExpectedExitCode: 1`.

- [x] [P0-T8] Capture the Python contract baseline. Run
      `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -p no:cacheprovider --no-header -q`.
      Write `evidence/remediation-baseline/baseline-python-contracts.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` and the recorded summary line reports `22 passed`. No Python
      production source file is edited by this cycle, so no Python coverage figure is required and
      none is recorded; the artifact states that in one sentence. The seam module's own count is
      recorded separately as `10 passed`, taken from a second run of
      `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q`,
      because that number is the one `[P3-T10]` compares against.

- [x] [P0-T9] Record the per-file PowerShell coverage baseline. Transcribe the seven
      orchestrator-supplied figures from CI run `34158596238` of `.github/workflows/_poshqc.yml` at
      commit `3b4f10b9` that correspond to files this cycle edits:
      `.claude/hooks/validate-bash.ps1` = **94.4444**;
      `.claude/hooks/enforce-epic-merge-gate.ps1` = **96.6102**;
      `.codex/hooks/enforce-epic-merge-gate.ps1` = **98.5075**;
      `.claude/hooks/enforce-pr-author-skill-helpers.ps1` = **95.5224**;
      `.claude/hooks/enforce-parallel-abandon-gate.ps1` = **92.7536**;
      `.claude/hooks/hook-command-scanner.ps1` = **97.7778** (missed 4, covered 176, total 180);
      `.codex/hooks/hook-command-scanner.ps1` = **100.0000** (missed 0, covered 180, total 180).
      All seven are reported by run `34158596238`, so all seven are numeric and none is substituted.
      The two scanner figures were derived from the `poshqc-test-results` artifact of that run by
      summing the JaCoCo `LINE` counters per `<sourcefile>` in `powershell-coverage.xml`, the same
      method that reproduces the other five figures exactly; both scanner paths are present in the
      coverage list at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` at lines 253 and
      255. Write
      `evidence/remediation-baseline/baseline-per-file-coverage.<capture-timestamp>.md`.
      **Acceptance:** the artifact records all seven figures as numeric percentages, never a
      placeholder and never a `BASELINE_NOT_REPORTED` marker;
      records the run id `34158596238`, the commit `3b4f10b9`, and the workflow path
      `.github/workflows/_poshqc.yml`; states explicitly that `.codex/hooks/validate-bash.ps1` is
      **not** carried because this cycle does not edit it; and carries a `TOOLCHAIN_SUBSTITUTION`
      note recording that the MCP test runner was deliberately not used for any coverage figure
      because it resolves runsettings from the installed VS Code extension and cannot see this
      branch's `CodeCoverage.Path` entries. `EXIT_CODE: 0` for the transcription.

- [x] [P0-T10] Record the pre-edit body of the six fail-closed-correct flag call sites named in the
      Scope section, so `[P5-T3]` has something to compare against. For each of the six, capture the
      enclosing function's full body with `sed -n '<start>,<end>p' <file>`. Write
      `evidence/remediation-baseline/baseline-failclosed-call-sites.<capture-timestamp>.md`.
      **Acceptance:** the artifact reproduces all six function bodies, one section each, and states
      for each in one sentence why flag absence is fail-closed there. The six file paths and line
      numbers must match the Scope table exactly. `EXIT_CODE: 0`.

- [x] [P0-T11] Record the pre-edit line-count inventory. Run
      `wc -l .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-parallel-abandon-gate.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/validate-bash.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
      Write `evidence/remediation-baseline/baseline-line-counts.<capture-timestamp>.md`.
      **Acceptance:** the artifact records all eight counts. The seven counts for the files this
      cycle edits must equal the values in standing constraint 4, and
      `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` must read `500`. A divergence
      means the tree is not the tree this plan was authored against: record it and stop with
      `BLOCKED`. `EXIT_CODE: 0`.

### Phase 1 — Batch A: the shared raw-scan predicate

- [x] [P1-T1] Open batch A. First run `ls -1 .claude/state/` and record the listing. Record every
      `powershell-batch-budget.*.json` name observed and, for each, its contents. Then delete every
      `powershell-batch-budget.*.json` present with `rm -f`, and run `ls -1 .claude/state/` again.
      Write `evidence/qa-gates/batch-a-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** the artifact records the pre-reset listing, every observed
      `powershell-batch-budget.*.json` name with its contents, the deletion command,
      `EXIT_CODE: 0`, and the post-reset listing.
      The post-reset listing must contain no file whose name begins `powershell-batch-budget.`. A
      bare exit code does not satisfy this task, because `rm -f` on an absent path also exits 0. An
      empty pre-reset listing is a valid observation and is recorded as such; `.claude/state/` holds
      no budget file at the time this plan was authored.

- [x] [P1-T2] `[expect-fail]` Add the predicate's own unit cases to
      `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` and
      `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`, in a new
      `Context 'R-2 raw-scan predicate'`. In
      `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1` place it immediately before the
      existing `Context 'D12 public parser contract'` at line 322.
      `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1` carries no such Context — its final
      Context is `Context 'wrapper carve-out set'` at line 310 — so in that file append the new
      Context after `Context 'wrapper carve-out set'`. Both files carry the `Get-SegmentList` helper
      at line 30, which every case uses. Add exactly these five `It` names to each file, with
      identical fixtures, and give the Context a leading comment stating that every case drives a
      pure predicate over a literal fixture with no disk I/O, no child process, no temporary file,
      and no ambient state:

      | It name | Fixture | Expected |
      |---|---|---|
      | `R2-P1 reports true for a wrapper-led segment` | `bash -c "gh pr merge --merge 688"` | `$true` |
      | `R2-P2 reports true for a segment carrying a live substitution` | `echo "$(gh pr merge --merge 688)"` | `$true` |
      | `R2-P3 reports true for an unbalanced segment` | `echo "gh pr merge --merge 688` | `$true` |
      | `R2-P4 reports false for a masked quoted mention in a non-wrapper segment` | `git commit -m "gh pr merge --merge 688"` | `$false` |
      | `R2-P5 reports false for a null segment` | `$null` | `$false` |

      Each case resolves its segment through the suite's existing segment-list helper and asserts
      `Test-CommandLineSegmentRawScan -Segment <segment>`; `R2-P5` passes `-Segment $null` directly.
      **Acceptance:** `grep -F -c 'R2-P1 reports true for a wrapper-led segment'` returns `1` in each
      of the two suite files, and the same holds for each of the other four `It` names, which this
      plan quotes verbatim above as the text the executor must create. `wc -l` on each suite file is
      at or under 500.

- [x] [P1-T3] `[expect-fail]` Record the fail-before state of the ten new cases. Run
      `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]` and read
      `artifacts/pester/pester-junit.xml`. Write
      `evidence/regression-testing/fail-before-r2-predicate.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a ten-row table, one row per new `It` name per side, each
      row recording a `status` other than `passed`. Ten non-passing rows is the required count; nine
      fails this task. The artifact carries a `TOOLCHAIN_SUBSTITUTION` note naming the MCP route and
      the JUnit read-out, and `ExpectedExitCode:` set to the folder-wide failed-test count the
      artifact records. It also records the per-suite `failures` count for
      `hook-command-scanner.Tests.ps1` on each side, which must be exactly 5 higher than the
      `[P0-T6]` and `[P0-T7]` baselines for those suites.

- [x] [P1-T4] Apply Edit 1 to `.claude/hooks/hook-command-scanner.ps1`.
      **Acceptance:** `grep -F -c 'function Test-CommandLineSegmentRawScan {'` returns `1`;
      `grep -n 'IsWrapperLed -or' .claude/hooks/hook-command-scanner.ps1` returns exactly one line,
      the new predicate's return line. It returns nothing before this edit: the selection clause at
      line 151 spells the flag `$isWrapperLed` in lowercase and places it last, so it never matches
      this pattern. `grep -F -c 'IsWrapperLed'` rises from 3 to 4;
      `wc -l .claude/hooks/hook-command-scanner.ps1` is at or
      under 500 and the observed value is recorded in `[P1-T8]`.
      `git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/hook-command-scanner.ps1`
      produces exactly one hunk, and that hunk contains no `-` line, so nothing existing was removed
      or altered.

- [x] [P1-T5] Apply Edit 1 to `.codex/hooks/hook-command-scanner.ps1`, byte-identically to the
      Claude copy.
      **Acceptance:** the same three checks as `[P1-T4]` against the Codex path — the two files are
      byte-identical today, so the Codex copy's selection clause at line 151 also spells the flag
      `$isWrapperLed` in lowercase and also places it last, and `grep -F -c 'IsWrapperLed'` there
      likewise rises from 3 to 4 — plus
      `cmp -s .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1` exits 0,
      which is the property the two files already hold at 450 lines each and must continue to hold.

- [x] [P1-T6] Mirror both scanner copies into the bundles and verify parity:
      `cp .claude/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1`
      and
      `cp .codex/hooks/hook-command-scanner.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`.
      Write `evidence/qa-gates/batch-a-parity.<capture-timestamp>.md`.
      **Acceptance:** both `cmp -s` comparisons of canonical against mirror exit 0, and the artifact
      records the `sha256sum` of all four files, with the Claude pair equal to each other and the
      Codex pair equal to each other. `EXIT_CODE: 0`.

- [x] [P1-T7] Record the pass-after state of the ten cases. Re-run the `[P1-T3]` command and write
      `evidence/regression-testing/pass-after-r2-predicate.<capture-timestamp>.md`.
      **Acceptance:** the same ten-row table now records `status` `passed` on every row. The
      per-suite `failures` and `errors` counts for `hook-command-scanner.Tests.ps1` are 0 on both
      sides, and each side's `tests` count is exactly 5 higher than its `[P0-T6]` / `[P0-T7]`
      baseline. Both folder-wide failure lists contain only the two tolerated names.

- [x] [P1-T8] Run the batch-A toolchain gate: format, then analyze, then the two hook-test folders,
      in that order, restarting from format if any stage fails or rewrites a file. Write
      `evidence/qa-gates/batch-a-toolchain.<capture-timestamp>.md`.
      **Acceptance:** the artifact records, per stage, the exact command and `EXIT_CODE:`. For
      format it records the `git status --porcelain` captures before and after with a set-difference
      count of `0`, and the `sha256sum` of the four scanner copies before and after, unchanged. For
      analyze it records `ok: true`. For test it records per-suite counts and states that the only
      folder-wide failures are the two tolerated names. It records `wc -l` for all four scanner
      copies, each at or under 500. `Output Summary:` states whether a restart from stage 1 was
      required and, if so, how many.

- [x] [P1-T9] Close batch A with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-a-close-reset.<capture-timestamp>.md`.
      **Acceptance:** the artifact records the contents of every `powershell-batch-budget.*.json`
      observed before the reset, and each such file shows at most 2 entries in `prodFiles` and at
      most 2 in `testFiles`; the deletion command with `EXIT_CODE: 0`; and a post-reset listing of
      `.claude/state/` containing no `powershell-batch-budget.` file. Batch A wrote two production
      and two test PowerShell files through the PreToolUse hook, so exactly one budget file is
      expected here; if the pre-reset listing is empty, record that observation and the reason it
      diverges from the expectation rather than treating the task as vacuously satisfied.

### Phase 2 — Batch B: R-2.a, the merge-gate scope filter on both runtimes

- [x] [P2-T1] Open batch B with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-b-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T1]`.

- [x] [P2-T2] `[expect-fail]` Add the Claude decision-surface cases to
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` in a new
      `Context 'R-2.a wrapper-led segments stay in scope'` appended after the existing final
      Context. Every case mocks all three checkpoint read seams
      (`Get-ChildOrchestratorCheckpointContent`, `Get-EpicOrchestratorCheckpointContent`,
      `Get-ParallelOrchestratorCheckpointContent`) to return `$null`, exactly as the existing cases
      at lines 66–68 do, so an in-scope command necessarily denies and the assertion turns on the
      scope filter alone. Add exactly these three `It` names:

      | It name | Command fixture | Expected decision |
      |---|---|---|
      | `R2a-C1 denies a gh pr merge --merge carried inside a bash -c argument` | `bash -c "gh pr merge --merge 688"` | `deny`, reason matches `EPIC_MERGE_GATE_BLOCKED` |
      | `R2a-N1 still allows a commit message quoting the merge phrase and the merge flag` | `git commit -m "gh pr merge --merge 688"` | `allow` |
      | `R2a-N2 keeps a gh pr merge --merge relocated through xargs in scope` | `echo 688 \| xargs gh pr merge --merge` | `deny`, reason matches `EPIC_MERGE_GATE_BLOCKED` |

      `R2a-N2` is a preservation pin, not a regression case. `|` is a segment delimiter
      (`.claude/hooks/hook-command-scanner.ps1` line 31), so the second segment of that fixture is
      `xargs gh pr merge --merge`.
      `xargs` is in `$script:CommandLineWrapperNames` (lines 21–24), so the segment is
      wrapper-led and `Resolve-CommandLineInvocation` already matches it by raw containment
      (`.claude/hooks/hook-command-invocation.ps1` lines 202–205). Nothing in the segment is quoted,
      so `--merge` is already a plain token and `Test-CommandLineFlag`'s token loop (lines 449–452)
      already returns true. The command therefore already denies today, and this case pins that it
      keeps denying.

      Give the Context a leading comment stating that every case drives the pure decision seam with
      all three checkpoint seams mocked, so no case reads live orchestration state.
      **Acceptance:** `grep -F -c` on each of the three `It` names, quoted verbatim above, returns
      `1` in that file. `wc -l` on the file is at or under 500.

- [x] [P2-T3] `[expect-fail]` Add the Codex decision-surface cases to
      `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` in a new
      `Context 'R-2.a wrapper-led segments stay in scope'`. The Codex seam takes both checkpoint
      texts as parameters and returns `$null` for allow, as the existing cases at lines 74 and 80
      do. Add exactly these two `It` names:

      | It name | Command fixture | Expected |
      |---|---|---|
      | `R2a-X1 denies a gh pr merge --merge carried inside a bash -c argument` | `bash -c "gh pr merge --merge 688"` | non-null decision, `permissionDecision` `deny`, reason matches `EPIC_MERGE_GATE_BLOCKED` |
      | `R2a-X2 still allows a commit message quoting the merge phrase and the merge flag` | `git commit -m "gh pr merge --merge 688"` | `$null` |

      **Acceptance:** `grep -F -c` on each of the two `It` names returns `1` in that file. `wc -l` is
      at or under 500.

- [x] [P2-T4] `[expect-fail]` Record the pre-change state of the five new merge-gate cases, two of
      which are expected to fail and three of which are expected to pass. Run
      `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]` and write
      `evidence/regression-testing/fail-before-r2a-merge-gate.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a five-row table. `R2a-C1` and `R2a-X1` record a `status`
      other than `passed`; `R2a-N1`, `R2a-N2`, and `R2a-X2` record `passed`, because each pins
      behaviour that is already correct — `R2a-N2` in particular, because an unquoted `xargs`
      segment already exposes `--merge` as a token and is already in scope. Two non-passing and
      three passing is the required split; any other split fails this task and must be reported
      rather than adjusted. `ExpectedExitCode:` is set to the folder-wide failed-test count
      recorded.

- [x] [P2-T5] Apply Edit 2 to `.claude/hooks/enforce-epic-merge-gate.ps1`.
      **Acceptance:** `grep -F -c 'Test-CommandLineSegmentRawScan' .claude/hooks/enforce-epic-merge-gate.ps1`
      returns `1`. `sed -n '160,180p' .claude/hooks/enforce-epic-merge-gate.ps1` reproduces
      `Get-EpicMergeGateCommandPrNumber`'s operand loop and its
      `Get-CommandLineFlagValue … -FlagName '--merge'` line unchanged, which is fail-closed-correct
      site 5. `wc -l` is at or under 500 and the observed value is recorded in `[P2-T9]`.

- [x] [P2-T6] Apply Edit 3 to `.codex/hooks/enforce-epic-merge-gate.ps1`.
      **Acceptance:** `grep -F -c 'Test-CommandLineSegmentRawScan' .codex/hooks/enforce-epic-merge-gate.ps1`
      returns `1`. `sed -n '50,70p' .codex/hooks/enforce-epic-merge-gate.ps1` reproduces
      `Get-CodexMergeCommandPrNumber`'s `Get-CommandLineFlagValue … -FlagName '--merge'` line
      unchanged, which is fail-closed-correct site 6. `wc -l` is at or under 500.

- [x] [P2-T7] Mirror both merge-gate copies and verify parity:
      `cp .claude/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
      and
      `cp .codex/hooks/enforce-epic-merge-gate.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`.
      Write `evidence/qa-gates/batch-b-parity.<capture-timestamp>.md`.
      **Acceptance:** both `cmp -s` comparisons exit 0 and the artifact records the `sha256sum` of
      all four files, each canonical equal to its mirror.

- [x] [P2-T8] Record the pass-after state. Re-run the `[P2-T4]` command and write
      `evidence/regression-testing/pass-after-r2a-merge-gate.<capture-timestamp>.md`.
      **Acceptance:** all five rows now record `passed`. The artifact additionally records `passed`
      for the four pre-existing `It` names in the Claude suite's `PR-number extraction comes from
      the matched segment only` Context, for the existing
      `allows a printf whose double-quoted text mentions the gated merge phrase`, and for the
      existing Codex `allows a quoted mention of the gated merge phrase` and for the three
      pre-existing `It` names in the Claude suite's
      `Context 'the false-allow direction of the whole-line PR-number defect'` —
      `takes the PR number from the merge operand 777, not from the authorized item number 501 in
      the cd path`, `denies merging unauthorized PR 777 even though authorized item 501 appears
      earlier on the line`, and
      `still allows merging the authorized PR 501 when 501 is the merge operand`. The second of
      these is the case execution amendment EA-2 makes binding on this feature; a non-passing row on
      it blocks this phase. Those preservation
      rows are the AT-4 paired negative the reaudit requires; a non-passing row on any of them means
      an existing allow was turned into a deny and blocks this phase. Per-suite `failures` and
      `errors` are 0 for both edited suites and for `enforce-epic-merge-gate.Tests.ps1` and
      `enforce-epic-merge-gate-decision-surface.Tests.ps1`.

- [x] [P2-T9] Run the batch-B toolchain gate with the `[P1-T8]` procedure and acceptance, over the
      four merge-gate copies and the two edited suites. Write
      `evidence/qa-gates/batch-b-toolchain.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T8]`, with the `wc -l` inventory covering the four merge-gate copies
      and the two suites, each at or under 500, and with the format-stage `sha256sum` set covering
      the four merge-gate copies.

- [x] [P2-T10] Close batch B with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-b-close-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T9]`.

### Phase 3 — Batch C: R-2.b and R-2.c

- [x] [P3-T1] Open batch C with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-c-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T1]`.

- [x] [P3-T2] `[expect-fail]` Add the abandon-gate decision-surface cases to
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` in a new
      `Context 'R-2.b wrapper-led disposition'` appended after the existing final `It`. Every case
      drives `Invoke-ParallelAbandonGateDecision` through the file's existing
      `ConvertTo-AbandonGateEnvelope` helper with a literal fixture. Add exactly these four `It`
      names:

      | It name | Command fixture | Expected decision |
      |---|---|---|
      | `R2b-C1 denies the space-separated disposition carried inside a bash -c argument` | `bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon"` | `deny`, reason matches `PARALLEL_ABANDON_BLOCKED` |
      | `R2b-C2 denies the equals-joined disposition carried inside a bash -c argument` | `bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition=abandon"` | `deny`, reason matches `PARALLEL_ABANDON_BLOCKED` |
      | `R2b-C3 allows a wrapper-led abandon carrying the confirmation marker in the same segment` | `bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon --confirm-abandon"` | `allow` |
      | `R2b-N1 still allows a commit message quoting the disposition token` | `git commit -m "note that --disposition abandon is gated"` | `allow` |

      **Acceptance:** `grep -F -c` on each of the four `It` names, quoted verbatim above, returns `1`
      in that file. `wc -l` is at or under 500. This constraint applies to the hook file and not to
      this suite: the token literals may appear in test fixtures, and two already do at the suite's
      existing lines 48 and 64.

- [x] [P3-T3] `[expect-fail]` Add the pr-author decision-surface cases to
      `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` in a new
      `Context 'R-2.c wrapper-led body flags'` appended after the existing final Context. Every case
      drives `Invoke-PrAuthorSkillDecision` through the file's existing `ConvertTo-CommandEnvelope`
      helper and mocks `Get-PrContextArtifactExistence`, as the existing Contexts do. Add exactly
      these four `It` names:

      | It name | Command fixture | Context mock | Expected |
      |---|---|---|---|
      | `R2c-C1 denies a gh pr edit inline body carried inside a bash -c argument` | `bash -c "gh pr edit 42 --body 'x'"` | `$true` | `deny`, reason matches `PR_AUTHOR_SKILL_BLOCKED` |
      | `R2c-C2 routes a wrapper-led --body-file to the context check rather than the inline-body case` | `bash -c "gh pr edit 42 --body-file artifacts/pr_body_545.md"` | `$false` | `deny`, reason matches `PR_CONTEXT_MISSING` and does not match `PR_AUTHOR_SKILL_BLOCKED` |
      | `R2c-N1 still routes a non-wrapper --body-file edit to the context check` | `gh pr edit 42 --body-file artifacts/pr_body_545.md` | `$false` | `deny`, reason matches `PR_CONTEXT_MISSING` and does not match `PR_AUTHOR_SKILL_BLOCKED` |
      | `R2c-N2 still allows a quoted --body mention inside a JSON receipt value` | `echo '{"cmd":"gh pr edit 42 --body x"}' > artifacts/receipt.json` | `$false` | `allow` |

      **Acceptance:** `grep -F -c` on each of the four `It` names returns `1` in that file. `wc -l`
      is at or under 500.

- [x] [P3-T4] `[expect-fail]` Record the fail-before state of the eight new cases. Run
      `mcp__drm-copilot__run_poshqc_test` with `scan_folders=["tests/scripts/claude-hooks"]` and
      write `evidence/regression-testing/fail-before-r2bc.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries an eight-row table. `R2b-C1`, `R2b-C2`, `R2c-C1`, and
      `R2c-C2` record a `status` other than `passed`. `R2b-C3`, `R2b-N1`, `R2c-N1`, and `R2c-N2`
      record `passed`, because each pins behaviour that is already correct. Four non-passing and four
      passing is the required split; any other split fails this task and must be reported rather than
      adjusted. `ExpectedExitCode:` is set to the folder-wide failed-test count recorded.

- [x] [P3-T5] Apply Edit 4 (all three parts) to `.claude/hooks/enforce-parallel-abandon-gate.ps1`.
      **Acceptance, five conditions, all of which must hold.**
      (1) `grep -F -c 'Test-CommandLineSegmentRawScan' .claude/hooks/enforce-parallel-abandon-gate.ps1`
      returns `2`, one occurrence in `Test-ParallelAbandonSegmentDisposition` and one in
      `Test-ParallelAbandonCommandConfirmed`.
      (2) `grep -c -- '--disposition abandon' .claude/hooks/enforce-parallel-abandon-gate.ps1`
      returns `1` and `grep -c -- '--confirm-abandon' .claude/hooks/enforce-parallel-abandon-gate.ps1`
      returns `1`. These two are the seam-test invariant and a comment mentioning either literal
      breaks them.
      (3) `sed -n '41,42p' .claude/hooks/enforce-parallel-abandon-gate.ps1` reproduces the two token
      assignments at those exact line numbers, byte-unchanged.
      (4) `grep -c -e ' -Token ' .claude/hooks/enforce-parallel-abandon-gate.ps1` returns `0`,
      confirming both call sites were converted to the `-Segment` form: line 166 currently reads
      `-Token @($segment.Tokens)` and line 202 currently reads `-Token $tokens`, so a pattern
      matching only the first would not detect a half-converted file. The `-e` form is required
      because a pattern beginning with `-` is otherwise parsed as an option bundle and grep exits 2.
      (5) The `.DESCRIPTION` sentence added by Edit 4a describes the raw-scan leg without naming
      `Test-CommandLineSegmentRawScan`, so condition (1)'s count of `2` covers the two executable
      references only.
      `wc -l` is at or under 500.

- [x] [P3-T6] Apply Edit 5 to `.claude/hooks/enforce-pr-author-skill-helpers.ps1`.
      **Acceptance:** `grep -F -c 'Test-CommandLineSegmentRawScan' .claude/hooks/enforce-pr-author-skill-helpers.ps1`
      returns `1`.
      `git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/enforce-pr-author-skill-helpers.ps1`
      contains no `-` line other than the blank-line or context adjustments the insertion requires,
      and in particular contains no `-` line matching `PR_`, `Test-PrAuthorReceiptVerification`,
      `Invoke-OrchestratorStatePreflight`, or `--body-file\s+artifacts`. `wc -l` is at or under 500.

- [x] [P3-T7] Mirror both files and verify parity:
      `cp .claude/hooks/enforce-parallel-abandon-gate.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`
      and
      `cp .claude/hooks/enforce-pr-author-skill-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`.
      Write `evidence/qa-gates/batch-c-parity.<capture-timestamp>.md`.
      **Acceptance:** both `cmp -s` comparisons exit 0 and the artifact records the `sha256sum` of
      all four files, each canonical equal to its mirror.

- [x] [P3-T8] Record the `--body-file` routing derivation, so the reaudit sees the R-2.c ordering as
      an intentional restoration rather than a silent behaviour change. Write
      `evidence/regression-testing/r2c-body-file-precedence.<capture-timestamp>.md`.
      **Acceptance:** the artifact reproduces the base-commit flag reads
      `$hasBodyFile = $CommandText -match '(?i)--body-file\b'` and
      `$hasInlineBody = $CommandText -match '(?i)--body(?!-file)\b'` together with their in-tree
      source, `research/2026-09-06T23-30-command-word-parser-rederivation-research.md` lines
      395–396; states in one paragraph that for `bash -c "gh pr create --body-file artifacts/pr_body_545.md"`
      the base set `$hasBodyFile` and routed to Case C and receipt verification while the cycle-scope
      head sets neither flag and routes to Case B; and states that the `--body-file`-first ordering
      in Edit 5 restores the base routing and therefore weakens no denial that existed at the
      feature-wide anchor. It cites `R2c-C2` and `R2c-N1` as the two cases that pin the ordering.
      `EXIT_CODE: 0` for the derivation.

- [x] [P3-T9] Record the pass-after state. Re-run the `[P3-T4]` command and write
      `evidence/regression-testing/pass-after-r2bc.<capture-timestamp>.md`.
      **Acceptance:** all eight rows now record `passed`. The artifact additionally records `passed`
      for the three pre-existing `It` names in the abandon suite (`AT-11 takes a grep whose quoted
      search term is the disposition token out of scope`, `AT-12 brings the equals-joined spelling of
      the disposition option into scope`, and `does not accept a confirmation marker that sits in a
      different segment from the disposition token`) and for all eighteen pre-existing `It` names in
      the pr-author trigger-scoping suite, including the seven wrapper deny pins, the seven `PR_*`
      reason-code cases, and `allows a quoted
      --body-file mention inside a JSON receipt value`. A non-passing row on any of those twenty-one
      blocks this phase. Per-suite `failures` and `errors` are 0 for both edited suites and for
      `enforce-parallel-abandon-gate.Tests.ps1`, `enforce-pr-author-skill.epic-base-branch.Tests.ps1`,
      and `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`. The only folder-wide
      failure is tolerated row 1.

- [x] [P3-T10] Run the batch-C toolchain gate with the `[P1-T8]` procedure and acceptance, over the
      four edited copies and the two edited suites. Additionally re-run
      `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py -p no:cacheprovider --no-header -q`
      as a fourth stage. Write `evidence/qa-gates/batch-c-toolchain.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T8]`, plus the seam module records `EXIT_CODE: 0` and a summary line
      reporting `10 passed`, equal to the `[P0-T8]` figure. A lower number means the token-count
      invariant was broken by the edit and blocks this phase.

- [x] [P3-T11] Close batch C with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-c-close-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T9]`.

### Phase 4 — Batch D: R-2.d, the `cd`-chained read rule

- [x] [P4-T1] Open batch D with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-d-budget-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T1]`.

- [x] [P4-T2] `[expect-fail]` Add the `cd`-chain cases to
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` in a new
      `Context 'R-2.d wrapper-led cd-chain'` appended after the existing final Context. Every case
      calls the pure function `Get-CdChainedReadCommandMatch` with a literal fixture; give the
      Context a leading comment saying so. Add exactly these four `It` names:

      | It name | Command fixture | Expected return |
      |---|---|---|
      | `R2d-C1 returns head for a cd-chained read inside a bash -c argument` | `bash -c "cd /x && head f"` | `head` |
      | `R2d-C2 returns grep for a semicolon-chained read inside an sh -c argument` | `sh -c "cd /x; grep foo bar"` | `grep` |
      | `R2d-C3 returns cat for a cd-chained read inside a pwsh -Command argument` | `pwsh -NoProfile -Command "cd /x && cat f"` | `cat` |
      | `R2d-N1 still returns null for an echo whose quoted text contains a cd-then-read phrase` | `echo "cd /x && head f"` | `$null` |

      **Acceptance:** `grep -F -c` on each of the four `It` names, quoted verbatim above, returns `1`
      in that file. `wc -l` is at or under 500.

- [x] [P4-T3] `[expect-fail]` Record the fail-before state. Run `mcp__drm-copilot__run_poshqc_test`
      with `scan_folders=["tests/scripts/claude-hooks"]` and write
      `evidence/regression-testing/fail-before-r2d.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a four-row table. `R2d-C1`, `R2d-C2`, and `R2d-C3` record
      a `status` other than `passed`; `R2d-N1` records `passed`. Three non-passing and one passing is
      the required split. `ExpectedExitCode:` is set to the folder-wide failed-test count recorded.

- [x] [P4-T4] Apply Edit 6 to `.claude/hooks/validate-bash.ps1`.
      **Acceptance, four conditions.**
      (1) `grep -F -c 'Test-CommandLineSegmentRawScan' .claude/hooks/validate-bash.ps1` returns `1`.
      (2) `grep -F -c 'CdChainedReadCommandPattern' .claude/hooks/validate-bash.ps1` returns `2`:
      the declaration at line 222 and the new `-match` operand. Before this edit it returned `1`,
      which is the orphaned-constant state code review recorded as C-3.
      (3) `sed -n '222p' .claude/hooks/validate-bash.ps1` reproduces the pattern assignment line
      byte-unchanged.
      (4) `grep -F -c "\$script:CdChainedReadCommandWords -notcontains" .claude/hooks/validate-bash.ps1`
      returns `1`, confirming the `CommandWord` walk was kept alongside the new leg rather than
      replaced by it.
      `wc -l` is at or under 500.

- [x] [P4-T5] Mirror and verify parity:
      `cp .claude/hooks/validate-bash.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`.
      Confirm that `.codex/hooks/validate-bash.ps1` was not modified. Write
      `evidence/qa-gates/batch-d-parity.<capture-timestamp>.md`.
      **Acceptance:** `cmp -s` of the Claude canonical against its mirror exits 0; the artifact
      records the `sha256sum` of both, equal. It also records
      `git diff --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`,
      whose output must be empty, and
      `git status --porcelain .codex/hooks/validate-bash.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/validate-bash.ps1`,
      whose output must also be empty. Both spans are required: the anchored diff is blind to an
      untracked path and porcelain status goes empty once a change is committed.

- [x] [P4-T6] Record the pass-after state. Re-run the `[P4-T3]` command and write
      `evidence/regression-testing/pass-after-r2d.<capture-timestamp>.md`.
      **Acceptance:** all four rows now record `passed`. The artifact additionally records `passed`
      for the eight `cd`-chain cases in `tests/scripts/claude-hooks/validate-bash.Tests.ps1`
      Context `Get-CdChainedReadCommandMatch detects cd-chained read commands`, naming each of the
      eight command fixtures (`cd /tmp/x && grep -n test file.txt`, `cd /tmp/x && cat file.txt`,
      `cd /tmp/x; tail -f log.txt`, `cd /tmp/x && head -20 file.txt`, `cd /tmp/x && less file.txt`,
      `cd /tmp/x && more file.txt`, `cd /tmp/x && awk "{print}" file.txt`, and
      `cd /tmp/x && sed -n 1,5p file.txt`), and for the two pre-existing `cd`-chain cases in the
      trigger-scoping suite (`allows a commit message whose quoted text contains a cd-then-read
      phrase` and `still denies a read command that is not adjacent to the cd segment`). A
      non-passing row on any of those ten blocks this phase. Per-suite `failures` and `errors` are 0
      for `validate-bash.Tests.ps1` and `validate-bash.TriggerScoping.Tests.ps1`.

- [x] [P4-T7] Run the batch-D toolchain gate with the `[P1-T8]` procedure and acceptance, over the
      two `validate-bash.ps1` Claude copies and the one edited suite. Write
      `evidence/qa-gates/batch-d-toolchain.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T8]`.

- [x] [P4-T8] Close batch D with a budget reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/batch-d-close-reset.<capture-timestamp>.md`.
      **Acceptance:** as `[P1-T9]`.

### Phase 5 — Final QA loop, coverage, and closure

- [x] [P5-T1] Run the full final QA loop in order — format, lint, test — restarting from format if
      any stage fails or rewrites a file, and continuing until all three complete in a single pass.
      Stage 1: `mcp__drm-copilot__run_poshqc_format` with
      `workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ae0df3e53c9c9883f`
      and no `scan_folders`,
      with `git status --porcelain` captured before and after and the `sha256sum` of
      all twenty-one touched PowerShell files — the seven canonical production files of standing
      constraint 4, their seven bundle mirrors, and the seven test suites edited by `[P1-T2]`,
      `[P2-T2]`, `[P2-T3]`, `[P3-T2]`, `[P3-T3]`, and `[P4-T2]` — captured before and after.
      Stage 2: `mcp__drm-copilot__run_poshqc_analyze` with the same arguments. Stage 3:
      `mcp__drm-copilot__run_poshqc_test` with
      `scan_folders=["tests/scripts/claude-hooks","tests/scripts/codex-hooks"]`. Write
      `evidence/qa-gates/final-qa-loop.<capture-timestamp>.md`.
      **Acceptance:** stage 1 records both porcelain captures and a set-difference count of `0`,
      and every one of the twenty-one `sha256sum` values is identical before and after; stage 2
      records `ok: true`; stage 3 records per-suite `failures` and `errors` of 0 for each of these
      fourteen suites, named here so the evidence set is fixed rather than chosen at run time:
      `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`,
      `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`,
      `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`,
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`,
      `tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1`,
      `tests/scripts/claude-hooks/validate-bash.Tests.ps1`, and
      `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`. Stage 3 also names every
      folder-wide failure, each of which must be one of
      the two tolerated rows. `Output Summary:` states the number of restarts from stage 1, which
      may be zero.

- [x] [P5-T2] Re-run the three Python contract modules:
      `poetry run pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -p no:cacheprovider --no-header -q`.
      Write `evidence/qa-gates/final-python-contracts.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0` and the recorded summary line reports `22 passed`, equal to the
      `[P0-T8]` baseline. The artifact states in one sentence that no Python production source file
      was edited by this cycle, so no Python coverage figure is required.

- [x] [P5-T3] Re-verify that all six fail-closed-correct call sites are byte-unchanged. For each of
      the six, run `git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- <file>` and confirm no `+`
      or `-` line falls inside the enclosing function recorded by `[P0-T10]`. Write
      `evidence/qa-gates/failclosed-call-sites-unchanged.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a six-row table, one row per call site, each recording
      the file, the enclosing function, the hunk boundaries produced by the anchored diff, and the
      determination that the function body lies outside every hunk. For the three files this cycle
      does not edit — `enforce-epic-worktree-removal-gate.ps1` on both runtimes,
      `enforce-parallel-worktree-removal-gate.ps1`, and `enforce-pr-author-skill.epic-base-branch.ps1`
      — the anchored diff must produce no output at all. Any `+` or `-` line inside any of the six
      function bodies fails this task.

- [x] [P5-T4] Assert the cycle-2 changed-file scope. Run
      `git add -A` followed by
      `git diff --cached --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca`, and additionally
      `git status --porcelain`. Write `evidence/qa-gates/cycle-scope.<capture-timestamp>.md`.
      **Acceptance:** the enumerated set contains exactly these twenty-one paths and no other:
      the seven canonical production files listed in standing constraint 4;
      `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-scanner.ps1`,
      `.../claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`,
      `.../claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`,
      `.../claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`,
      `.../claude-customizations/.claude/hooks/validate-bash.ps1`,
      `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-scanner.ps1`,
      `.../codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`;
      and the seven suites this cycle edits, enumerated rather than described:
      `tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`,
      `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`,
      `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1`,
      `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1`, and
      `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1`. Paths under the
      feature folder's `evidence/` tree, `spec.md`, and `remediation-plan.2026-09-07T20-45.md` are
      additionally permitted and are listed separately; the plan file is in the anchored diff
      because the plan commit `459d245f` sits between the cycle-scope anchor and HEAD. Any other
      PowerShell path in the set blocks closure. The `git add -A` span is
      required because a name-listing diff enumerates tracked changes only and would report an empty
      list for a file this cycle creates; the porcelain span is required because it is the only view
      that survives if the change is committed before this task runs.

- [ ] [P5-T5] Re-verify that no frozen literal was deleted anywhere in the feature. Run
      `git diff 6dff80ed4596bec088d548b23013e6077e32c484 -- .claude/hooks .codex/hooks extensions/drm-copilot/resources`
      and search the removed lines for each frozen literal named in standing constraint 2. Write
      `evidence/qa-gates/frozen-literals-unchanged.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries one row per frozen-literal group, each recording the count
      of `-` lines in the feature-wide diff that contain that literal, and every such count is `0`.
      It additionally records that
      `grep -F -c "\$script:CdChainedReadCommandPattern = " .claude/hooks/validate-bash.ps1` returns
      `1` and that
      `grep -F -c "\$script:AbandonDispositionToken = " .claude/hooks/enforce-parallel-abandon-gate.ps1`
      returns `1`. This task uses the feature-wide anchor deliberately: a literal deleted earlier in
      the #545 work does not appear as a removed line against the cycle-scope anchor.

- [x] [P5-T6] Re-verify the line-cap inventory. Run the `[P0-T11]` `wc -l` command plus the same
      count over the seven bundle mirrors and the seven test suites edited by `[P1-T2]`, `[P2-T2]`,
      `[P2-T3]`, `[P3-T2]`, `[P3-T3]`, and `[P4-T2]`. Write
      `evidence/qa-gates/final-line-counts.<capture-timestamp>.md`.
      **Acceptance:** every recorded count is at or under 500, and
      `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` still reads exactly `500`,
      unchanged from `[P0-T11]`. The artifact records each file's before and after count side by
      side, so a count that moved is visible rather than inferred.

- [ ] [P5-T7] Consume the orchestrator-supplied per-file coverage figures. **The executor runs no
      coverage command.**

      **Precondition, discharged by the orchestrator before this task is dispatched.** The
      orchestrator pushes the branch, dispatches `.github/workflows/_poshqc.yml` via
      `workflow_dispatch` against the pushed head, reads the `LINE` counters from the
      `artifacts/pester/powershell-coverage.xml` that run produces, and supplies to the executor the
      run id, the measured commit SHA, and one post-change percentage for each of these seven
      canonical paths: `.claude/hooks/hook-command-scanner.ps1`,
      `.codex/hooks/hook-command-scanner.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`,
      `.codex/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-parallel-abandon-gate.ps1`,
      `.claude/hooks/enforce-pr-author-skill-helpers.ps1`, and `.claude/hooks/validate-bash.ps1`.

      **The executor confirms the supplied SHA carries the fix before consuming any figure.** Run
      `git show <supplied-sha>:.claude/hooks/hook-command-scanner.ps1 | grep -F -c 'function Test-CommandLineSegmentRawScan {'`,
      substituting the orchestrator-supplied SHA. The expected printed value is `1`. The plan quotes
      that literal here because `[P1-T4]` is the task that creates it. If the command prints `0`, or
      if `git show` fails because the SHA names no commit or the path is absent from it, the supplied
      SHA does not carry the fix: this task is `BLOCKED`, not `SKIPPED`. Record the blocked state,
      name the supplied SHA and the observed output, and stop.

      Write `evidence/qa-gates/final-per-file-coverage.<capture-timestamp>.md`.
      **Acceptance:** the artifact records all seven supplied percentages as numeric values, the
      supplied run id, the supplied commit SHA verbatim, the workflow path
      `.github/workflows/_poshqc.yml`, the exact `git show … | grep -F -c` command as run with the
      SHA substituted, and its observed output `1`. It carries a `TOOLCHAIN_SUBSTITUTION` note
      recording that the MCP test runner was deliberately not used for any coverage figure. Each of
      the seven recorded percentages must be at or above **85.0000**. If the orchestrator has not
      supplied all seven figures, this task is `BLOCKED`, not `SKIPPED`: record the blocked state and
      stop; do not substitute an MCP-produced figure and do not record a placeholder.

- [ ] [P5-T8] Record the coverage delta. Using the `[P0-T9]` baselines and the `[P5-T7]`
      post-change values, write `evidence/qa-gates/final-coverage-delta.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries a seven-row table, one row per canonical path, each with a
      baseline percentage, a post-change percentage, and their arithmetic difference. All seven rows
      carry a numeric baseline from run `34158596238`, a numeric post-change value, and a difference
      at or above `0.0000`. No row may record a `BASELINE_NOT_REPORTED` marker in place of a number:
      run `34158596238` reports a `LINE` counter for every one of the seven paths, including both
      scanner paths, so a marker in any baseline column is a recording error rather than a permitted
      substitution. If any of the seven rows shows a
      negative difference, the outcome is remediation-required and must not be reported as PASS:
      identify the uncovered new statement by reading the per-line `LINE` counters for that path in
      the `artifacts/pester/powershell-coverage.xml` produced by the `[P5-T7]` run, add one pinning
      case to that file's suite in the same `R2-` naming series and with the same determinism
      comment, then re-run `[P5-T7]` and this task against a fresh orchestrator-supplied dispatch of
      the recommitted head. Do not lower the 85.0000 threshold, do not waive the baseline comparison,
      and do not record the shortfall as an accepted regression. An added case changes the `tests`
      counts recorded in `[P1-T7]`, `[P2-T8]`, `[P3-T9]`, and `[P4-T6]`; update every artifact whose
      count moved.

- [ ] [P5-T9] Refresh the deny-preservation audit for AC-09. For each of the four regressing commands
      in the Scope table, and for each of the paired negatives named in `[P2-T8]`, `[P3-T9]`, and
      `[P4-T6]`, record the decision the head now produces and the named test that pins it. Write
      `evidence/qa-gates/deny-preservation-audit.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries one row per command with four columns — command, decision
      at the feature-wide anchor, decision at the post-fix head, and the `It` name that pins it —
      and every row's post-fix decision equals its anchor decision. Every `It` name cited must be one
      of the twenty-two distinct names, carried by twenty-seven cases because `[P1-T2]`'s five names
      are added to both scanner suites, created by `[P1-T2]`, `[P2-T2]`, `[P2-T3]`, `[P3-T2]`,
      `[P3-T3]`, and
      `[P4-T2]`, or one of the preservation names enumerated in `[P2-T8]`, `[P3-T9]`, and `[P4-T6]`.
      A row with no pinning `It` name fails this task. The artifact additionally states that the
      `.codex` runtime carries no `cd`-chain rule and therefore contributes no R-2.d row, and cites
      the `grep` result from the Scope section as the evidence for that.

- [ ] [P5-T10] Re-check AC-09 in `spec.md`. Change the checkbox at line 1499 from `- [ ]` to `- [x]`
      and append to that criterion's body one sentence naming the cycle-2 evidence that discharges
      it. Change nothing else in `spec.md`.
      **Acceptance:** `sed -n '1499p' docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      begins `- [x]`. `git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
      produces exactly one hunk. AC-22 at line 1565 remains `- [ ]`, confirmed by
      `sed -n '1565p'` on the same file. Do not perform this task before `[P5-T1]`, `[P5-T7]`,
      `[P5-T8]`, and `[P5-T9]` have all passed: AC-09 is the criterion those four discharge, and
      checking it earlier would record a claim the evidence does not yet support.

- [ ] [P5-T11] Run the evidence-location validator:
      `python scripts/dev_tools/validate_evidence_locations.py --root .`. Write
      `evidence/qa-gates/evidence-locations.<capture-timestamp>.md`.
      **Acceptance:** `EXIT_CODE: 0`. A clean run of this validator prints no lines at all — it
      emits one `VIOLATION: <path> — use <path> instead` line per violation and exits 1 — so the
      artifact records the observed stdout verbatim and states `(no output)` when it is empty. A
      non-empty stdout with exit 0 is not a possible outcome and must be reported rather than
      recorded as a pass. It also
      records the result of `ls -1 artifacts/ 2>/dev/null | sort`, and states that no path this plan
      wrote falls under `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`,
      `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`,
      `artifacts/regression-testing/`, or `artifacts/post-change/`.

- [ ] [P5-T12] Reconcile against the cycle-2 exit condition and close the final batch with a budget
      reset, using the `[P1-T1]` procedure. Write
      `evidence/qa-gates/cycle-2-reconciliation.<capture-timestamp>.md`.
      **Acceptance:** the artifact carries one row per closure condition, each naming the task that
      discharges it and its evidence artifact path, and every row reads PASS:
      (1) all four R-2 instances fixed at their call sites — `[P2-T5]`, `[P2-T6]`, `[P3-T5]`,
      `[P3-T6]`, `[P4-T4]`;
      (2) `Test-CommandLineFlag` and `Get-CommandLineFlagValue` unchanged, verified by
      `git diff 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1`
      producing no output;
      (3) all six fail-closed-correct call sites unchanged — `[P5-T3]`;
      (4) all four instances pinned by decision-surface tests on every applicable side — `[P1-T7]`,
      `[P2-T8]`, `[P3-T9]`, `[P4-T6]`;
      (5) canonical/bundle byte parity for all seven pairs — `[P1-T6]`, `[P2-T7]`, `[P3-T7]`,
      `[P4-T5]`;
      (6) format, analyze, and test completed in a single pass — `[P5-T1]`;
      (7) per-file coverage re-measured via `_poshqc.yml` dispatch, all seven at or above 85.0000
      with no regression on any of the seven rows, each of which carries a numeric baseline from run
      `34158596238` — `[P5-T7]`, `[P5-T8]`;
      (8) frozen literals and the two abandon token assignments unchanged — `[P5-T5]`;
      (9) every touched file at or under 500 lines and the 500-line Codex preimplementation gate
      untouched — `[P5-T6]`;
      (10) AC-09 re-checked with cited evidence and AC-22 left unchecked — `[P5-T10]`;
      (11) no file under `.claude/rules/` or `.github/instructions/` modified, verified by
      `git diff --name-only 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- .claude/rules .github/instructions`
      producing no output, paired with
      `git status --porcelain .claude/rules .github/instructions` also producing no output;
      (12) no F-1 through F-7 fix and no attempt on the two ambient-state failures, verified by
      `[P5-T4]`'s scope enumeration containing none of the files those follow-ups name.
      The task closes with the budget-reset record required by `[P1-T1]`'s acceptance.

---

## Rollback

Every edit in this plan is additive at the statement level and is confined to twenty-one paths. To
revert the whole cycle: `git checkout 26dba29533ba70f6cd80d14ac3c87ac24ca82aca -- <paths>` for the
twenty-one paths enumerated in `[P5-T4]`, then re-run `[P5-T1]`. No schema, no reason-code string, no
frozen literal, and no public parser signature other than the private
`Test-ParallelAbandonSegmentDisposition` parameter changes, so no consumer outside the four edited
hooks is affected by a revert.
