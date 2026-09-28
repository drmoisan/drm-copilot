# Final QC step 3 — testing with coverage

Timestamp: 2026-09-17T13-56

Task: `[P4-T3]` of `remediation-plan.2026-09-17T12-29.md`
Loop pass: 1

Command, all three named verbatim:

- **C3**, run in its own wrapper script with nothing chained after it, because `Run.Exit` is `$true` at
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4 and a run with failures ends the host
  process:
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- **C7**, in a separate invocation:
  `$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'); $junit.testsuites.tests; $junit.testsuites.failures; $junit.testsuites.errors; @($junit.SelectNodes('//testcase[failure]')) | ForEach-Object { $_.name }`
- **C8**, in the same separate invocation:
  `$cov = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')`, then per file the
  `sourcefile` node whose `name` attribute is the leaf name, with the match count recorded.

EXIT_CODE: 2
ExpectedExitCode: 2

The observed C3 exit code is 2 and equals the expectation. C7 and C8 ran in their own invocation and exited 0.

Output Summary:

## `testsuites` element attributes

| attribute | value | baseline at `[P0-T6]` | required |
| --- | --- | --- | --- |
| `tests` | **4761** | 4758 | baseline + 3 = 4761 |
| `failures` | **2** | 2 | not asserted here; `[P4-T5]` asserts set membership |
| `errors` | **0** | 0 | **0** |

Passed count computed as `tests` minus `failures` minus `errors`: **4761 - 2 - 0 = 4759**.

The C3 console tally printed `Tests Passed: 4750, Failed: 2, Skipped: 9`, which sums to 4761, the `tests`
attribute. The computed figure of 4759 exceeds the console's executed-and-passed figure of 4750 by exactly the
9 skipped cases, because the plan's stated computation subtracts only failures and errors. Both are recorded.

**`tests` equals the `[P0-T6]` value plus 3**, which is the node count this remediation adds: three new
`It` blocks in the TargetResolution suite, none `-ForEach`-bound. The fourth new identifier,
`hands a repo-relative citation to the derivation`, replaced a delivered `It` in place and so adds no node,
and the two amended identifiers keep their nodes. 4758 + 3 = 4761, as measured.

`errors` is **0**.

## Failing node set

`//testcase[failure]` returned a node count of **2**, with these full `name` attributes:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

This is the same pair the `[P0-T6]` baseline recorded. No repository-wide failure count of 0 is asserted here;
the set-equality assertion is `[P4-T5]`.

## Per-identifier node counts for the six named identifiers

Each matched by `name`-attribute containment, with the absence of a child `failure` element as the pass
condition. Each is expected to match exactly **one** node, since none is `-ForEach`-bound:

| # | identifier | nodes matched | nodes carrying a child `failure` | verdict |
| --- | --- | --- | --- | --- |
| 1 | `allows a repo-relative citation placed in the item worktree` | **1** | **0** | pass |
| 2 | `denies with the ambiguity reason when a repo-relative citation places in no worktree` | **1** | **0** | pass |
| 3 | `hands a repo-relative citation carrying a branch signal to the derivation` | **1** | **0** | pass |
| 4 | `hands a repo-relative citation to the derivation` | **1** | **0** | pass |
| 5 | `allows when the modelled cwd is the item worktree` | **1** | **0** | pass |
| 6 | `denies rather than selecting the earliest candidate on an unresolved tie` | **1** | **0** | pass |

Every identifier matched its stated node count exactly, in both directions, and every matched node carries no
child `failure` element.

Identifiers 3 and 4 do not collide under containment matching, which is worth recording because their names
share a prefix: identifier 4's text continues `citation to the derivation` where identifier 3's continues
`citation carrying a branch signal`, so neither name contains the other and each match count of 1 is exact
rather than an artifact of overlap.

## Per-file line coverage

| file | `sourcefile` match count | form used | covered | total | line coverage | baseline at `[P0-T6]` | threshold |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1 | child `line` elements with `ci` > 0 over all child `line` elements | 88 | 97 | **90.72%** | 90.91% (90/99) | >= 85 |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 1 | child `line` elements with `ci` > 0 over all child `line` elements | 60 | 62 | **96.77%** | 93.55% (58/62) | >= 85 |

Both figures are at or above the uniform 85 percent line-coverage threshold in
`.claude/rules/quality-tiers.md`.

The `sourcefile` match count is exactly **1** for each leaf name, as the C8 procedure requires. A count other
than 1 would have halted this task. The count is 1 because `CodeCoverage.Path` registers the two repository
hook files and no `claude-customizations` path, so neither bundled mirror is measured and no duplicate leaf
name exists — a property `[P3-T6]` confirmed independently by measuring exactly one registration of the
helpers sibling in each settings file.

The `counter` element of `type` `LINE` fallback form was **not** used for either file; both `sourcefile` nodes
carry child `line` elements.

### Movement against the baseline, attributed

- **Parent hook: 90.91% to 90.72%**, with the denominator falling from 99 measurable lines to 97 and the
  numerator from 90 to 88. The two-line reduction in measurable lines is the pre-filter deletion: the
  `if ($text -notmatch ...)` test and its `return $null` were both executable and both measured. Both were
  covered at the baseline, so removing them reduced numerator and denominator by 2 each, which lowers the
  ratio slightly while removing no coverage. The figure remains 5.72 points above the threshold. No changed
  line lost coverage: `[P2-T2]` and `[P2-T3]` added no executable line, so there is no newly added line to be
  uncovered.
- **Helpers sibling: 93.55% to 96.77%**, with the denominator unchanged at 62 and the numerator rising from 58
  to 60. `[P2-T5]` changed only comment text, adding no executable line, so the denominator could not move;
  the two newly covered lines are reached because the derivation now runs on paths that previously
  short-circuited, which exercises `Select-PrdFeatureFolderByTarget` and its callers more fully. This is a
  coverage improvement.

**No branch-coverage figure is recorded.** Pester measures line and command coverage only, and
`.claude/rules/powershell.md` line 64 states there is no PowerShell branch-coverage gate. The whole-run
console figure `Covered 94.92% / 0%` is command coverage against a zero branch column, recorded for
information only with no threshold attached.

Acceptance: `errors` is 0; `tests` equals the `[P0-T6]` value of 4758 plus 3; each of the six identifiers
matches exactly one node with no child `failure`; and both per-file coverage figures are at or above 85.
Satisfied.
