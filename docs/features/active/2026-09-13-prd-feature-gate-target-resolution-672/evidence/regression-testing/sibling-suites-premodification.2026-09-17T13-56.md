# Sibling suites with the modelled derivation in place, hook still unmodified

Timestamp: 2026-09-17T13-56

Task: `[P1-T6]` of `remediation-plan.2026-09-17T12-29.md`

What this task establishes: the `[P1-T4]` and `[P1-T5]` amendments reproduce today's composition behaviour
exactly. Phase 1 edits tests only, so the hook is still the pre-change hook and the pre-filter is still in
place. A failure here would mean the modelled result changed delivered behaviour, which must be corrected
before Phase 2 begins rather than deferred.

Command, **C4** run once per suite:
`Import-Module Pester -MinimumVersion 5.0.0 -Force; $r = Invoke-Pester -Path '<suite path>' -PassThru; $r.TotalCount; $r.PassedCount; $r.FailedCount`

No settings file is supplied, so neither run overwrote `artifacts/pester/pester-junit.xml` and neither
recomputed coverage. The `[P0-T6]` baseline reports remain the ones on disk.

EXIT_CODE: 0

Output Summary:

| suite | `TotalCount` | `PassedCount` | `FailedCount` | expected |
| --- | --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1` | **47** | **47** | **0** | 47 total, 0 failed |
| `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | **25** | **25** | **0** | 25 total, 0 failed |

No failing test was reported by either run, so no failure name or message is recorded.

## What the result confirms

1. **The Describe-level `BeforeAll` mock is observed by the contained cases on this Pester version.** The
   installed version is 5.6.1. Had the mock not been observed, the cases would have reached the real
   `Resolve-WorktreeCallTarget`; that would not have changed the outcome against the *pre-change* hook,
   because the pre-filter still short-circuits before the call, but the mock's registration is what makes the
   suites safe once Phase 2 removes that pre-filter. The alternative `BeforeEach` placement permitted by
   `[P1-T4]` and `[P1-T5]` was therefore not required and was not used.
2. **The node counts are unchanged at 47 and 25.** The amendments add a mock inside an existing `BeforeAll`
   and declare no new `It`, so the counts must match the `[P0-T6]` baseline figures of 47 and 25 exactly.
   They do.
3. **No case in either suite changed outcome.** Both suites were at 0 failures in the `[P0-T6]` baseline and
   remain at 0 failures here.
4. **The no-external-dependency rule in `.claude/rules/general-unit-test.md` is preserved.** The modelled
   `NoTarget` result is what keeps these cases from reaching the real derivation and the real filesystem once
   the pre-filter is gone.

Acceptance: 47 total with 0 failed for the first suite and 25 total with 0 failed for the second. Satisfied.
