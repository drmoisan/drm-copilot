# The three prd-feature suites against the changed hook — pass-after evidence

Timestamp: 2026-09-17T13-56

Task: `[P2-T8]` of `remediation-plan.2026-09-17T12-29.md`

This is the **pass-after** half of the fail-before / pass-after pair whose fail-before half is
`[P1-T7]`, recorded at
`docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/regression-testing/fail-before-remediation.2026-09-17T13-56.md`.
The suites are byte-identical to the Phase 1 versions; the only change between the two runs is the Phase 2
edit to the hook.

Command, **C4** run once per suite:
`Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Invoke-Pester -Path '<suite path>' -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`

No settings file is supplied, so no run overwrote `artifacts/pester/pester-junit.xml` and none recomputed
coverage. The `[P0-T6]` baseline reports remain the ones on disk until `[P4-T3]` replaces them.

EXIT_CODE: 0

Output Summary:

## Counts

| suite | `TotalCount` | `PassedCount` | `FailedCount` | expected |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | **28** | **28** | **0** | 28 total, 0 failed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | **47** | **47** | **0** | 47 total, 0 failed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | **25** | **25** | **0** | 25 total, 0 failed |

No failing test was reported by any of the three runs.

## The fail-before / pass-after transition, named per identifier

The four identifiers that failed in `[P1-T7]` against the unmodified hook all pass here against the changed
hook. Each matched exactly **one** node, as the plan's test-count derivation requires, since none is
`-ForEach`-bound:

| # | identifier | `[P1-T7]` result, unmodified hook | `[P2-T8]` result, changed hook | nodes matched |
| --- | --- | --- | --- | --- |
| 1 | `allows a repo-relative citation placed in the item worktree` | **Failed** — returned `deny` where `allow` was asserted | **Passed** | 1 |
| 2 | `denies with the ambiguity reason when a repo-relative citation places in no worktree` | **Failed** — reason was the marker-is-broken reason, not the ambiguity code | **Passed** | 1 |
| 3 | `hands a repo-relative citation carrying a branch signal to the derivation` | **Failed** — derivation returned `$null` on a zero invocation count | **Passed** | 1 |
| 4 | `hands a repo-relative citation to the derivation` | **Failed** — derivation returned `$null` on a zero invocation count | **Passed** | 1 |

The transition is attributable to exactly one cause: `[P2-T2]` deleted the pre-filter, so the assembled text
now reaches `Resolve-WorktreeCallTarget` unconditionally. Identifiers 3 and 4 observe that directly through
their `Should -Invoke -CommandName Resolve-WorktreeCallTarget -Times 1 -Exactly` assertions. Identifiers 1 and
2 observe its consequences: the probe is now anchored to the derived target root, so a repo-relative citation
placed in the item worktree allows; and a citation that places in no worktree yields `Ambiguous`, which the
hook denies before any probe, so the misleading marker-is-broken remedy is unreachable on that path.

## The two amended identifiers, and the case deliberately left unamended

| identifier | `[P1-T7]` result | `[P2-T8]` result | nodes |
| --- | --- | --- | --- |
| `allows when the modelled cwd is the item worktree` | Passed | **Passed** | 1 |
| `denies rather than selecting the earliest candidate on an unresolved tie` | Passed | **Passed** | 1 |
| `derives nothing from a call whose text is empty` | Passed | **Passed** | 1 |

The two amended identifiers pass on both sides of the change, which is what made the "exactly four failures"
assertion in `[P1-T7]` a real discriminator rather than a tautology: had either amendment altered delivered
behaviour, it would have appeared as a fifth failure there.

`derives nothing from a call whose text is empty` was deliberately not amended and still passes with its
zero-invocation assertion, which confirms the empty-text guard at the hook survived the Phase 2 edit
byte-unmodified, as `[P2-T2]` requires.

## Sibling-suite node counts are unchanged

47 and 25, matching both the `[P0-T6]` baseline and the `[P1-T6]` measurement. The Phase 1 amendments added a
mock inside an existing `BeforeAll` and declared no new `It`, and Phase 2 changed no test file, so the counts
must not move. They did not. The modelled `NoTarget` result continues to keep those cases from reaching the
real derivation now that the pre-filter no longer short-circuits ahead of it, which is what preserves both
their outcomes and the no-external-dependency rule in `.claude/rules/general-unit-test.md`.

Acceptance: 28 total with 0 failed for the TargetResolution suite, 47 total with 0 failed for the parent
suite, 25 total with 0 failed for the FolderResolution suite, and the four `[P1-T7]` identifiers named with
their post-change results. Satisfied.
