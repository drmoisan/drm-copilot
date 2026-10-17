# Code Review — Issue #935 (hook-test-isolation-737-remainder), cycle R4 confirming pre-push full-diff review

**Branch:** `bug/hook-test-isolation-737-remainder-935-r4` (no PR yet)
**Base:** `main`; merge-base `7516050be5d03293f8964eb54e7bea9951d726ab`; `origin/main` is at `87f3d8996745029d93b16c19751e5a55dca1b919`
**Head reviewed:** `ae0d3a03b8c26879bb7ab67be37a149930f7669a` (local, not pushed) plus the uncommitted P6-T30 check-off in `remediation-plan.2026-10-16T20-56.md`
**Files reviewed:**
- The nine PowerShell files of `git diff origin/main...HEAD -- tests/`, read by full branch diff and by the Phase 6 diff `git diff 009f7d0c7 HEAD -- tests`; read in full: `enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`, `EpicStateIsolation.Discovery.Helpers.ps1`.
- `EpicStateIsolation.HookReference.Helpers.ps1` pattern table (to confirm that the TEST-2 rows reach the braced `ExpandableLeaf` alternative), the `EpicStateIsolation.Helpers.ps1` header, and `Get-EpicStateProbeFinding` in `EpicStateIsolation.Compliance.Helpers.ps1`.
- `spec.md`, `issue.md`, `plan.2026-10-15T17-44.md` and `remediation-plan.2026-10-16T20-56.md` diffs, and every `r4-rf-*` evidence record.

## Total Blocking Findings: 0

The code changes carry no blocking finding. The table below lists 4 non-blocking findings in code; the feature audit lists 4 more in documents and evidence. The operator ruling requires every one to be fixed before the single push, so each row has an exact location and a concrete fix.

## Executive Summary

- CR-G1: the per-surface `try`/`catch` in the Describe BeforeAll records the message in `$script:VariableLoadError[$surface]` and sets an empty report; the `AC-5b` row asserts `Should -BeNullOrEmpty` on the recorded message, so the assertion is no longer vacuous and a build failure is confined to the rows of that surface. The catch does not swallow the error: it propagates the message into a row assertion. Spec D7 records the resulting `F-3 non-vacuity` behaviour.
- CR-G3: `$script:EpicStateParseCache` is now `Dictionary[string, object]` with `StringComparer.Ordinal`; `ContainsKey`, the indexer and `Count` are used unchanged. The `[string]` parameter of `Get-EpicStateParsedSource` converts `$null` to an empty string, so no null key reaches the dictionary. The new row parses both texts within the row and so fails on the hashtable regardless of row order; the fail-before record shows exactly that row failing.
- CR-G2: `Get-EpicStateProbeFinding` returns `$state.Error` before calling `Test-EpicStateProbeCalledFromIt`; the Memo row covers the missing-suite case with `-Seam`.
- Memo suite: header, BeforeAll and fixtures are in-memory; every row is self-contained (distinct census paths, a reader per row, or fresh memos after the reset row). The exact read count of 3 in `PERF closure memo reads each file once for a repeated closure` matches the walk (`.claude/hooks/a.ps1`, `.claude/lib/fixture/b.psm1`, `.codex/hooks/a.ps1`; `b.psm1` is then served from the text memo). The TEST-4 row repopulates all four memos before the reset. The Memo suite has its spec `## Write Set` entry (Create, line 237) and D7 names it.
- TEST-2: the braced alternative `\$(?:\{(?<var>...)\}|...)` is the only alternative that matches `${HookRoot}/...` and `${script:HookRoot}/...`, so both rows depend on it.
- CR-G7: five `[CmdletBinding()]` attributes; `Get-EpicStateHookLiteral` emits elements; its callers at Discovery helper lines 240, 328 and 341 iterate or wrap in `@(...)`.
- 500-line limit: maximum 478 (HookReference suite). Determinism grep: six matches, none executable, none in the Memo suite.

## Findings Table

