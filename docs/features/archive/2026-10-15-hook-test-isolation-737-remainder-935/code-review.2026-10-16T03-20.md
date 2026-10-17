# Code Review — Issue #935 (hook-test-isolation-737-remainder)

**Branch:** `bug/hook-test-isolation-737-remainder-935`
**Base:** `main`; merge-base `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964`
**Head reviewed:** `79386619519d99cb0fed56b5f4b41e42837903d3`
**Files reviewed:** the 18 PowerShell files under `tests/scripts/` in `git diff origin/main...HEAD` (7 created, 11 edited); feature-folder Markdown read for context

## Total Blocking Findings: 0

## Executive Summary

The change is confined to the epic-state isolation guard and four test-file splits. No production hook, library, policy or configuration file changed.

- **F-1/F-2 reapply** (`EpicStateIsolation.Helpers.ps1`): `Test-EpicStateIsolationConditionalAncestor` makes a command under `if`/`switch`/loop/`try`/`trap` count as nested unless it sits in a single-clause `if (Get-Command <its target>)`. `Get-EpicStateIsolationHookDotSource` no longer falls back to the first dot-source and returns `$null`. `Get-EpicStateIsolationFinding` emits `no dot-source loads the hook` unless the block is helper-only (R2), in which case the last helper dot-source is the ordering anchor. The logic matches spec `## Proposed Fix` item 1.
- **R1** (`EpicStateIsolation.HookReference.Helpers.ps1`): `Test-EpicStateIsolationHookReference` recognizes literal, expandable `"$var/<leaf>"`, `Join-Path` positional and `-ChildPath`, and `hooks`-segment forms, with one level of variable binding through `Test-EpicStateIsolationHooksRootBinding` (regex `(^|[\\/])hooks[\\/]?$`).
- **F-3**: `Get-EpicStateIsolationHookReference` enumerates load positions and returns `Name`/`Form`/`Root` records; `Get-EpicStateProcessSpawningHook` now returns the union with variable-built loads; `Get-EpicStateLoadedSourceClosure` is unchanged (line 158 still seeds only from `Get-EpicStateHookLiteral`).
- **I-3 splits**: this review compared removed lines with the new files. Every removed non-blank line appears verbatim in its target, except the three Codex helper functions, which differ only by removed indentation after leaving the `BeforeAll`. Each split suite has its own `BeforeAll` with the baseline mocks and one `baseline mock interception probe` row.

No blocking defect was found. Eight non-blocking findings concern duplication, an undeclared load-order dependency, report-only false-positive surface, and readability.

## Findings Table

