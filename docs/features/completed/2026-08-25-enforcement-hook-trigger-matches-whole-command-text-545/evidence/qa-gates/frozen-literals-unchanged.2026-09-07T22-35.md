# Final QA — frozen-literal removal check (feature-wide)

Task: `[P5-T5]`
Timestamp: 2026-09-07T22-35

**Result: one group diverges from the plan's predicted count. This task is NOT checked off.**
The divergence, its full evidence, and the reason it is a proxy-measure artefact rather than a
frozen-literal deletion are recorded below in full. No acceptance condition was reinterpreted or
weakened to produce a pass.

Anchor: the **feature-wide** anchor `6dff80ed4596bec088d548b23013e6077e32c484`, the epic base. This
task asks whether any frozen literal was deleted anywhere in the #545 work, and a literal deleted
earlier in the feature does not appear as a removed line against the cycle-scope anchor, so the
feature-wide anchor is the only correct base here. The cycle-scope anchor `26dba295` is used only by
`[P5-T3]` and `[P5-T4]`.

Command:
`git diff 6dff80ed4596bec088d548b23013e6077e32c484 -- .claude/hooks .codex/hooks extensions/drm-copilot/resources`
EXIT_CODE: 0

Output Summary of the diff itself: 6506 diff lines, of which **136** are removed lines (`^-`
excluding the `---` file header). Each frozen literal was counted with
`grep -F -c -- '<literal>'` against those 136 removed lines.

## Per-frozen-literal removed-line counts

### Group 1 — the six `Get-BlockedBashPattern` literals

| Literal | `-` lines containing it |
|---|---|
| `rm -rf` | 0 |
| `git push --force` | 0 |
| `git push origin --force` | 0 |
| `Remove-Item -Recurse -Force` | 0 |
| `git reset --hard` | 0 |
| `git push -f` | 0 |

Group total: **0**.

### Group 2 — the five preimplementation trigger patterns

| Literal | `-` lines containing it |
|---|---|
| `(^|\s)git\s+(add|commit)\b` | 0 |
| `(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b` | 0 |
| `(^|\s)npm\s+.*\s+(prettier|lint|typecheck|test:unit)\b` | 0 |
| `(^|\s)npx\s+(prettier|eslint|tsc|jest)\b` | 0 |
| `(^|\s)pwsh\s+.*(Invoke-Pester|tests/scripts/)` | 0 |

Group total: **0**.

### Group 3 — the promotion hook's four forbidden tokens

| Literal | `-` lines containing it |
|---|---|
| `new-potential-entry.ps1` | 0 |
| `new_potential_bug_entry` | 0 |
| `potential_to_issue` | 0 |
| `new_active_feature_folder` | 0 |

Group total: **0**.

### Group 4 — the promotion hook's two `gh` expressions

| Literal | `-` lines containing it |
|---|---|
| `(?i)\bgh\s+issue\s+(?:create|new)\b` | **4** |
| `gh' -SubcommandPath @('issue', 'create')` (the structural spelling) | 0 |

Group total: **4**. **This is the divergence.** Analysed in full below.

### Group 5 — the `$ghApiIssuesPostPattern` declaration line

| Literal | `-` lines containing it |
|---|---|
| `$ghApiIssuesPostPattern = '(?i)(?=.*\bgh\s+api\b)(?=.*repos/[^/\s]+/[^/\s]+/issues(?:\b|/[^/\s]*$))(?=.*(?:-X\s+POST|--method\s+POST))'` | 0 |

Group total: **0**.

### Group 6 — `$script:CdChainedReadCommandPattern`

| Literal | `-` lines containing it |
|---|---|
| `cd\s+\S.*?(&&|;)\s*(grep|cat|head|tail|less|more|awk|sed\s+-n)\b` | 0 |

Group total: **0**. This is the pattern Edit 6 of this cycle newly reads. It was un-orphaned, not
rewritten.

### Group 7 — the two abandon token constants

| Literal | `-` lines containing it |
|---|---|
| `--disposition abandon` | 0 |
| `--confirm-abandon` | 0 |

