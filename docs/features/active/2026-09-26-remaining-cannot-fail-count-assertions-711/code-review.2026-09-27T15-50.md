# Code Review — Issue #711 (remaining-cannot-fail-count-assertions)

- Timestamp: 2026-09-27T15-50
- Branch: `bug/remaining-cannot-fail-count-assertions-711`
- Base: `origin/main` at `bd4284c57be52d222eec3983671fc7e444f9a88b`
- Scope: 4 modified test files, no production files

## Summary of Changes Reviewed

```
tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1        | 2 +-
tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1   | 4 ++--
tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 2 +-
tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1             | 9 ++++++++-
```

Five same-line assertion edits plus one new `Context`/`It` documentation pair.

## Correctness

### AC-1 — `BlastRadius.TruthTable.Tests.ps1`

```diff
-            $entries.Count | Should -BeGreaterThan 0
+            Test-NonVacuousCollection -Value $entries | Should -BeTrue
```

`Test-NonVacuousCollection` is a pre-existing helper (added by issue #513/PR #702, defined at line 49 of the same file) already reused at four other call sites in this file. Its body — `return @($Value | Where-Object { $null -ne $_ }).Count -gt 0` — correctly returns `$false` for `$null`, `@()`, and all-null collections, and `$true` for any collection with at least one non-null element. This is the correct fix: it reuses an existing, already-tested abstraction rather than introducing new logic, consistent with the repository's reusability principle (`.claude/rules/general-code-change.md`).

### AC-2/AC-3/AC-4 — inline filtered form

```diff
-@($files).Count | Should -BeGreaterThan 0
+@($files | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
```

(and the equivalent for `$errors` at two sites in `DiscoveryValidation.Tests.ps1`). This same-line pattern is already used elsewhere in the codebase (`BlastRadius.TruthTable.Tests.ps1:253`, `codex-pretooluse-integration.Tests.ps1:134` pre-change), so its formatting and PSScriptAnalyzer acceptance were already established before this change. Verified by direct inspection: the three producers (`Get-GuardedPowerShellFile`, `Get-DiscoveryProfileValidationError`, `Get-DiscoverySchemaArtifactValidationError`) all use `return , $x.ToArray()`, so these three sites were not exploitable as a `$null`-collapsing defect prior to this change, but the new form still hardens them uniformly and costs nothing (same-line, no behavior change for real data). This is a defensible design choice (spec.md Decision D1, Option B) — closing the textual defect class uniformly is simpler to reason about for a future reader than leaving three sites "sound but different-looking" from the two genuinely exploitable ones.

### AC-5 — assertion edit plus new documentation test

```diff
-@($script:Registrations).Count | Should -BeGreaterThan 0
+@($script:Registrations | Where-Object { $null -ne $_ }).Count | Should -BeGreaterThan 0
```

`Get-CodexPreToolUseRegistration` (line 55) returns `$registrations.ToArray()` without the leading comma used by the other three producers; a zero-registration parse collapses to `$null` on assignment, which is the asymmetry the spec identifies and which this review confirmed by direct inspection of the producer body. The fix correctly discriminates the zero-registration case.

The new documentation test:

```powershell
Context 'Non-vacuity floor for the registration count' {
    It 'documents that the legacy expression @($null).Count -gt 0 evaluates to $true while the filtered form is $false' {
        (@($null).Count -gt 0) | Should -BeTrue
        (@($null | Where-Object { $null -ne $_ }).Count -gt 0) | Should -BeFalse
    }
}
```

is placed as a sibling `Context` block appended after the existing final `It` in the `Describe` block, mirroring the "legacy-expression documentation" pattern #513 established in `BlastRadius.TruthTable.Tests.ps1` at line 326 (per spec.md D4). The test name and body clearly document the old-vs-new form distinction; both assertions are self-contained literals with no external dependency, satisfying independence, isolation, and determinism. This is a correct and minimal addition.

## Best-Practices Assessment

- **Naming**: no new function names introduced; the one new `It`/`Context` pair uses descriptive, sentence-style names consistent with the surrounding suite's convention.
- **Simplicity**: every edit is the smallest possible change (same line, no restructuring); no new abstraction was introduced where an existing one (AC-1's helper) or an already-proven pattern (AC-2/3/4/5's inline filter) could be reused.
- **File size limit**: all four files remain at or under 500 lines after the edit (391/500/476/210), verified directly via `evidence/qa-gates/final-line-count-invariant.2026-09-27T16-35.md` and cross-checked by this review's own line-length reads of the four edited lines.
- **No production code touched**: confirmed via `git diff origin/main...HEAD --stat -- .claude .codex scripts`, which returned no output.
- **Test independence/determinism**: all five edits and the one new test operate on in-memory PowerShell literals or already-loaded fixture data; no network, filesystem temp files, or wall-clock dependency is introduced.
- **AAA structure**: existing `Arrange`/`Act`/`Assert` comment structure in each modified `It` block is preserved; the new `It` has no distinct arrange/act phases (it evaluates two static literal expressions), which is appropriate for a documentation-only test of language semantics.

## Design Choices Worth Noting (not defects)

- Decision D1 (spec.md) — applying the filtered form uniformly to all five sites even though three (AC-2/3/4) are not currently exploitable is a defense-in-depth choice. This trades a small amount of "unnecessary" code churn for uniformity and resilience against a future change to the producer's `return , $x.ToArray()` contract (explicitly reasoned in spec.md's Risks section). This is a reasonable, disclosed trade-off, not a code-quality issue.
- Decision D5 — `Get-CodexPreToolUseRegistration`'s missing leading comma (root cause of AC-5's producer-side asymmetry) is deliberately left unfixed, following #513's own precedent of touching only assertion lines within a "Low"-severity fix's scope. This is disclosed as a follow-up candidate in spec.md's Rollout & Follow-up section, not silently left as unaddressed technical debt.

