# Remediation Inputs — issue #545 — cycle 2 entry

- Issue: #545
- Timestamp: 2026-09-07T20-45
- Cycle: 2 (cycle 1 closed R-1; this opens cycle 2 for R-2)
- Base: `epic/cleanup-merged-worktrees-hardening-integration` @ `6dff80ed4596bec088d548b23013e6077e32c484`
- Head at audit time: `85a3c3448c0900762e47d03f4fed2a9442cc1ef9`

## Source Audit Artifacts

| Artifact | Path |
|---|---|
| Policy audit | `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/policy-audit.2026-09-07T20-45.md` |
| Code review | `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/code-review.2026-09-07T20-45.md` |
| Feature audit | `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/feature-audit.2026-09-07T20-45.md` |
| AC source (amended by this audit) | `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md` — AC-09 unchecked at line 1499 |

Path-convention note for the orchestrator: `remediation-handoff-atomic-planner` prescribes a
`remediation/<entry-ts>/` and `audit/<exit-ts>/` folder-per-cycle layout. This branch's cycle-1
artifacts and the caller's explicit instruction for this round both use flat, timestamp-suffixed
filenames in the feature-folder root, and this artifact follows that established convention for
continuity. If the orchestrator prefers the folder layout for cycle 2, migrate all five cycle
artifacts together rather than mixing conventions within one cycle.

## Blocking Count

**1** blocking finding: **R-2**, with four enumerated instances sharing one root cause.

## R-2 — Wrapper-led segments produce an allow at four flag-gated call sites

### Root cause (single, shared by all four instances)

`ConvertTo-CommandLineToken` collapses a balanced quoted span into ONE token.
`Resolve-CommandLineInvocation` correctly applies D12's fail-closed rules and classifies a
wrapper-led, live-substitution, or unbalanced segment by raw containment, returning
`OperandIndex = -1`. But `Test-CommandLineFlag` and `Get-CommandLineFlagValue` then iterate
`$resolved.Segment.Tokens` unconditionally, so on such a segment **every flag reads as absent**.

Call sites that treat flag absence as *missing authorization* remain fail-closed and are correct.
Call sites that treat flag absence as *out of scope* fail open. The four below are the complete set
of the latter, established by enumerating every consumer of `Read-CommandLineSegment` across both
runtimes.

This is the same defect class as cycle 1's R-1, in the four locations the R-1 fix did not reach.

### Evidence that each is a weakened denial

Each row was established by extracting the base-commit copy of the file and comparing scope filters
directly, not by inference.

| # | Command | At `6dff80ed` | At `85a3c344` |
|---|---|---|---|
| R-2.a | `bash -c "gh pr merge --merge 688"` | in scope; denies `EPIC_MERGE_GATE_BLOCKED` absent an authorizing checkpoint | **allows** |
| R-2.b | `bash -c "python … --disposition abandon"` | in scope; denies `PARALLEL_ABANDON_BLOCKED` absent `--confirm-abandon` | **allows** |
| R-2.c | `bash -c "gh pr edit 42 --body 'x'"` | Case A denies `PR_AUTHOR_SKILL_BLOCKED` | **allows** |
| R-2.d | `bash -c "cd /x && head f"` | denied by `$script:CdChainedReadCommandPattern` | **allows** |

None is covered by an accepted residual risk. D4.1 accepts *over*-match inside wrapper-led segments
(deny-biased); these are *under*-match (allow-biased). D4.3 accepts an *unlisted* wrapper such as
`parallel`; `bash` is a listed member of the fourteen-name carve-out set. D3's conclusion states the
opposite of the observed behavior: "Every wrapper form D8 cited **that denies today** keeps its
denial." AC-09 states "**No existing denial is weakened**," and is now FAIL.

### In-repo reference implementation

`.claude/hooks/enforce-promotion-mcp-only.ps1` lines 104–141 already implements the correct shape:
byte-unchanged literals scanned against `$segment.ScanText`, the adjacency-requiring expression
scanned against `$segment.ScanText`, and a structural `Test-CommandLineInvocation` leg alongside for
the relocating spelling. Use it as the model. The cycle-1 R-1 fix at `validate-bash.ps1` lines
194–200 is the second model, and its three-disjunct guard
(`IsWrapperLed -or HasLiveSubstitution -or Unbalanced`) is the exact guard each fix below needs,
because it is set-identical with the scanner's own ScanText selection at
`hook-command-scanner.ps1` line 151.

---

### R-2.a — `enforce-epic-merge-gate.ps1` scope filter

