# Code Review — Issue #513 (Truth-table non-emptiness assertions cannot fail)

- Timestamp: 2026-09-26T23-56
- Reviewer: feature-review agent
- Diff reviewed: `git diff ae8d2ce32c95cf03d55ffb544f2514d83ebfc620 -- tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1`
- File: `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` (391 lines post-edit; 45 insertions, 3 deletions)

## Executive Summary

The diff adds one file-local helper function, `Test-NonVacuousCollection`, to the file's existing top-level `BeforeAll` block, rewrites three non-emptiness assertions to call it, and adds a new `Context 'Non-vacuity floor helper'` block with six `It` cases. No production file is modified.

```powershell
function Test-NonVacuousCollection {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [AllowNull()]
        [object] $Value
    )
    return @($Value | Where-Object { $null -ne $_ }).Count -gt 0
}
```

The null-safe idiom is verified correct for all input categories exercised by the new tests (see Findings Table and Correctness Detail below). The naming follows repository convention, AC-3 and AC-4's specific negative/positive control requirements are satisfied by the diff content itself (verified independently of the evidence artifacts' pass/fail claims), and the change preserves all stated invariants and boundaries. **No blocking or partial code-quality findings were identified.** The Findings Table below is empty because no finding met the bar for a table entry; observations that do not rise to that bar are recorded as non-blocking notes in the narrative sections that follow.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| — | — | — | No findings. | — | — | — |

## Correctness of the Null-Safe Idiom

The helper's core expression is `@($Value | Where-Object { $null -ne $_ }).Count -gt 0`. This is verified correct for all five categories the negative/positive controls exercise:

- `$Value = $null`: piping `$null` into `Where-Object` produces zero pipeline output elements (a documented PowerShell pipeline behavior — a scalar `$null` piped to a pipeline stage does not enumerate as a one-element sequence the way `@($null)` does when applied directly to a scalar). `@()` wraps zero elements, `.Count` is `0`, `0 -gt 0` is `$false`. Correct.
- `$Value = @()`: `Where-Object` over an empty array yields no output; same result, `$false`. Correct.
- `$Value = @($null, $null)`: both elements are filtered out by `{ $null -ne $_ }`; zero elements remain; `$false`. Correct.
- `$Value = @('a')`: one non-null element passes the filter; `Count` is `1`; `1 -gt 0` is `$true`. Correct.
- `$Value = $sample.Keys` (non-empty hashtable): `.Keys` enumerates as a real collection; both keys pass the filter; `$true`. Correct.

This matches the pattern already established in the same file at the pre-existing lines 226-238 (`$separatorFree = @($script:BundledConfig['shared_surfaces'] | Where-Object { -not $_.Contains('/') })`), which spec.md's Root Cause Analysis section cites as the sound precedent. The helper generalizes that precedent into a single named, independently testable predicate rather than duplicating the filter-and-count expression at three call sites — consistent with the general-code-change policy's reusability principle (avoid copy-paste; share behavior via composition or helper methods).

