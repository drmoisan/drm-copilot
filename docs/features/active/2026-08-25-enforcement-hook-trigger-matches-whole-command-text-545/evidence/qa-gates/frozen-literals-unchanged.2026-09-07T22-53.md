# Final QA — frozen-literal removal check (feature-wide, paired-count formula)

Task: `[P5-T5]`
Timestamp: 2026-09-07T22-53

**Result: PASS.** All twenty-one frozen literals record an unpaired-removal count of `0`. Both
required declaration-count confirmations return `1`.

This artifact supersedes `frozen-literals-unchanged.2026-09-07T22-35.md`, which recorded the same
underlying diff under the earlier raw removed-line formula and correctly declined to check the task
off. The task text has since been corrected to count pairing rather than merely detect it. The
earlier artifact is retained unmodified as the record of that refusal.

Anchor: the **feature-wide** anchor `6dff80ed4596bec088d548b23013e6077e32c484`, the epic base. This
task asks whether any frozen literal was deleted anywhere in the #545 work, and a literal deleted
earlier in the feature does not appear as a removed line against the cycle-scope anchor
`26dba29533ba70f6cd80d14ac3c87ac24ca82aca`, so a check anchored there would pass vacuously. The
cycle-scope anchor is used only by `[P5-T3]`, `[P5-T4]`, and `[P5-T12]` conditions (2) and (11).

## Command 1 — capture the feature-wide diff

Command:
`git diff 6dff80ed4596bec088d548b23013e6077e32c484 -- .claude/hooks .codex/hooks extensions/drm-copilot/resources`
EXIT_CODE: 0
Output Summary: 6506 diff lines. Identical in length to the diff captured at 2026-09-07T22-35,
confirming HEAD `06d166e0` did not alter the hook/bundle diff surface relative to that capture.

## The counting formula

