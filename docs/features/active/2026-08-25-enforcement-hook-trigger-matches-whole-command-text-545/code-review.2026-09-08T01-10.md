# Code Review — Remediation Cycle 2 Reaudit (issue #545)

Timestamp: 2026-09-08T01-10
Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r4`
Head reviewed: `636b18a7bf2e6ec4ff76abbc8d1d45577e80af3a`
Cycle-2 scope anchor: `26dba29533ba70f6cd80d14ac3c87ac24ca82aca`
Feature-wide anchor: `6dff80ed4596bec088d548b23013e6077e32c484`

## Executive Summary

Cycle 2 closes all four instances of the cycle-1 blocking finding R-2 by the mechanism the review
prescribed: a new, separately named predicate `Test-CommandLineSegmentRawScan` in the shared
scanner, applied as a guarded fallback at the four call sites that read flag absence as *out of
scope*. The two token readers the review ring-fenced — `Test-CommandLineFlag` and
`Get-CommandLineFlagValue` — are byte-unchanged, as are the six call sites that correctly depend on
their fail-closed behaviour.

The central risk in this remediation was that a raw-scan fallback would fire too broadly and
re-create the whole-command-text over-match the feature exists to remove. It does not. The
predicate's three disjuncts are set-identical with the scanner's own ScanText selection clause, every
call site reads `ScanText` rather than `RawText`, and each of the four call sites carries an explicit
negative case pinning the canonical over-match input to an allow. Independently traced: the delivered
behaviour on every input examined sits at or inside the epic-base behaviour, never outside it.

The code is small, readable, and consistently documented. Each new leg carries a comment that names
the mechanism (the one-token collapse of a quoted span), the direction of the failure it closes, and
why the guard keeps the narrowing intact. That is the right level of explanation for enforcement
code whose failure modes are asymmetric.

Cycle-1 finding C-3 (the dead `$script:CdChainedReadCommandPattern` constant) closes as a side
effect of R-2.d, as predicted. C-2 (`rm -rfv`) and C-4 (the 500-line file) remain open and are out
of scope for this cycle.

Four new observations are recorded below. All are Low or Informational. **No Blocking or Medium
finding.**

## Findings Table

| ID | Severity | File | Location | Finding | Recommendation |
|---|---|---|---|---|---|
| C-5 | Low | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-pr-author-skill-helpers.ps1` (+3 bundle copies) | merge gate L403–411 / L135–143; helpers L197–210 | The fallback loops **every** segment looking for the flag, not only the segment in which the invocation matched. A command line whose `gh pr edit` sits in one segment and whose `--body` mention sits in an unrelated wrapper-led segment now classifies as an inline-body edit. | Restrict the fallback loop to the segment `Resolve-CommandLineInvocation` matched, in a follow-up. Not blocking: the behaviour equals the epic base and is fail-closed. |
| C-6 | Low | `.claude/hooks/enforce-parallel-abandon-gate.ps1` (+1 bundle copy) | `Test-ParallelAbandonCommandConfirmed` L226–228 | The confirmation marker is matched by `IndexOf`, so a superstring such as `--confirm-abandon-now` satisfies it on a raw-scanned segment. This is the one raw-scan leg whose direction is *allow*. | No action required. Recorded so the trade is visible. Exact reproduction of the epic-base semantics; see the analysis below. |
| C-7 | Low | `.claude/hooks/enforce-parallel-abandon-gate.ps1` (+1 bundle copy) | `Test-ParallelAbandonSegmentDisposition` L118 | The parameter changed from `[Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Token` to `[Parameter(Mandatory)][AllowNull()] $Segment` — untyped. A caller passing the wrong shape gets a silent `$false` rather than a binding error. | Constrain to `[pscustomobject]` in a follow-up. The function is file-private in practice: grep shows two call sites, both in this file, and no test binds it. |
| C-8 | Informational | `.claude/hooks/enforce-epic-merge-gate.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1` | `Get-EpicMergeGateCommandPrNumber` | A wrapper-led merge is now in scope, but the PR number remains unresolvable for it, because both the operand reader and the flag-value reader are token-based and were correctly left unchanged. `bash -c "gh pr merge --merge 688"` therefore always denies, even when an epic or parallel checkpoint authorizes PR 688. | No action on this branch. The direction is fail-closed and correct; the practical consequence is that an authorized merge must be spelled without a wrapper. |
| C-9 | Informational | `.claude/hooks/hook-command-scanner.ps1` L165 (+3 copies) | new function | `Test-CommandLineSegmentRawScan` is a new public function in the scanner not enumerated in the spec's D12 parser contract. AC-35 does not require exhaustiveness and the mechanism was explicitly authorized by the cycle-1 remediation inputs, so no criterion is violated. | Amend D12 when the #545 spec is next touched. |

