# Phase 0 — baseline Pester and coverage state

Timestamp: 2026-09-17T13-56

Task: `[P0-T6]` of `remediation-plan.2026-09-17T12-29.md`

Command, all three named verbatim:

- **C3**, run in its own wrapper script with nothing chained after it, because `Run.Exit` is `$true` at
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4 and a run with failures ends the host
  process:
  `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- **C7**, in a separate invocation:
  `$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml'); $junit.testsuites.tests; $junit.testsuites.failures; $junit.testsuites.errors; @($junit.SelectNodes('//testcase[failure]')) | ForEach-Object { $_.name }`
- **C8**, in the same separate invocation:
  `$cov = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml')`, then per file the
  `sourcefile` node whose `name` attribute is the leaf name, with the match count recorded and per-file line
  coverage computed as the count of child `line` elements with `ci` greater than zero over the count of all
  child `line` elements.

EXIT_CODE: 2
ExpectedExitCode: 2

The observed C3 exit code is 2 and equals the expectation. Per the plan's failure-baseline section, the
expectation is the count of failing tests, and the acceptance for this task is the failing-node-set identity
and `errors = 0` rather than the exit code. C7 and C8 ran in their own invocation and exited 0.

Output Summary:

## `testsuites` element attributes

| attribute | value |
| --- | --- |
| `tests` | **4758** |
| `failures` | **2** |
| `errors` | **0** |

Passed count computed as `tests` minus `failures` minus `errors`: **4758 - 2 - 0 = 4756**.

Reconciliation with the C3 console tally, recorded so the two figures are not read as a contradiction. The
console printed `Tests Passed: 4747, Failed: 2, Skipped: 9`. The three console figures sum to 4758, which is
the `tests` attribute. The computed passed count of 4756 is higher than the console's 4747 by exactly the 9
skipped cases, because the plan's stated computation subtracts only failures and errors and the JUnit
`testsuites` element carries no skipped attribute this task reads. Both figures are recorded; 4756 is the
computed value the plan's formula produces and 4747 is the executed-and-passed count.

**`tests` = 4758 is the integer `[P4-T3]` binds to**: that gate requires `tests` to equal this value plus 3,
which is **4761**, being the node count this remediation adds.

## Failing node set — exactly two members

`//testcase[failure]` returned a node count of **2**. The full `name` attribute of each:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Member 1 contains the literal `allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
and sits in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`, which is the wall-clock and
receipt-dependent node the plan's failure-baseline section names first.

Member 2 contains the literal `allows every registered handler for every tool name its own matcher admits`
and is the Codex PreToolUse integration node the plan names second.

The measured set is therefore **exactly** the pair the preamble fixes. `errors` is **0**. No task in this plan
asserts a repository-wide failure count of 0, and none is asserted here.

## The three prd-feature suites

| suite | `tests` attribute | `testcase` nodes | failures |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 25 | **25** | **0** |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | 47 | **47** | **0** |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | **25** | **0** |

The measured node counts are 25, 47, and 25 with zero failures each, which confirms the plan's re-derivation:
the TargetResolution suite declares 21 `It` blocks expanding to 25 nodes, because two of them are
`-ForEach`-bound over a two-row and a four-row array. Its post-change count is therefore 28, since this plan
adds three non-`-ForEach` `It` blocks, and the sibling counts stay at 47 and 25.

## Per-file line coverage

Both figures were read from `artifacts/pester/powershell-coverage.xml` by the C8 procedure. The
`sourcefile` node match count is recorded for each leaf name, and each is exactly **1**, as the plan requires:
`CodeCoverage.Path` registers the two repository hook files and no `claude-customizations` path, so neither
bundled mirror is measured and no duplicate leaf name exists. A match count other than 1 would have halted
this task.

| file | `sourcefile` match count | form used | covered | total | line coverage |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1 | child `line` elements with `ci` > 0 over all child `line` elements | 90 | 99 | **90.91%** |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 1 | child `line` elements with `ci` > 0 over all child `line` elements | 58 | 62 | **93.55%** |

Both are at or above the uniform 85 percent line-coverage threshold in `.claude/rules/quality-tiers.md`.

The `counter` element of `type` `LINE` fallback form was **not** used for either file, because both
`sourcefile` nodes carry child `line` elements.

**No branch-coverage figure is recorded.** Pester measures line and command coverage only, and
`.claude/rules/powershell.md` line 64 states there is no PowerShell branch-coverage gate. The whole-run
console figure `Covered 94.91% / 0%` is command coverage against a zero branch column and is recorded here for
information only, with no threshold attached.

Acceptance: `errors` is 0; the failing node set has exactly two members whose `name` attributes contain the two
literals named in the preamble; the three prd-feature suites report 25, 47, and 25 nodes with zero failures;
and both per-file coverage figures are recorded as numbers at or above 85. Satisfied.