Blocking findings: 0. Non-blocking findings: 4.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Low (TEST-5) | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1` | BeforeAll lines 26-56 | The Memo suite copies verbatim from the Discovery suite the function `Get-FixtureReader` (Discovery lines 51-60) and the fixtures `$script:HookFile`, `$script:HookText`, `$script:ProbeHookText` and `$script:LoadHookSuite` (Discovery lines 71-92), about 30 lines. A change to one fixture (for example the probe hook text) must now be made in two suites, and the Memo row `PERF probe finding with supplied seams` states that it uses "the suite and reader of the Discovery row" while it holds its own copy. | Create `tests/scripts/claude-hooks/EpicStateIsolation.Fixture.Helpers.ps1` holding `Get-FixtureReader` and the four fixture assignments (each with `-replace "`r`n", "`n"`), with a header naming its two consumer suites and stating that it reads no file. Dot-source it from the file-level BeforeAll of both suites after the three existing helpers, and delete the copies (Memo lines 26-56 and Discovery lines 51-60 and 71-92 become one dot-source line each; the Discovery normalization lines 90-92 go with them). Add the new file to spec `## Write Set` (Create) and to the plan's `CODE9` set (making it `CODE10`), D-LC, scope and determinism checks. The file name does not end in `.Tests.ps1`, so the Discovery guard does not enumerate it. | `.claude/rules/general-code-change.md` Reusability ("Avoid copy-paste; share behavior via composition or helper methods"). | Memo lines 26-56; Discovery lines 51-60, 71-92. |
| Info (TEST-6) | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1` | row `PERF probe finding with supplied seams`, line 201 | `$scanned.Count \| Should -Be 1` pins the number of scanned findings but not their text, so `$supplied \| Should -BeExactly $scanned[0]` proves equality with an unspecified finding. The Discovery row it mirrors pins the text with `Should -BeLike '*never calls Invoke-EpicStateInterceptionProbe*'`. | After line 201 insert `        $scanned[0] \| Should -BeLike '*never calls Invoke-EpicStateInterceptionProbe*'` (+1 line; Memo suite 207 lines). | Assertions should identify the behaviour under test (`.claude/rules/general-unit-test.md` Readability). | Memo lines 195-204; Discovery lines 154-155. |
| Info (CR-H1) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` | `Get-EpicStateParsedSource` line 108; `Get-EpicStateHookLiteral` line 150; `Get-EpicStateLoadedSourceClosure` line 223; `Get-EpicStateSeamCensus` line 258; header lines 31-32 | After CR-G5 the three memo writers read "Deterministic ... records the result in ...", but `Get-EpicStateParsedSource` writes `$script:EpicStateParseCache` directly and still reads "Pure: ... cached by text", and three functions that write memos through their callees still read "Pure". The header paragraph on the parse memo says "keyed by source text" without the ordinal comparison that CR-G3 introduced and spec D7 states. | Line 108: `    # Deterministic: the parsed AST and the non-bareword string-literal values of one source text, recorded in $script:EpicStateParseCache by text (ordinal keys).` Line 150: replace `# Pure:` with `# Deterministic (records parse-memo entries):`. Line 223: replace `Pure over the injected reader:` with `Deterministic over the injected reader (records memo entries through its callees):`. Line 258: replace `Pure:` with `Deterministic (records census-memo entries through Get-EpicStateFileSeamCensus):`. Line 32: replace `keyed by source text,` with `keyed by source text with ordinal comparison,`. No line-count change except where reflow requires it. | Comment accuracy; completes the CR-G5 wording for every function that writes a memo. | Lines 31-32, 108, 150, 223, 258. |
| Info (CR-H2) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`; `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` | Discovery helper header lines 9-10 and 20-23, `Get-EpicStateClosureSuccessor` help lines 186-187; Helpers header lines 6-8 | The CR-F6, CR-G4 and CR-G5 edits inserted text without reflowing the paragraphs: Discovery line 10 (`enumerate the hook suites of both surfaces, compute the`) and line 22 (`which read the committed tree`) are short lines in the middle of a paragraph, line 186 runs to about 105 columns before the short line 187, and Helpers line 7 (`Predicate, Discovery, HookReference, Memo). The functions parse a`) breaks before `suite's AST`. | Reflow each of the four paragraphs to the column width of the surrounding header (about 96 columns), with no change to the words. Run the formatter and analyzer afterwards. | Readability of the help text that the next editor relies on. | Discovery helper lines 6-12, 20-24, 185-191; Helpers lines 6-13. |