Carried forward from cycle 1, unchanged and out of scope for this cycle: C-2 (Medium, `rm -rfv` no
longer matches the `rm -rf` literal under whole-token equality) and C-4 (Low,
`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` at exactly 500 lines). Both are
recorded in `code-review.2026-09-07T20-45.md`. C-4 was re-verified untouched: the file is absent from
the cycle-2 changed-file list and `wc -l` still reports 500.

## Implementation Audit

### The predicate is correctly scoped

`hook-command-scanner.ps1` L165–194:

```powershell
param([Parameter(Mandatory)][AllowNull()] $Segment)

if ($null -eq $Segment) {
    return $false
}

return ([bool]$Segment.IsWrapperLed -or [bool]$Segment.HasLiveSubstitution -or [bool]$Segment.Unbalanced)
```

`ConvertTo-CommandLineSegmentRecord` L151:

```powershell
$scanText = $MaskedText
if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }
```

The record's three fields are assigned directly from the three variables the clause tests, so the
predicate and the clause select the same set of segments. The `$null` guard returns `$false`, which
is the over-match-safe direction: a caller iterating an empty segment list is never handed a true.
The `[bool]` casts also make a hand-built object missing a property evaluate to `$false` rather than
throwing, again in the safe direction.

The one stylistic note: the parameter is untyped (`$Segment` with no type constraint). That is
consistent with C-7 and applies here too, though the null guard and the `[bool]` casts make the
consequences benign.

### The four call sites, read individually

**R-2.a, both merge gates.** The fallback runs only when `Test-CommandLineFlag` already reported the
flag absent, breaks on first match, and is conjoined with the unchanged structural
`$isMergeInvocation`. Since it can only turn `$hasMergeFlag` from `$false` to `$true`, it can only
move a command *into* scope. It cannot weaken a denial by construction. The Claude and Codex legs are
textually parallel, differing only in the local variable name (`$commandText` versus `$command`),
which is the pre-existing difference between the two files.

**R-2.b, the abandon gate.** Two changes. The scope leg (L144–155) runs after the token loop and
reconstructs both accepted spellings from the split constant rather than restating either literal —
`$joined` and `$optionName + ' ' + $optionValue`. That is the right call: it keeps
`test_parallel_abandon_token_seam.py` finding each literal exactly once in the file, which the
reviewer verified independently (`grep -c` returns 1 for each in
`.claude/hooks/enforce-parallel-abandon-gate.ps1`). The confirmation leg (L226–228) is the one
raw-scan use whose direction is allow, analysed under C-6 below.

The signature change from `-Token` to `-Segment` is a small API break on a helper. Grep confirms only
two call sites, both in this file and both updated, and no test binds the function directly. Correct
handling of an in-file refactor.

**R-2.c, the pr-author helpers.** The interesting decision here is ordering: `--body-file` is tested
before `--body`, with `elseif`, so a `--body-file` carried inside a wrapper is never misread as an
inline body. That is necessary — `--body` is a prefix of `--body-file` and `IndexOf` is substring
containment — and the comment says exactly why. The reviewer traced the downstream consequence: for
`bash -c "gh pr create --body-file artifacts/pr_body_1.md"`, `$hasBodyFile` becoming true routes to
Case C and then to `Test-PrAuthorReceiptVerification`, which matches `--body-file` against the whole
`$CommandText` with a case-sensitive regex at L70 and therefore still resolves the path and runs all
six receipt checks. No verification is skipped, and a non-canonical path inside a wrapper still
returns `PR_BODY_PATH_NONCANONICAL`. This is the one place where the fix could have converted a deny
into an unverified allow, and it does not.

**R-2.d, `validate-bash.ps1`.** The new leg runs *before* the CommandWord walk and returns
`($Matches[2] -replace '\s+', ' ')`, which yields the same value shape the walk returns (`'grep'`,
`'sed -n'`, and so on) and feeds the same `Get-BashBlockReason` message template. The docstring's
claim that the two legs are complementary and that ordering only decides which leg reports a chain
both could see is accurate: a `&&`-delimited chain never lands in one segment, so only the walk sees
it, while a wrapper-led chain lands entirely in one segment whose command word is the wrapper, so
only the pattern leg sees it. The comment also states the retained narrowing explicitly and names
the input that proves it (`echo "cd /x && head f"`), which is pinned by case `R2d-N1`.

