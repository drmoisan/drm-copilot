# Fail-Before Evidence — Guard Repository Scan, Assertion A (P1-T5, `[expect-fail]`) — Issue #475

Timestamp: 2026-08-15T19-53

Command: `Invoke-Pester` with `Run.Path = tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `Filter.Tag = 'RepositoryScan'`, executed via `pwsh -NoProfile`.

EXIT_CODE: 1 (non-zero, as required for this `[expect-fail]` task; the harness exits with the Pester failed-test count)

## Why This Failure Is the Expected Outcome

`[P1-T5]` is tagged `[expect-fail]`. The guard lands in Phase 1 with an EMPTY allowlist while every Python invocation site is still present in the guarded tree; those sites are removed across Phases 3, 10, and 11. Assertion A therefore legitimately reports the current invocation sites now, and is not run again until Phase 14. This artifact is the fail-before half of the fail-before/pass-after pair.

Formatting, linting, and the fixture tests are NOT waived by the `[expect-fail]` tag and all passed in the same pass — see the Toolchain State section below.

## Result Summary

- 3 `It`s selected by tag; **2 passed, 1 failed**, 24 not run (the tag-excluded fixtures).
- Pester v5.6.1, duration 1.63 s.

| `It` | Result | Meaning |
| --- | --- | --- |
| enumerates only the two guarded roots and never the bundled mirror | PASS | Scan scope is correct: rooted at `.claude/hooks` and `.claude/lib`, `.claude/lib/bash/**` excluded, zero paths under `extensions/`. |
| reports no Python invocation beyond the allowlist across the guarded tree (**Assertion A**) | **FAIL (expected)** | Reports exactly the 5 known pre-change sites. |
| carries no stale allowlist entry (**Assertion B**) | PASS | Vacuously green over the empty allowlist. |

## Detected Sites — Exactly the Five the Plan Names, and No Others

```
.claude/hooks/enforce-discovery-artifact-gate.ps1:50 [ConstantCommand] in Invoke-DiscoveryValidatorExe
.claude/hooks/validate-discovery-artifact-gate.ps1:53 [ConstantCommand] in Invoke-DiscoveryValidatorExe
.claude/hooks/validate-orchestrator-output.ps1:196 [ConstantCommand] in Invoke-RoutingContractValidation
.claude/lib/orchestrator-state/OrchestratorState.psm1:367 [ConstantCommand] in Test-PythonOrchestratorValidatorAvailable
.claude/lib/orchestrator-state/OrchestratorState.psm1:451 [ConstantCommand] in Invoke-OrchestratorStatePreflight
```

Assertion message: `Expected 0 ... but got 5.`

These match the plan's predicted line numbers exactly (`enforce-discovery-artifact-gate.ps1:50`, `validate-discovery-artifact-gate.ps1:53`, `validate-orchestrator-output.ps1:196`, `OrchestratorState.psm1:367` and `:451`). Each is a `ConstantCommand` finding, i.e. a literal `python` in command position.

## No-False-Positive Confirmation (AC-10 leg)

- **Zero findings in the six incidental-match hooks**, all of which remain byte-unchanged and out of scope: `check-python-test-purity.ps1`, `enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-python-batch-budget.ps1`, `validate-executor-output.ps1`, `validate-feature-review-coverage.ps1`. They contain `python` only in string literals, comments, artifact paths, and agent names.
- **Zero findings for the sibling-script helper-load sites** (carve-out b), all three of them.
- **Zero findings for the 25 `[scriptblock]`-parameter seam invocations** (carve-out a).

## Plan Deviation Recorded: Carve-Out (b) Inventory Was Incomplete (2 sites -> 3)

The plan's `[P1-T2]` text describes carve-out (b) as covering "a dot-source (`.`) invocation of a variable", and states "the two occurrences are `enforce-completion-consistency.ps1:47` and `enforce-parallel-drift-gate.ps1:67`".

The first scan run reported a **sixth** finding the plan did not predict:

```
.claude/hooks/enforce-pr-author-skill.ps1:142 [DynamicInvocation] in <script>
```

Line 142 is `. (Join-Path $PSScriptRoot 'enforce-pr-author-skill.epic-base-branch.ps1')` — the identical sibling-script helper-load pattern, written as an inline expression rather than through an intermediate variable. A repository-wide search (`grep -rn '^\s*\.\s*(' .claude/hooks .claude/lib`) confirms it is the only occurrence of the inline form.

Resolution: carve-out (b) was extended to the same PATTERN in its inline form. The plan's parenthetical "the two occurrences" was an incomplete inventory of a pattern, not a narrowing of the rule. The alternatives were rejected:

- Treating it as a real finding would require modifying `.claude/hooks/enforce-pr-author-skill.ps1`, which the plan never lists as a file to modify and which is not among the six incidental hooks. That would invent scope.
- Leaving it as a finding would make `[P1-T5]`'s stated acceptance ("exactly the five listed findings") unreachable and would make Phase 14 permanently red.

**This does not weaken the guard.** The new predicate `Test-SiblingScriptLoadExpression` is deliberately tight and requires ALL of: the dot-source operator, a parenthesized single `Join-Path` command, an argument that is the `$PSScriptRoot` variable, and a literal argument ending in `.ps1`. A dot-sourced path cannot be a Python interpreter. Three boundary `It`s pin the tightness and all pass:

- `still reports a dot-sourced expression that is not a Join-Path call`
- `still reports a Join-Path load that does not resolve a ps1 sibling`
- `still reports an ampersand-invoked inline sibling-load expression`

After the extension the scan reports exactly 5 findings, satisfying the task's acceptance criterion.

## Second Defect Found and Fixed: `VariablePath.UnqualifiedPath` Is Not a Public Member

While diagnosing why the inline carve-out did not fire, the helper was found to read `$variable.VariablePath.UnqualifiedPath`. That member is **not public** on `System.Management.Automation.VariablePath`; `Get-Member` reports only `DriveName, IsDriveQualified, IsGlobal, IsLocal, IsPrivate, IsScript, IsUnqualified, IsUnscopedVariable, IsVariable, UserPath`. Reading it silently yields an empty string.

Consequences before the fix, both silent:

1. `Get-ScriptBlockParameterName` stored `''` for every `[scriptblock]` parameter, so the name set was `{''}`.
2. In the class-3 branch the invoked variable's name also resolved to `''`, so `Contains('')` returned `$true` and **every** `&`-invoked variable was carved out — including all 25 real sites — for the wrong reason. The guard would have appeared green while performing no dynamic-invocation checking at all.

Fix: new `Get-VariableName` helper reads `UserPath` and strips any scope qualifier itself; all three call sites now use it. A regression fixture pins the behavior — the class-3 fixture now declares BOTH a `[string] $ToolPath` and a real `[scriptblock] $Invoker` in the same file and asserts exactly one finding naming `ToolPath`. Under the defect that fixture reports zero findings and fails.

This is why the scan now reports 5 rather than 6: the sixth was resolved by the carve-out extension, and the 25 seam sites are now carved out by genuine name matching rather than by the empty-string bug.

## Toolchain State (not waived by `[expect-fail]`)

- `mcp__drm-copilot__run_poshqc_format` (`scan_folders: tests/scripts/claude-runtime`): clean and idempotent.
- `mcp__drm-copilot__run_poshqc_analyze` (same narrowing): **0 findings**.
- Fixture suite (`Filter.ExcludeTag = 'RepositoryScan'`): **24 passed, 0 failed** — see `guard-fixtures.2026-08-15T19-31.md`.
- File sizes at or under the 500-line cap: helper 500, suite 500.

## Pass-After Reference

The pass-after half of this pair is produced in Phase 14, after the last Python invocation site is removed in Phase 11 and the bundle mirror lands in Phase 12. Phases 4 through 13 must keep narrowing `scan_folders` so this legitimately-red scan is not pulled into an unrelated verification.