The original defect is confirmed present and distinct: `@($null).Count` wraps a bare scalar `$null` in a one-element array (`@()` applied directly to a scalar, not to a pipeline's output), so `.Count` is `1` and the old `Should -BeGreaterThan 0` assertion passed vacuously. The new sixth `It` case documents this directly: `(@($null).Count -gt 0) | Should -BeTrue` — asserting the legacy expression's defective behavior as a permanent regression canary rather than silently deleting the evidence of the bug. This turns the defect's signature into an assertion that would fail loudly if a future PowerShell version or configuration ever changed `@($null).Count`'s behavior, which would otherwise silently invalidate the historical justification for the fix.

## Naming

- `Test-NonVacuousCollection` uses the approved verb `Test-` (PSScriptAnalyzer-enforced) and a descriptive, non-abbreviated noun. The name accurately describes the returned boolean's meaning ("is this collection non-vacuous," i.e., does it contain at least one non-null element) rather than merely restating its implementation.
- The parameter name `$Value` is generic but appropriate for a general-purpose predicate helper with no domain-specific semantics; `-Value` is a conventional PowerShell parameter name for a single generic input.
- The new `Context` name, `'Non-vacuity floor helper'`, and each `It` name are descriptive and state both the scenario and the expected outcome (e.g., `'returns false for an array of only null elements'`), consistent with `.claude/rules/general-unit-test.md`'s documentation requirement.

## Negative/Positive Control Coverage Against Spec AC-3 and AC-4

spec.md AC-3 requires: `Test-NonVacuousCollection` returns `$false` for `-Value $null`, `-Value @()`, and `-Value @($null, $null)`; returns `$true` for `-Value @('a')` and for a non-empty hashtable's `.Keys` property; none of these read from disk, network, or environment.

Diff verification: all five cases named in AC-3 are present verbatim in the new `Context` block, each as a single-assertion `It` with a literal, in-memory value — no `Get-Content`, `Invoke-WebRequest`, `$env:`, or similar I/O call appears in any of the six new `It` bodies. AC-3 is fully satisfied by the diff's actual content, independent of the evidence artifacts (which additionally show all five passing at `evidence/regression-testing/pass-after-negative-control.2026-09-26T23-39.md`).

spec.md AC-4 (optional, retained) requires a case demonstrating that the legacy expression `@($null).Count -gt 0` evaluates to `$true`. The sixth `It`, `'documents that the legacy expression @($null).Count -gt 0 evaluates to $true'`, is present verbatim in the diff and asserts exactly this. AC-4 is satisfied.

Both AC-3 and AC-4 are satisfied by the diff content itself, not merely by the evidence describing a claimed prior run — a distinction worth stating explicitly, since a code-review pass should verify the assertion exists and is textually correct independent of a separate evidence artifact's claim that it once passed.

## Design Quality

- **Simplicity**: the fix is minimal — one helper function, three call-site rewrites, one new test block. No unnecessary abstraction (e.g., no generic "collection validator" framework) was introduced.
- **Reusability**: the helper is called from all three rewritten floors rather than duplicating the filter-and-count expression three times, which the spec's design-decision section explicitly weighs against the rejected alternative of inline repetition.
- **Separation of concerns**: the helper is pure (no I/O, no side effects); it is defined in the test file's setup block rather than in production code, correctly, since spec.md's scope explicitly excludes any production-file change.
- **Extensibility / API shape**: `[AllowNull()][object] $Value` accepts any input type without constraining callers to a specific collection type, which is appropriate for a file-local test helper with three heterogeneous call sites (`.Keys`, a config array value, and literal test values).

## Boundaries Preserved

The diff does not touch: the pre-existing sound floor at lines 226-238 (`$separatorFree`), the `mandate_reads` checks (confirmed unchanged by `evidence/qa-gates/scope-boundary-mandate-reads.2026-09-26T23-39.md`, byte-for-byte, count 1), the `Disjoint work items` context, or the `BeforeAll` block's `$script:CommittedConfig`/`$script:BundledConfig`/`$script:ConfigPath` construction (visible directly in the diff — the only addition to `BeforeAll` is the new function; no existing line in that block is modified). This matches spec.md's stated boundaries-and-invariants section.

## Non-Blocking Observations

- The rewritten floors use a two-line pipeline form (`Test-NonVacuousCollection -Value <expr> |` / `    Should -BeTrue`) rather than a single line. This is a stylistic choice; PSScriptAnalyzer and the formatter both report no findings and no drift against it (`evidence/qa-gates/final-analyze.2026-09-26T23-39.md`, `evidence/qa-gates/final-format-apply.2026-09-26T23-39.md`), so it is accepted as-is.
- `Test-NonVacuousCollection` has no comment-based help block. The file's existing `Get-ReasonSignature` helper in the same `BeforeAll` block also has no comment-based help, so this is consistent with the file's established local convention rather than a deviation, and PSScriptAnalyzer's settings for this file do not flag its absence (0 findings, matching baseline).
- The helper is file-local (defined in `BeforeAll`, not exported from a module), which is appropriate given spec.md's explicit scope exclusion of any production module change; a shared, exported version was correctly rejected as out of scope for this bug fix.

None of these observations rise to a Findings Table entry: each is either a deliberate, evidence-confirmed design choice or consistent with an established local convention, with no policy violation and no correctness risk.

## Verdict

**No blocking or partial code-quality findings.** The null-safe idiom is correct for all five input categories exercised by the new tests, the naming follows repository convention, both AC-3 and AC-4's specific negative/positive control requirements are satisfied by the diff content itself (verified independently of the evidence artifacts' pass/fail claims), and the change preserves all stated invariants and boundaries.