### The over-match analysis, in full

The three behaviours to compare on any given input are: the epic-base whole-text scan, the cycle-1
token-only read, and the cycle-2 delivered read.

| Input | Epic base `6dff80ed` | Cycle 1 | Cycle 2 |
|---|---|---|---|
| `git commit -m "gh pr merge --merge 688"` | deny (over-match) | allow | allow |
| `bash -c "gh pr merge --merge 688"` | deny | allow (the R-2 defect) | deny |
| `echo "cd /x && head f"` | deny (over-match) | allow | allow |
| `bash -c "cd /x && head f"` | deny | allow (the R-2 defect) | deny |
| `echo '{"cmd":"gh pr edit 42 --body x"}' > f` | deny (over-match) | allow | allow |
| `bash -c "gh pr edit 42 --body 'x'"` | deny | allow (the R-2 defect) | deny |

The delivered behaviour is a strict subset of the epic base and a strict superset of cycle 1. The
over-match rows stay at allow; the under-match rows return to deny. That is the intended shape and it
is pinned by test on every row.

### C-5, cross-segment flag attribution

The merge-gate and pr-author fallbacks iterate the whole segment list rather than only the matched
segment. Consequence, using the pr-author case as the example:

```
gh pr edit 42 --add-label bug && bash -c 'echo "--body"'
```

Segment 1 matches `gh pr edit` structurally and carries neither body flag. Segment 2 is wrapper-led,
so the fallback reads it raw, finds `--body`, and sets `$hasInlineBody`. Case A then returns
`PR_AUTHOR_SKILL_BLOCKED` for a command whose actual `gh pr edit` carries no body flag at all.

This is a deviation from strict per-segment attribution, which is the design's stated model. It is
recorded as **Low** rather than Medium for three reasons: the epic base denied the same input via its
whole-text regex, so nothing is weakened; the direction is fail-closed, which D4 accepts inside
wrappers; and the trigger requires a wrapper-led sibling segment on the same line, which is rare in
practice. The clean form is to pass the matched segment into the fallback instead of re-enumerating.

### C-6, the one allow-direction raw leg

`Test-ParallelAbandonCommandConfirmed` L226–228 can turn a deny into an allow when the confirmation
marker appears anywhere in a raw-scanned segment's text. The reviewer looked for a case where this
weakens an existing denial and found none, for two reasons.

First, the scope leg and the confirmation leg move together. A wrapper-led segment that only becomes
in-scope through the new raw scope leg was previously out of scope entirely — that is, allowed — so a
raw confirmation on the same segment cannot make the outcome worse than before.

Second, for a segment already in scope by tokens, the reviewer checked whether the raw read can see a
marker the token read cannot. It can, in two shapes: a marker inside a heredoc body (masked out of
`TokenText` but present in `RawText`), and a superstring such as `--confirm-abandon-now` (matched by
`IndexOf`, not by token equality). Both were then checked against the epic base, where
`Test-ParallelAbandonCommandConfirmed` was `$NormalizedCommand.Contains('--confirm-abandon',
OrdinalIgnoreCase)` — plain whole-text substring containment. Both shapes allowed at the epic base
too. There is therefore no input on which cycle 2 weakens a denial that existed before the feature.

Quoted spellings are a non-issue: `ConvertTo-CommandLineToken` strips balanced quotes, so
`--msg "--confirm-abandon"` already produced the bare token and already allowed.

## Test Quality Audit

Twenty cases added across seven suites, 247 added lines, **zero deleted lines**. No existing
assertion was modified, reversed, or removed.