Blocking findings: 0. Non-blocking findings: 8.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (CR-N1) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` | header lines 6-9; `Get-EpicStateProcessSpawningHook` line 236; `Get-EpicStateVariableHookLoad` line 250 | Both functions now call `Get-EpicStateIsolationHookReference`, which is defined in `EpicStateIsolation.HookReference.Helpers.ps1` and loaded only through `EpicStateIsolation.Helpers.ps1`. The header does not state this load-order dependency. A future consumer that dot-sources only the Discovery helper receives `CommandNotFoundException` from `Get-EpicStateProcessSpawningHook`, which was previously self-contained. | Add one sentence to the header naming the dependency (as `EpicStateIsolation.Compliance.Helpers.ps1` line 6 does), or dot-source the HookReference helper from the Discovery helper. | Undeclared cross-file dependencies fail at run time rather than at load. Both current consumers (Discovery and HookReference suites) load all three helpers, so there is no present failure. | `git diff origin/main...HEAD -- tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`; Grep of consumers: only the two suites dot-source the Discovery helper. |
| Low (CR-N2) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | lines 21, 105, 233, 272 (`$isLiteral`); 170, 270 (leaf regex); 112, 183, 271 (hooks-root regex); 173, 295 (expandable regex); 46-71 vs 73-95 | The string-literal predicate is defined four times, the leaf and hooks-root regexes and the expandable-string regex are repeated, and `Test-EpicStateIsolationVariableBoundToHook` repeats the assignment and hashtable traversal that `Get-EpicStateIsolationVariableBinding` now provides. | Hoist the predicate and patterns to file-level constants (or small pure functions) and express `Test-EpicStateIsolationVariableBoundToHook` through `Get-EpicStateIsolationVariableBinding`. | Reusability principle in `general-code-change.md`; a later change to one copy of a pattern can drift from the others. | File read at HEAD. |
| Low (CR-N3) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | lines 345-352 (`Get-EpicStateIsolationHookReference`); lines 126-129 (`Get-EpicStateIsolationJoinPathPart`) | Every non-parameter element of an `Import-Module` or process-start command is treated as a load position, so the separate-token value of an unrecognized parameter (for example `-WorkingDirectory $dir`) is scanned as a load. `Get-EpicStateIsolationJoinPathPart` likewise treats the separate-token value of an unrecognized `Join-Path` parameter as positional. | Skip the following element when an unrecognized parameter has no attached argument and the next element is not a parameter. | Report-only (D3), so the effect is limited to possible extra `REPORT-VARIABLE-LOAD` lines; D3 already accepts known report false positives. Worth fixing before F-3 enforcement uses the report. | File read at HEAD; spec D3. |
| Low (CR-N4) | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` | lines 164-185 | `AC-5b variable-built hook-load report <Surface>` and `F-3 non-vacuity <Surface> ...` each enumerate and read every discovered suite of the surface, so each suite file is read twice more per surface. | Collect the lines once per surface (for example in a `BeforeAll` keyed by surface) and have both rows read the collected set. | The parse memo avoids a second parse, but the reader still reads each file; the Discovery suite already scans the full population for other rows. | Diff hunk at line 161. |
| Info (CR-N5) | `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` | lines 110, 112 | `Test-EpicStateIsolationConditionalAncestor` has a single comment line of about 230 characters and a one-line `param()` with two typed mandatory parameters. | Wrap the comment and split the parameter block across lines, consistent with neighbouring functions. | Readability; the text was recovered verbatim from `4e8d9f92d`, so the recovery is faithful. | Diff hunk at line 93. |
| Info (CR-N6) | Branches, Predicate and legacy guard suites | each recovered `$script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'` fixture line | The recovered binding lines sit at column 0 inside indented here-string fixtures. | Optional: indent to match the surrounding fixture text. | Cosmetic only; fixtures are parsed text and the AST is unaffected. | Diffs of the three suites. |
| Info (CR-N7) | `enforce-prd-feature-before-planner.CallTarget.Tests.ps1`; `enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` | Describe titles (line 22; line 16) | The split suites reuse the original Describe titles, so `baseline mock interception probe` has the same Pester full name in the original and the split file; the Selectors Describe title names #539 while it holds the #671 and #663 Contexts. | No change required for this item. If a later edit renames, keep test names stable for AC-14..AC-16 counting. | `test-name-uniqueness.Tests.ps1` checks sibling collisions within one file, and D-JUNIT attributes testcases by `classname` file path, so there is no functional collision. The titles preserve "unchanged test names". | Grep of Describe lines; `test-name-uniqueness.Tests.ps1` lines 281-385. |
| Info (CR-N8) | `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` | line 292 | `$value.Substring(0, $match.Index + 5)` uses the literal length of `hooks` as a bare number. | Use `'hooks'.Length` or a named constant. | Readability of the root derivation. | File read at HEAD. |

## Correctness Notes (no finding)

- `Get-EpicStateIsolationDirectCommand` stops the ancestor walk at the block (`ReferenceEquals($parent, $Block)`), so a guard outside the `BeforeAll` does not mark commands nested.
- `Test-EpicStateIsolationConditionalAncestor` returns `$true` for any non-`Mock`/non-`Register-EpicStateBaselineMock` command under an `if`, so a dot-source or `Import-Module` inside a guard is also excluded from the direct commands. This matches the recovered #903 behavior and the R2 fixtures.
- R2 requires every dot-source to be a `.Helpers.ps1` load (case-sensitive `-cmatch`) and no identified hook; a mixed block still yields the F-2 finding (row R2 (d)).
- `Get-EpicStateVariableHookLoad` excludes names already reported as literals, so `Get-EpicStateProcessSpawningHook` returns a distinct union.
- Spec risk "R1 can move the ordering anchor in a block holding both a root-variable hook load and a later literal load" remains as recorded; step (i) picks the first identified dot-source in source order.

## Positive Observations

- Splits were performed before edits so no file exceeded 500 lines at any commit; all 18 files are at or below 428 lines.
- Every new row uses in-memory fixtures, and fixture hook names were checked against both hook trees.
- Fail-before dossiers state why a failing CI run on intermediate commits was not obtainable and give a code-path argument; the AC-6 record proves code identity with `git diff --stat`.
- The report-only design for F-3 keeps enforcement out of this item and records the follow-up input (`AC-5b`).