## Prior Findings Status

| Prior finding | Status | Verification |
|---|---|---|
| AC-CHK-2 | Fixed | `spec.md`: 8 AC lines `- [x]` (AC-6, AC-9, AC-13, AC-18, AC-20, AC-21, AC-22, AC-25) and 18 `- [ ]`; criterion text unchanged; `evidence/other/r4-ac-recheck-note.2026-10-17T03-42.md` records the change and basis; `s9-ac-verification` not edited. |
| CR-G1 | Fixed | Discovery suite lines 117 and 119 (capture), 184-185 (assertion and read). |
| CR-G2 | Fixed | Compliance helper `Get-EpicStateProbeFinding`: `if ($null -ne $state.Error) { return $state.Error }` before `Test-EpicStateProbeCalledFromIt`; Memo row missing-suite case. |
| CR-G3 | Fixed | Discovery helper line 49 (ordinal dictionary); Memo row lines 151-162; fail-before `regression-testing/r4-rf-cr-g3-fail-before.2026-10-17T03-46.md`. |
| TEST-2 | Fixed | HookReference suite, two braced rows in `R1 identifies <Case>`. |
| TEST-3 | Fixed | (a) Memo lines 164-173, (b) 175-186, (c) 188-205 (placed in the Memo suite instead of the HookReference suite, recorded in the plan and ledger), (d) line 112 exact count 3. Residual TEST-6. |
| TEST-4 | Fixed | Memo lines 137-138: reader memo populated and all four memos in the precondition. |
| DOC-5 | Fixed | `spec.md` line 144 and D7 (line 226). Residual DOC-7 and DOC-9 in the feature audit. |
| DOC-6 | Fixed | D6 cites the header paragraph by text. Same class remains at spec line 124 (DOC-8). |
| CR-G4 | Fixed | Discovery helper header lines 6-9 name the three dot-sourcing suites and the Compliance-helper dependency. |
| CR-G5 | Fixed as prescribed | Header line 20 and the help texts of the three memo writers. Residual CR-H1. |
| CR-G6 | Fixed | HookReference suite `-Because "the $Case fixture does not form a hook path from a variable bound to a hooks root"`. |
| CR-G7 | Fixed | `[CmdletBinding()]` on `Get-EpicStateSourceReader`, `Get-EpicStateHookLiteral`, `Get-EpicStateLoadedSourceClosure`, `Get-EpicStateSeamCensus`, `Get-EpicStateProbeFinding`; element emission; analyzer returned. |
| PLAN-2 | Fixed | Plan revision 5 text (committed in `d48f58cf8`, revisions 5 to 7); `Status:` line reads Executing. |
| EV-4 | Fixed | `evidence/qa-gates/r4-plan-validation.2026-10-17T03-55.md` and ledger reference. Residual EV-5 in the feature audit. |
| DOC-2 | Open (orchestrator, after S9) | The plan assigns the PR description to pr-author after S9; no PR exists yet. |

## Correctness Notes (no finding)

- The TEST-4 row dot-sources the Discovery helper inside an `It`; the helper assigns `$script:` memos, which resolve to the container script scope, so the following rows run on empty memos. No following row depends on a memo entry written before the reset.
- `PERF reader memo returns one reader per repository root` creates a reader for `/synthetic-worktrees/other` without invoking it, so no file system access occurs.
- `PERF closure memo keys by library directory` uses one reader for both walks; the text memo is shared, and only the successor key differs, which is the property under test.
- The Memo suite is discovered by the Discovery guard; its hook literal names `a.ps1`, which exists under neither hook directory, so its closure is empty and its `AC-4` row passes (recorded as the seventh new testcase in `r4-ps-test-repo.2026-10-17T04-25.md`).
- The on-disk repository-scope figure moved by 8 covered lines against the merged-tree control with no production change; no test-only change in this cycle can move production coverage, so this is attribution variation, consistent with earlier cycles.

## Positive Observations

- The CR-G3 fail-before was taken on the Memo suite alone, and the JUnit record names the single failing row.
- The order-check record states its own limitation (the runner fixes container order) instead of claiming a shuffle it did not perform.
- The Memo suite header states why the Describe moved and that row names are unchanged, which keeps the S9 row lists traceable.