Per hunk (delimited by the diff's `@@ ... @@` header) and per literal:

    unpaired = max(0, removed_count - added_count)

where `removed_count` and `added_count` are the number of `-` and `+` lines in that hunk whose text
contains the literal. The row value is the sum of `unpaired` across all hunks for that literal.
Every row must be `0`.

Executable form actually run (inline `awk`; `awk -f` is denied under worktree isolation. The first
input file holds one literal on line 1, the second is the captured feature-wide diff):

```
awk 'function flush(  u){ if(inh){ u=r-a; if(u<0)u=0; if(r>0||a>0) printf "hunk@%d removed=%d added=%d unpaired=%d\n", hh, r, a, u; tot+=u } } NR==FNR{ if(FNR==1) lit=$0; next } /^@@/{ flush(); r=0; a=0; inh=1; hh=FNR; next } { if(inh && index($0,lit)>0){ c=substr($0,1,1); if(c=="-") r++; else if(c=="+") a++ } } END{ flush(); printf "TOTAL_UNPAIRED=%d\n", tot }' lit.txt featurewide.diff
```

EXIT_CODE: 0 for all twenty-one invocations.

`hunk@N` in the output below is the diff-file line number of that hunk's `@@` header, not a source
line number.

Why the pairing exemption is principled rather than an accommodation: standing constraint 2 freezes
the literal text and expressly permits the comparison primitive and its operand to change. An
in-place operand rewrite on the line that holds a frozen literal is rendered by a line-oriented diff
as a paired removed/added line carrying the identical literal — textually indistinguishable from a
deletion under a raw removed-line count, but not a deletion. Counting the pairing rather than
detecting it preserves the failure mode that matters: a genuinely deleted literal produces a `-`
line with no matching `+` line in its hunk and still fails its row.

## Pre-check — no literal is vacuous

A mistyped literal returns `0` unpaired whatever the executor does, so each literal was first
confirmed present in the tree being measured.

Command: `grep -rF -- '<literal>' .claude/hooks .codex/hooks extensions/drm-copilot/resources | wc -l`
EXIT_CODE: 0

| # | Literal | present-tree matching lines |
|---|---|---|
| 1 | `rm -rf` | 28 |
| 2 | `git push --force` | 20 |
| 3 | `git push origin --force` | 12 |
| 4 | `Remove-Item -Recurse -Force` | 4 |
| 5 | `git reset --hard` | 8 |
| 6 | `git push -f` | 8 |
| 7 | `(^|\s)git\s+(add|commit)\b` | 4 |
| 8 | `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b` | 4 |
| 9 | `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b` | 4 |
| 10 | `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b` | 4 |
| 11 | `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` | 4 |
| 12 | `new-potential-entry.ps1` | 8 |
| 13 | `new_potential_bug_entry` | 34 |
| 14 | `potential_to_issue` | 51 |
| 15 | `new_active_feature_folder` | 56 |
| 16 | `(?i)\bgh\s+issue\s+(?:create|new)\b` | 4 |
| 17 | `gh' -SubcommandPath @('issue', 'create')` | 4 |
| 18 | `$ghApiIssuesPostPattern = '(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))'` | 4 |
| 19 | `cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b` | 2 |
| 20 | `--disposition abandon` | 7 |
| 21 | `--confirm-abandon` | 5 |

Every literal is present. No row is vacuous.

## Per-frozen-literal unpaired-removal counts

### Group 1 — the six `Get-BlockedBashPattern` literals

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `rm -rf` | hunk@1084 r=0 a=2; hunk@1584 r=0 a=4; hunk@2583 r=0 a=2; hunk@3085 r=0 a=3; hunk@4309 r=0 a=2; hunk@4809 r=0 a=4; hunk@5821 r=0 a=2; hunk@6323 r=0 a=3 | **0** |
| `git push --force` | hunk@1584 r=0 a=5; hunk@3085 r=0 a=3; hunk@4809 r=0 a=5; hunk@6323 r=0 a=3 | **0** |
| `git push origin --force` | hunk@1584 r=0 a=2; hunk@3085 r=0 a=2; hunk@4809 r=0 a=2; hunk@6323 r=0 a=2 | **0** |
| `Remove-Item -Recurse -Force` | no hunk contains the literal on a `-` or `+` line | **0** |
| `git reset --hard` | hunk@1584 r=0 a=1; hunk@3085 r=0 a=1; hunk@4809 r=0 a=1; hunk@6323 r=0 a=1 | **0** |
| `git push -f` | hunk@1584 r=0 a=1; hunk@3085 r=0 a=1; hunk@4809 r=0 a=1; hunk@6323 r=0 a=1 | **0** |

Group total: **0**. Every occurrence is an addition (new test-surface or scanner text); nothing was
removed.

### Group 2 — the five preimplementation trigger patterns

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `(^|\s)git\s+(add|commit)\b` | none | **0** |
| `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b` | none | **0** |
| `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b` | none | **0** |
| `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b` | none | **0** |
| `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` | none | **0** |

Group total: **0**.

### Group 3 — the promotion hook's four forbidden tokens

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `new-potential-entry.ps1` | none | **0** |
| `new_potential_bug_entry` | none | **0** |
| `potential_to_issue` | none | **0** |
| `new_active_feature_folder` | none | **0** |

Group total: **0**.

### Group 4 — the promotion hook's two `gh` expressions

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `(?i)\bgh\s+issue\s+(?:create|new)\b` | hunk@535 r=1 a=1; hunk@2034 r=1 a=1; hunk@3760 r=1 a=1; hunk@5272 r=1 a=1 | **0** |
| `gh' -SubcommandPath @('issue', 'create')` | hunk@535 r=0 a=1; hunk@2034 r=0 a=1; hunk@3760 r=0 a=1; hunk@5272 r=0 a=1 | **0** |

Group total: **0**.

This is the group that recorded 4 under the earlier raw formula. The literal occurs exactly 8 times
in the feature-wide diff, at diff lines 558/560, 2057/2059, 3783/3785, and 5295/5297 — four
removed/added pairs, each pair inside a single hunk:

```
-    if ($CommandText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {
+        if ($segment.ScanText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {
```

The operand changed from `$CommandText` to `$segment.ScanText`; the literal was retyped unchanged on
the same line. `grep -F -c` returns `1` in each of the four canonical and mirror copies of
`enforce-promotion-mcp-only.ps1` today, so nothing was deleted. Provenance is commit `b5c59430`,
earlier in the #545 feature, not cycle 2.

### Group 5 — the `$ghApiIssuesPostPattern` declaration line

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `$ghApiIssuesPostPattern = '(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))'` | none | **0** |

Group total: **0**.

### Group 6 — `$script:CdChainedReadCommandPattern`

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b` | none | **0** |

Group total: **0**. This cycle un-orphaned the pattern by adding a read of it; the pattern text was
not rewritten.

### Group 7 — the two abandon token constants

| Literal | per-hunk detail | unpaired |
|---|---|---|
| `--disposition abandon` | none | **0** |
| `--confirm-abandon` | none | **0** |

Group total: **0**. This cycle reconstructs both accepted spellings from the split constant rather
than restating either literal, which is why neither appears on any diff line and why
`test_hook_states_each_token_exactly_once` still finds each exactly once.

## Summary of the seven groups

| Group | Required | Observed unpaired | Row passes |
|---|---|---|---|
| 1 — six `Get-BlockedBashPattern` literals | 0 | 0 | yes |
| 2 — five preimplementation trigger patterns | 0 | 0 | yes |
| 3 — four forbidden tokens | 0 | 0 | yes |
| 4 — two `gh` expressions | 0 | 0 | yes |
| 5 — `$ghApiIssuesPostPattern` declaration | 0 | 0 | yes |
| 6 — `$script:CdChainedReadCommandPattern` | 0 | 0 | yes |
| 7 — two abandon token constants | 0 | 0 | yes |

**TOTAL_UNPAIRED across all twenty-one literals: 0.**

## Negative control — the formula is able to fail

An acceptance condition that cannot fail verifies nothing. The formula was run against a synthetic
diff derived from the real one by deleting only the four `+` lines that carry the group-4 literal
(`sed '560d;2059d;3785d;5297d'`), which is exactly the shape a genuine deletion of that literal would
produce.

Command:
`sed '560d;2059d;3785d;5297d' featurewide.diff > control.diff`, then the same `awk` form against
`control.diff` with the group-4 literal.
EXIT_CODE: 0
Observed output:

```
hunk@535 removed=1 added=0 unpaired=1
hunk@2033 removed=1 added=0 unpaired=1
hunk@3758 removed=1 added=0 unpaired=1
hunk@5269 removed=1 added=0 unpaired=1
TOTAL_UNPAIRED=4
```

The control fails with `4` where the real diff passes with `0`. The pass recorded above is therefore
a measurement, not a tautology.

## Noted limitation (accepted, not closed here)

A hunk that deletes a frozen literal while separately **adding an unrelated line** carrying that same
literal would net to `unpaired = 0` and be masked by this formula. Recorded as an accepted residual
risk on the following grounds:

- It is not reachable by this plan's edits. No task in this plan adds a line carrying a frozen
  literal to a hunk that also deletes one.
- No line-oriented text check can distinguish an enforcing literal from one appearing in a comment or
  a test fixture, so no refinement of this check closes the gap.
- `[P5-T1]` stage 3 covers the behaviour independently: the promotion-hook suites assert the decision
  the hook produces, which is the property the frozen literal exists to protect.

No attempt was made to close it here.

## The two required declaration-count confirmations

Command: `grep -F -c "\$script:CdChainedReadCommandPattern = " .claude/hooks/validate-bash.ps1`
EXIT_CODE: 0
Observed output: **1**. Required: 1. Agrees.

Command:
`grep -F -c "\$script:AbandonDispositionToken = " .claude/hooks/enforce-parallel-abandon-gate.ps1`
EXIT_CODE: 0
Observed output: **1**. Required: 1. Agrees.

Both declarations survive in their existing single-assignment form.

## Output Summary

All twenty-one frozen literals record an unpaired-removal count of `0` against the feature-wide
anchor `6dff80ed`, so all seven group rows pass and `TOTAL_UNPAIRED=0`. The group-4 `gh` literal's
four removed lines are each paired with an added line carrying the identical literal in the same
hunk, an in-place operand rewrite made by commit `b5c59430` earlier in the feature; the literal is
present exactly once in each of its four copies today. A negative control confirms the formula
reports `4` when those pairings are absent, so the pass is non-vacuous. Both required declaration
greps return `1`. One residual masking case is recorded as an accepted limitation. No frozen literal
was deleted anywhere in the feature.
