# Fail-before evidence for the remediation regression rows

Timestamp: 2026-09-17T13-56

Task: `[P1-T7]` `[expect-fail]` of `remediation-plan.2026-09-17T12-29.md`

This is the fail-before half of a fail-before / pass-after pair. Phase 1 edits tests only, so this run is
against the **unmodified** hook, with the absolutely-placed-token pre-filter at
`.claude/hooks/enforce-prd-feature-before-planner.ps1` lines 242-245 still in place. A failing run is the
expected outcome for this task and for this task only. The pass-after half is `[P2-T8]`.

Command, **C4** against the TargetResolution suite:
`Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Invoke-Pester -Path 'tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1' -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`

EXIT_CODE: 0
ExpectedExitCode: 0

`Invoke-Pester -PassThru` without a settings file does not set `Run.Exit`, so the host exits 0 and the failure
signal is carried by `FailedCount` on the result object rather than by the process exit code. No settings file
was supplied, so this run overwrote neither `artifacts/pester/pester-junit.xml` nor the coverage report.

Output Summary:

## Counts

| metric | value | expected |
| --- | --- | --- |
| `TotalCount` | **28** | 28 |
| `PassedCount` | **24** | 24 |
| `FailedCount` | **4** | exactly 4 |

The node count of 28 confirms the plan's derivation: the suite declared 21 `It` blocks expanding to 25 nodes
at the `[P0-T6]` baseline, because `allows an absolute path to the target feature folder` is `-ForEach`-bound
over a two-row array and `resolves the required document set for each work mode` over a four-row array. This
task adds three non-`-ForEach` `It` blocks and re-specifies a fourth in place, so 25 + 3 = **28**.

## The four failing identifiers, with verbatim failure messages

All four are exactly the identifiers the plan fixes, and no fifth identifier failed. A fifth would have meant
an amendment in `[P1-T2]` or `[P1-T3]` changed delivered behaviour; that condition did not arise, which is
what makes the "exactly four failures" assertion a real discriminator rather than a tautology.

**1. `allows a repo-relative citation placed in the item worktree`**
Full path: `enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.allows a repo-relative citation placed in the item worktree`

```
Expected strings to be the same, but they were different. | Expected length: 5 | Actual length:   4 | Strings differ at index 0. | Expected: 'allow' | But was:  'deny' |            ^
```

This is a **decision assertion** failure: the row asserts `allow` and the pre-change hook returns `deny`. It
is not a parameter-binding error. This is the false denial criterion 10 names, reproduced in the repo-relative
form the originating run used.

**2. `denies with the ambiguity reason when a repo-relative citation places in no worktree`**
Full path: `enforce-prd-feature-before-planner.ps1 target resolution.target resolution matrix.denies with the ambiguity reason when a repo-relative citation places in no worktree`

```
Expected like wildcard '*TARGET_WORKTREE_AMBIGUOUS*' to match 'PRD_FEATURE_BLOCKED: resolved feature folder 'docs/features/active/2026-09-13-synthetic-target-672', but its work mode could not be determined from 'docs/features/active/2026-09-13-synthetic-target-672/issue.md' (the '- Work Mode:' marker is absent, unreadable, or unrecognized). Confirm that is the intended feature folder, then add or correct the '- Work Mode:' marker in that file so the prerequisite set can be derived.', but it did not match.
```

This is a **reason assertion** failure, not a parameter-binding error, and the observed reason is the precise
defect criterion 6 names: because the pre-filter returns `$null`, the decision falls through to the
marker-is-broken branch and prescribes editing `- Work Mode:` in an `issue.md` that does not exist under any
resolved target root. The remedy is misleading in exactly the way criterion 6 forbids.

The two failure messages above are the only form of fail-before proof that rules out a vacuous pass: each
shows the hook producing a specific wrong *outcome*, rather than the case failing to bind a parameter or to
resolve a command.

**3. `hands a repo-relative citation carrying a branch signal to the derivation`**
Full path: `enforce-prd-feature-before-planner.ps1 target resolution.call-target derivation seam.hands a repo-relative citation carrying a branch signal to the derivation`

```
Expected like wildcard '*docs/features/active/2026-09-13-synthetic-target-672*' to match $null, but it did not match.
```

The derivation returned `$null` because the pre-filter short-circuited before `Resolve-WorktreeCallTarget` was
reached, so the mocked result was never produced. This is the zero-invocation failure against an expected
count of one that the plan predicts for identifiers 3 and 4.