| Suite | Added | Positive / negative split |
|---|---|---|
| `claude-hooks/hook-command-scanner.Tests.ps1` | 5 | 3 true-direction disjuncts, 1 masked-segment false, 1 null-input false |
| `codex-hooks/hook-command-scanner.Tests.ps1` | 5 | identical set on the Codex side |
| `claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 3 | 1 deny (`bash -c`), 1 allow (quoted mention), 1 deny-preservation pin (`xargs` relocation, already in scope by token) |
| `codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 2 | 1 deny, 1 allow |
| `claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 4 | 2 deny (space-separated, equals-joined), 1 allow-with-marker, 1 allow (quoted mention) |
| `claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 4 | 1 deny, 2 routing (`PR_CONTEXT_MISSING`, not `PR_AUTHOR_SKILL_BLOCKED`), 1 allow |
| `claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 4 | 3 detect (`bash -c`, `sh -c`, `pwsh -Command`), 1 non-detect |

Strengths worth naming:

- **Every instance carries a paired negative.** A deny-only test set would not have caught an
  over-broad fallback; each of the four instances pins both directions. `R2-P4` is the single most
  valuable case in the set, because it asserts the predicate itself is false on the exact input the
  feature exists to stop denying.
- **`R2c-C2` and `R2c-N1` assert the reason code, not just the decision**, including
  `Should -Not -Match 'PR_AUTHOR_SKILL_BLOCKED'`. That distinguishes "denied for the right reason"
  from "denied", which is the property the `--body-file`-before-`--body` ordering actually protects.
- **Determinism is stated per Context, not assumed.** Each new Context opens with a comment naming
  what it drives and what it mocks. Every case uses a literal fixture; the decision-surface cases mock
  all three checkpoint readers to `$null` so the assertion turns on the scope filter alone rather
  than on ambient state. That is the correct construction for a gate test and it is why these cases
  pass identically in CI and locally.
- **Codex parity is tested, not assumed.** The scanner predicate cases and an R-2.a decision case
  exist on both runtimes.

One observation, not a finding: `R2d-C2` uses `sh -c` and `R2d-C3` uses `pwsh -NoProfile -Command`,
which exercise two additional members of the wrapper set beyond `bash`. That is a good instinct and
worth repeating for the other three instances, which test `bash -c` only.

## Security and Correctness Checks

| Check | Result |
|---|---|
| Any deny converted to allow by cycle 2 | None found. Each fallback either only widens scope (merge gate, abandon scope leg, validate-bash) or is neutralized downstream by an unchanged whole-text check (pr-author receipt verification). The abandon confirmation leg is analysed under C-6 and matches the epic base. |
| Any new unguarded raw-text read | None. `grep -rn "\.RawText"` returns only the two pre-existing sites, neither changed in cycle 2. |
| Reason codes and denylist literals altered | None. Zero reason-code tokens appear on any removed line in the entire feature-wide diff; the six denylist literals and five trigger patterns are byte-identical base versus head. |
| Injection or path handling introduced | None. All five legs are pure string comparisons over an in-memory segment record. No disk, process, network, or environment access added. |
| Error handling | Every leg is total: the predicate short-circuits on `$null`, `IndexOf` and `-match` are total over strings, and `[string]` casts guard the two places where `ScanText` could arrive as a non-string. |
| Public API breakage | One in-file helper signature changed (`Test-ParallelAbandonSegmentDisposition`); both call sites updated, no external caller, no test binding. See C-7. |

## Scope-Fenced Items (recorded, not raised)

Per the review scope fence, the following are noted as non-blocking observations only:

- **EA-3(a).** `Test-ChildCheckpointAllowsEpicMerge` and its Codex sibling `Test-CodexChildMergeReady`
  take only a `Checkpoint` parameter and are consulted first, so a checkpoint with `epic_mode` true
  and `step9_status` passed authorizes merging any PR number. Confirmed present at
  `.claude/hooks/enforce-epic-merge-gate.ps1` L177–205, consulted first at L417–420. Filed
  follow-up; not raised here.
- **EA-3(b).** The `.codex` hook copies outside the delivered D11 scope. Confirmed that
  `.codex/hooks/` carries no `enforce-parallel-abandon-gate.ps1` and no `enforce-pr-author-skill*`,
  so R-2.b and R-2.c are correctly Claude-only, and that `.codex/hooks/validate-bash.ps1` contains no
  `CdChainedRead` logic at all (`grep -c` returns 0), so R-2.d is correctly Claude-only. The
  Claude-only delivery of these three instances is therefore complete rather than partial.
- Issue #591 remains open through this epic. AC-22 closes on the PR body and is the orchestrator's.

## Verdict

**PASS.** Zero Blocking findings, zero Medium findings. Five new Low or Informational observations
(C-5 through C-9), none of which requires action on this branch.

The remediation is well-targeted: it fixes the four sites the review named, by the mechanism the
review prescribed, without touching the six sites the review ring-fenced, and it pins both directions
of every change. The residual observations are refinements of a correct fix, not defects in it.