## Toolchain Evidence

- Format (`mcp__drm-copilot__run_poshqc_format`): pre/post SHA-256 hashes of all four files are identical (`evidence/qa-gates/format-4-files.2026-09-27T16-20.md`), confirming no formatting drift.
- Analyze (`mcp__drm-copilot__run_poshqc_analyze`): call returned without raising; `Invoke-PoshQCAnalyze` throws on any PSScriptAnalyzer finding, so a non-raising return is evidence of zero findings (`evidence/qa-gates/analyze-4-files.2026-09-27T16-20.md`).
- Test (`Invoke-Pester`, run directly via `pwsh` rather than the MCP test tool — consistent with this repository's documented preference to avoid `mcp__drm-copilot__run_poshqc_test`'s unreliable output): per-file and per-directory baseline-relative comparisons all show `FailedCount=0` with `TotalCount` deltas matching the expected `+0`/`+1` exactly (`evidence/regression-testing/final-per-file-pester-and-ac6-comparison.2026-09-27T16-30.md`, `evidence/regression-testing/final-per-directory-pester.2026-09-27T16-35.md`).

This review was unable to independently re-run `pwsh`/PSScriptAnalyzer directly (the worktree-isolation guard in this environment blocks direct `pwsh` invocation from the Bash tool), so the format/analyze verdicts rely on the MCP call's evidenced return value plus the hash-identity check, which is a reasonable substitute given the documented behavior of `Invoke-PoshQCAnalyze` (throw-on-finding).

## Findings

No Major or Blocking findings. No enforcement-hook bypass risk (no `.claude/hooks`, `.codex/hooks`, or `scripts` file is touched).

**Minor (non-blocking)**: `evidence/baseline/phase0-instructions-read.2026-09-27T15-20.md` omits `Command:`/`EXIT_CODE:` fields (it documents a reading checklist, not a command execution); no action required.

## Overall Code-Review Verdict

**PASS.** All five edits are correct, minimal, and consistent with existing patterns in the codebase. The one new test is well-placed, well-named, and deterministic. No production code was touched. No enforcement-hook bypass exists.

**Blocking finding count: 0.**