**4. `hands a repo-relative citation to the derivation`**
Full path: `enforce-prd-feature-before-planner.ps1 target resolution.call-target derivation seam.hands a repo-relative citation to the derivation`

```
Expected 'NoTarget', but got $null.
```

Same mechanism as identifier 3. This identifier replaces the delivered `It` named
`derives nothing from a call that cites no absolutely-placed token`, whose assertion the selected option
inverts. That delivered name was removed in the same edit, so the suite now carries no case asserting the
pre-filter's behaviour.

## Cases deliberately not amended, and their results

- `derives nothing from a call whose text is empty` **passed**. The empty-text guard at hook lines 238-240
  survives the Phase 2 edit, so this case keeps asserting a zero invocation count and must keep passing. It
  was not amended.
- `allows when the modelled cwd is the item worktree` **passed**, as `[P1-T2]` requires. The modelled root and
  the session root coincide, so the hook keeps the bare repo-relative probe spelling and the row's outcome is
  unchanged. No invocation-count assertion was added to this row: the derivation is not called at all against
  the unmodified hook, so a `Should -Invoke ... -Times 1 -Exactly` here would have made this row a fifth
  failure and contradicted `[P1-T2]`'s own acceptance.
- `denies rather than selecting the earliest candidate on an unresolved tie` **passed**, as `[P1-T3]`
  requires, including its new `cites 2 feature folders` substring assertion. That substring is the literal the
  hook composes at `.claude/hooks/enforce-prd-feature-before-planner.ps1` line 322, re-derived against the
  tree in this phase: the line reads
  `Get-PrdFeatureAmbiguityDecision -Detail ("the call cites $($candidates.Count) feature folders ($($candidates -join ', ')) and no derived target chooses between them")`,
  which renders `cites 2 feature folders` for a two-candidate prompt.

## Header-comment correction

The suite's own header recorded sibling line counts that no longer hold. All three required counts:

| token | pre-change count | post-change count | required |
| --- | --- | --- | --- |
| `measured 431` | **1** | **0** | 0 against a pre-change count of 1 |
| `measured 419` | **1** | **0** | 0 against a pre-change count of 1 |
| `both sibling suites sit within sixty lines of the cap` | **0** | **1** | exactly 1 |

The two pre-change counts were measured against the baseline blob with
`git show 1b150689c2d6bbda848ae10ec92e4ccc018a5560:tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`,
which also confirms the pre-change physical line count of **454**.

The replacement is line-for-line — three lines replaced by three lines — so it consumes none of the line
budget. The first replacement line is, on a line of its own,
`    regression guards: both sibling suites sit within sixty lines of the cap, and`, and the remaining two
state that the measured counts live in this feature's evidence ledger under the stem
`remediation-file-size-ledger` rather than being restated in the comment. Carrying a ledger reference rather
than fresh integers is what stops the comment going stale again on the next edit to either sibling.

The claim the replacement makes is true as measured: the siblings are 445 and 453 lines before the Phase 1
amendment and 446 and 454 after it, so both sit within sixty lines of the 500-line cap on both sides of the
amendment.

## Line budget — the reclaim performed in this task

The suite measured 454 physical lines before Phase 1 and the cap in `.claude/rules/general-code-change.md` is
500, leaving 46 lines for `[P1-T2]`, `[P1-T3]`, and this task.

A first pass of this task measured **504** physical lines, which is 4 lines over the cap. The overage is
recorded here rather than absorbed silently. It was resolved **without trimming any assertion**, by applying
two directions the plan already states:

1. Two mocks in `allows a repo-relative citation placed in the item worktree` were written as three-line
   blocks and were rewritten to the **single-line `Mock -CommandName ... -MockWith { ... }` form** that
   `[P1-T7]` mandates for exactly this purpose. Reclaimed: 4 lines.
2. The explanatory comment added by `[P1-T3]` was condensed from three lines to two. Reclaimed: 1 line. No
   assertion, mock, or payload was touched.

Post-reclaim measurement: **499** physical lines, one line under the cap. No assertion was weakened, removed,
or shortened at any point; the reclaim came from statement formatting and one comment only. The re-run after
the reclaim reproduced the same counts — 28 total, 24 passed, 4 failed — and the same four identifiers with
the same four messages, which confirms the reclaim was behaviour-neutral.

Acceptance: `TotalCount` is 28, `FailedCount` is exactly 4, the four failing identifiers are exactly the four
named in the plan's preamble, and the recorded messages show identifiers 1 and 2 failing on a decision or
reason assertion rather than on a parameter-binding error. Satisfied.