**Files (4 copies):**
- `.claude/hooks/enforce-epic-merge-gate.ps1` — `Invoke-EpicMergeGateDecision`, lines 396–400
- `.codex/hooks/enforce-epic-merge-gate.ps1` — `Invoke-CodexEpicMergeDecision`, lines 130–133
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1`

**Current behavior:** `$hasMergeFlag = Test-CommandLineFlag … -FlagName '--merge'` reads the
wrapper-led segment's collapsed `Tokens`, so `--merge` reads absent and `-not $hasMergeFlag` returns
the allow decision.

**Expected behavior:** `bash -c "gh pr merge --merge 688"`, `sh -c "gh pr merge --merge 688"`,
`xargs gh pr merge --merge`, and `echo "$(gh pr merge --merge 688)"` each remain in scope, so the
gate evaluates the checkpoint and denies with `EPIC_MERGE_GATE_BLOCKED` when no checkpoint
authorizes the merge. `printf "gh pr merge --merge"` in a non-wrapper segment must still allow
(AT-4 must not regress).

**Suggested shape** (a helper is preferable to four inline copies of the same conjunct, since the
identical guard is needed at R-2.a and R-2.c; the planner may choose where it lives, provided both
parser files stay pure and byte-identical across runtimes):

```powershell
# Presence-with-wrapper-fallback: a wrapper's quoted argument is a nested command line, and
# ConvertTo-CommandLineToken collapses it into one token, so a flag inside it can never appear
# as a token. The three disjuncts are exactly the scanner's ScanText selection clause.
$hasMergeFlag = Test-CommandLineFlag -CommandText $command -CommandWord 'gh' `
    -SubcommandPath @('pr', 'merge') -FlagName '--merge'
if (-not $hasMergeFlag) {
    foreach ($segment in @(Read-CommandLineSegment -CommandText $command)) {
        if (($segment.IsWrapperLed -or $segment.HasLiveSubstitution -or $segment.Unbalanced) -and
            $segment.ScanText.IndexOf('--merge', [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            $hasMergeFlag = $true
            break
        }
    }
}
```

**Note on PR-number resolution:** `Get-EpicMergeGateCommandPrNumber` will return `$null` for a
wrapper-led segment, because `OperandIndex = -1` yields no operands and the flag value is
unreadable. That is already the fail-closed direction — `Test-CodexEpicMergeReady` and the Claude
equivalent treat `$null` as "no explicit PR number," and the parallel branch denies on `$null`. Do
not change it. Only the scope filter needs the fix.

---

### R-2.b — `enforce-parallel-abandon-gate.ps1` scope and confirmation tests

**Files (2 copies):**
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` — `Test-ParallelAbandonCommandInScope` lines 165–170; `Test-ParallelAbandonCommandConfirmed` lines 200–208
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-abandon-gate.ps1`

**Current behavior:** both functions pass `@($segment.Tokens)` to
`Test-ParallelAbandonSegmentDisposition` with no wrapper fallback, so a wrapper-led segment's
collapsed token matches neither the adjacent `--disposition` `abandon` pair nor the `=`-joined
single token.

**Expected behavior:** `bash -c "python -m scripts.dev_tools.parallel_mutation_abandon_cli --item 545 --disposition abandon"`
and the `--disposition=abandon` spelling inside the same wrapper are both in scope, so the gate
denies with `PARALLEL_ABANDON_BLOCKED` absent `--confirm-abandon` in the same segment. AT-11 must not
regress: `grep -n "--disposition abandon" scripts/…` is a non-wrapper segment and must still allow.

**Hard constraint:** `$script:AbandonDispositionToken` (line 41) and `$script:AbandonConfirmToken`
(line 42) must stay byte-unchanged in their **single-assignment form at those exact line numbers**.
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` extracts the consumer-side values from
exactly those two named assignments and must continue to pass. Derive the option name and value by
splitting the constant, as `Test-ParallelAbandonSegmentDisposition` already does; do not restate
either literal.

**Suggested shape:** extend `Test-ParallelAbandonSegmentDisposition` to accept the segment record
rather than only its tokens, and add a second condition testing `$segment.ScanText` by ordinal
case-insensitive `IndexOf` for both the space-separated and `=`-joined spellings when the segment is
wrapper-led, carries a live substitution, or is unbalanced. Apply the identical change to both the
in-scope and the confirmation call sites, so a wrapper-led command that carries **both** the
disposition and `--confirm-abandon` in the same segment is still correctly confirmed and allowed.

---

### R-2.c — `enforce-pr-author-skill-helpers.ps1` inline-body check on the `isPrEdit` branch

**Files (2 copies):**
- `.claude/hooks/enforce-pr-author-skill-helpers.ps1` — `Get-PrAuthorBypassReason`, flag reads at lines 190–191, allow branch at lines 205–210
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill-helpers.ps1`

**Current behavior:** `$hasInlineBody = Test-CommandLineFlag … '--body'` reads collapsed tokens, so
for `bash -c "gh pr edit 42 --body 'x'"` both flags read absent, `isPrEdit` is true, and the no-body
branch returns `$null` — allow.