Group total: **0**. Edit 4 of this cycle reconstructs both accepted spellings from the split
constant rather than restating either literal, which is why neither appears on a removed line and
why the seam test still finds each exactly once.

## Summary of the seven groups

| Group | Predicted count | Observed count | Agrees |
|---|---|---|---|
| 1 — six `Get-BlockedBashPattern` literals | 0 | 0 | yes |
| 2 — five preimplementation trigger patterns | 0 | 0 | yes |
| 3 — four forbidden tokens | 0 | 0 | yes |
| 4 — two `gh` expressions | 0 | **4** | **no** |
| 5 — `$ghApiIssuesPostPattern` declaration | 0 | 0 | yes |
| 6 — `$script:CdChainedReadCommandPattern` | 0 | 0 | yes |
| 7 — two abandon token constants | 0 | 0 | yes |

Twenty of the twenty-one individual literals record 0. One records 4.

## The divergence, analysed

The four removed lines are all the same line in the four copies of `enforce-promotion-mcp-only.ps1`
(Claude canonical, Codex canonical, and their two bundle mirrors):

```
-    if ($CommandText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {
```

Each is paired, in the same hunk, with an added line carrying the identical literal:

```
+    foreach ($segment in $segments) {
+        if ($segment.ScanText -match '(?i)\bgh\s+issue\s+(?:create|new)\b') {
+            return (Get-PromotionMcpOnlyGhIssueBlockedReason)
+        }
```

`grep -F -c` over the whole feature-wide diff returns **8** occurrences of the literal: 4 on removed
lines and 4 on added lines. The net removal is therefore **0**.

Present-tree confirmation. `grep -rF -c` reports the literal present **exactly once in each of the
four copies**:

| File | occurrences |
|---|---|
| `.claude/hooks/enforce-promotion-mcp-only.ps1` | 1 |
| `.codex/hooks/enforce-promotion-mcp-only.ps1` | 1 |
| `extensions/…/claude-customizations/.claude/hooks/enforce-promotion-mcp-only.ps1` | 1 |
| `extensions/…/codex-and-agents-customizations/.codex/hooks/enforce-promotion-mcp-only.ps1` | 1 |

What actually changed is the **operand**, from `$CommandText` to `$segment.ScanText`, plus the
`foreach` wrapper that introduces `$segment`. Standing constraint 2 states the rule R2 obligation
as: literal text is frozen, and "only the comparison primitive and its operand may change". The
operand changed; the literal did not. The R2 obligation is satisfied.

The count of 4 is an artefact of the measurement, not a finding. A line-oriented count of removed
lines cannot distinguish a deleted literal from a literal carried across an in-place rewrite of the
line that holds it: both produce a `-` line containing the literal. Every other group escaped this
because none of their lines was rewritten in place during the feature.

Provenance. The rewrite was **not** made by cycle 2. `git diff --cached --name-only 26dba295 --
.claude/hooks/enforce-promotion-mcp-only.ps1 .codex/hooks/enforce-promotion-mcp-only.ps1` produces
no output, so neither promotion-hook copy is in this cycle's changed-file set. `git log --oneline
6dff80ed..HEAD -- .claude/hooks/enforce-promotion-mcp-only.ps1` attributes the change to a single
earlier commit in the same feature: `b5c59430 fix(545): scope preimplementation and promotion gate
triggers per segment`. It is a pre-existing state of the branch that this cycle neither created nor
can close.

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

Six of the seven frozen-literal groups record 0 removed lines, and both required declaration-count
confirmations return 1. Group 4 records 4 removed lines for the literal
`(?i)\bgh\s+issue\s+(?:create|new)\b`. Those four lines are paired with four added lines carrying
the identical literal in the same hunks; the literal is present exactly once in each of the four
`enforce-promotion-mcp-only.ps1` copies in the current tree; only the operand changed, which
standing constraint 2 expressly permits; and the change was made by commit `b5c59430` earlier in the
feature, not by cycle 2. No frozen literal was deleted anywhere in the feature. The stated
acceptance condition "every such count is 0" is nonetheless not met as literally written, so this
task is left unchecked and referred to the orchestrator.