**Expected behavior:** `bash -c "gh pr edit 42 --body 'x'"` denies with `PR_AUTHOR_SKILL_BLOCKED`
(Case A). Two existing behaviors must not regress: a quoted `--body-file` mention inside a JSON
receipt *value* in a non-wrapper segment must still allow, and `--body` must still not match
`--body-file` (`hook-command-invocation.Tests.ps1` line 166).

**Scope note:** the `isPrCreate` path is already fail-closed — when both flags read absent, Case B
denies with "New PRs require `--body-file`". Only the `isPrEdit` no-body allow branch is affected.
Applying the same wrapper fallback to both flag reads is still the correct fix, because it keeps the
two reads symmetric and avoids a `--body-file`-inside-a-wrapper case being misrouted into Case A.

**Do not** change any `PR_*` reason-code string, the receipt-verification logic, the orchestrator-state
preflight, or the `--body-file` path-value extraction, all of which AC-12 pins as unchanged.

---

### R-2.d — `validate-bash.ps1` `cd`-chained read rule

**Files (2 copies):**
- `.claude/hooks/validate-bash.ps1` — `Get-CdChainedReadCommandMatch`, lines 274–297
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-bash.ps1`

**Current behavior:** the function walks segments comparing `$segment.CommandWord` against `cd` and
then against the read-command family. A wrapper-led segment's command word is `bash`, and `&&`
inside a quoted span is consumed by the scanner's `inDouble` branch rather than delimiting, so
`bash -c "cd /x && head f"` is a single segment that never matches either half of the chain.

**This is also a deviation from the normative D12 call-site rewrite table** (`spec.md` line 1198),
which directs `validate-bash.ps1 L105` to "the `cd`-chained pattern evaluated per segment against
`ScanText`."

**Expected behavior:** `bash -c "cd /x && head f"`, `sh -c "cd /x; grep foo bar"`, and
`pwsh -Command "cd /x && cat f"` each deny with the existing `Forbidden Bash pattern` reason. The
intended narrowing must be preserved: `echo "cd /x && head f"` in a non-wrapper segment allows,
because the scanner masks the quoted span — that is the over-match fix this issue exists to deliver.

**Suggested shape:** add the D12-directed leg **alongside** the existing `CommandWord` walk, not
instead of it. The walk is required because `&&` and `;` are segment delimiters, so no single
segment carries both sides of an unquoted chain; the pattern leg is required because a wrapper-led
chain sits entirely inside one segment. The two are complementary.

```powershell
foreach ($segment in $segments) {
    if (($segment.IsWrapperLed -or $segment.HasLiveSubstitution -or $segment.Unbalanced) -and
        $segment.ScanText -match $script:CdChainedReadCommandPattern) {
        return ($Matches[2] -replace '\s+', ' ')
    }
}
```

The returned value must match the existing reason-string interpolation, including the `sed -n`
special case. This change also makes `$script:CdChainedReadCommandPattern` live again, resolving
code-review finding C-3 (a constant currently assigned and never read, retained only to discharge
the AC-07 byte-unchanged obligation).

**Hard constraint:** `$script:CdChainedReadCommandPattern` at line 222 stays byte-unchanged (AC-07),
and the eight existing `cd`-chain pins in `tests/scripts/claude-hooks/validate-bash.Tests.ps1` must
pass unmodified (AC-31).

---

## Required Test Additions

Parser-level pins are **not** sufficient. `hook-command-invocation.Tests.ps1` lines 201, 208, and 213
already assert that `Test-CommandLineInvocation` classifies wrapper-led, live-substitution, and
unbalanced segments, and those pass today — that is exactly why R-2 went undetected. Each new pin
must drive the **hook's decision surface**.

| Suite | Required cases |
|---|---|
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | `Invoke-EpicMergeGateDecision` denies `bash -c "gh pr merge --merge 688"` against an unauthorizing checkpoint; paired negative: the AT-4 `printf` case still allows |
| `tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | Codex equivalent through `Invoke-CodexEpicMergeDecision` |
| `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | `Invoke-ParallelAbandonGateDecision` denies `bash -c "… --disposition abandon"`; allows the same wrapper when `--confirm-abandon` is in the same segment; paired negative: AT-11's `grep` still allows |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | `Get-PrAuthorBypassReason` returns `PR_AUTHOR_SKILL_BLOCKED` for `bash -c "gh pr edit 42 --body 'x'"`; paired negative: the quoted `--body-file` receipt-value mention still allows |
| `tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | `Get-CdChainedReadCommandMatch` returns `head` for `bash -c "cd /x && head f"`; paired negative: `echo "cd /x && head f"` returns `$null` |

Each case must be recorded failing before the fix and passing after, with output under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/regression-testing/`,
following the cycle-1 `fail-before-r1-*` / `pass-after-r1-*` pattern.

## Acceptance Criteria Impact

| Criterion | Current | After remediation |
|---|---|---|
| AC-09 (`spec.md` line 1499) | `- [ ]` — unchecked by this audit; FAIL | Re-check only when all four instances are fixed **and** pinned |
| AC-22 (`spec.md` line 1565) | `- [ ]` | Closes on the PR body; out of scope for this cycle |

No new acceptance criterion should be added. R-2 is a failure to satisfy AC-09 as written, not a
gap in the criteria. If the planner concludes any instance should be an accepted residual instead of
a fix, that requires an explicit amendment to spec D4 recording it as a fourth accepted residual
risk with its rationale, in the same change — not a silent re-check of AC-09.

## Do Not Do

- **Do not** change any of the byte-unchanged trigger literals: the six `Get-BlockedBashPattern`
  literals, the five preimplementation trigger patterns, the promotion hook's four forbidden tokens
  and two `gh` expressions and `$ghApiIssuesPostPattern` declaration line,
  `$script:CdChainedReadCommandPattern`, or the two abandon token constants at lines 41–42.
- **Do not** move `$script:AbandonDispositionToken` or `$script:AbandonConfirmToken` off lines 41 and
  42, or restate either literal anywhere else in the file. `test_parallel_abandon_token_seam.py`
  parses exactly those two assignments.
- **Do not** widen the wrapper carve-out set to fix this. Adding members changes AC-05's pinned
  membership count and does not address the mechanism, which is flag reads on collapsed tokens.
- **Do not** change `Test-CommandLineFlag` or `Get-CommandLineFlagValue` to fall back to raw
  containment internally. Doing so would silently change every call site, including the four that
  are correctly fail-closed today, and would make `Get-CommandLineFlagValue` return a value it
  cannot actually parse from a nested command line. The fix belongs at the four call sites that
  treat absence as out-of-scope. If a shared helper is introduced, it must be a new, separately
  named predicate.
- **Do not** re-run or regenerate coverage for files this cycle does not touch. Cycle 1's composite
  measurement is valid; only the files edited in cycle 2 need re-measurement.
- **Do not** re-check AC-09 until every one of the four instances is both fixed and pinned by a
  decision-surface test on every applicable side.
- **Do not** expand scope beyond R-2. The Medium and Low findings in
  `code-review.2026-09-07T20-45.md` (C-2 `rm -rfv`, C-4 the 500-line file) are follow-up candidates,
  not cycle-2 work. C-3 resolves as a side effect of R-2.d and needs no separate task.
- **Do not** modify any file under `.github/instructions/` or `.claude/rules/`.
- **Do not** weaken, delete, or reverse any existing test assertion. The only assertion reversal
  authorized by this feature is the single heredoc `It` per side already delivered in cycle 1.

## Verification Commands

Run after the fix, in this order, restarting from the first stage on any failure or auto-fix:

```
mcp__drm-copilot__run_poshqc_format     # over the changed files
mcp__drm-copilot__run_poshqc_analyze
mcp__drm-copilot__run_poshqc_test       # per-suite results from artifacts/pester/pester-junit.xml
```

Coverage for the files edited in this cycle must come from a CI dispatch of
`.github/workflows/_poshqc.yml` against the pushed head, not from the MCP test runner, which
resolves runsettings from the installed extension and cannot see this branch's `CodeCoverage.Path`
entries.

Parity and cap checks:

```
cmp -s .claude/hooks/<f> extensions/drm-copilot/resources/claude-customizations/.claude/hooks/<f>
cmp -s .codex/hooks/<f>  extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/<f>
wc -l <every edited .ps1>          # every file must stay at or under 500
python scripts/dev_tools/validate_evidence_locations.py --root .
```

Note the line-cap risk: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at exactly
500 lines in both copies. R-2 does not touch it, but any incidental edit to it in this cycle must be
paired with an extraction.

Expected-failure allowance: `enforce-pr-author-skill.Tests.ps1` (one case) and
`codex-pretooluse-integration.Tests.ps1` (one case) fail locally in this worktree from gitignored
ambient checkpoint state and are green on a clean CI checkout. Both were independently confirmed
not change-caused. Do not attempt to "fix" them in this cycle; `F-4` in
`docs/features/potential/2026-09-07-issue-545-feature-review-follow-ups.md` files the first.

## Handoff

Route to `atomic-planner` per `remediation-handoff-atomic-planner`. The planner authors the cycle-2
remediation plan conforming to `atomic-plan-contract`; the orchestrator then runs the
`atomic-executor` preflight sub-loop before execution. Workers are invoked by `atomic-executor`
only. The plan must validate through `mcp__drm-copilot__validate_orchestration_artifacts` with
`artifact_type: "plan"` before preflight.

Exit gate for cycle 2: `blocking_count == 0` on the next `feature-review` reaudit.
