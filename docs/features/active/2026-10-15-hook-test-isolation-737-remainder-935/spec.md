# hook-test-isolation-737-remainder (Spec)

- **Issue:** #935
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Implemented (CI-dependent acceptance criteria are confirmed at S9)
- **Version:** 0.3
- **Work Mode:** full-bug (acceptance criteria are tracked in this file only; no `user-story.md`)
- **Design source:** `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/research/research.2026-10-15T22-03.md`

## Context
Remaining hook-test isolation work from #737, recorded as #903 Operator Follow-ups 4 (F-3), 5 (N-2), 6 (F-6), 10 (F-1/F-2) and 11 (I-3). The #737 and #903 feature folders are cited below by folder name; each may be located under `docs/features/active/` or `docs/features/archive/`:

- #737: `2026-09-27-hook-test-isolation-remaining-gaps-737/` (`code-review.2026-10-09T06-46.md`, findings F-1..F-6, N-2, I-3).
- #903: `2026-10-11-round-2-review-nits-and-evidence-timestamps-903/` (`issue.md` `## Operator Follow-ups`; `evidence/qa-gates/f1-f2-decision.2026-10-13T13-44.md`; `evidence/qa-gates/ps-rows.2026-10-13T13-43.md`).

The isolation guard under `tests/scripts/claude-hooks/` (`EpicStateIsolation.Helpers.ps1`, `.Discovery.Helpers.ps1`, `.Compliance.Helpers.ps1`, `.Baseline.Helpers.ps1`, and the `enforce-gate-suites.EpicStateIsolation.*.Tests.ps1` suites) is test infrastructure. No production hook, runtime, or policy file changes in this item.

Environment:
- OS/version: Windows (`poshqc / PowerShell QC`, windows-latest) and Linux (`poshqc / PowerShell hook suites (Linux)`, hook-suite directories only)
- Python version: n/a
- Command/flags used: PoshQC MCP tools (`run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`) locally; PR CI for per-row results
- Data source or fixture: `origin/main` at `adb9aa5f0` (research base); issue snapshot at `f6915d42`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low


## Repro & Evidence
Steps to Reproduce:
1. Read #903 `issue.md` `## Operator Follow-ups` items 4, 5, 6, 10 and 11 (folder `2026-10-11-round-2-review-nits-and-evidence-timestamps-903/` under `docs/features/active/` or `docs/features/archive/`).
2. F-1/F-2: reapply the withheld change recovered from commit `4e8d9f92d` (reverse diff; research Item 1) and run `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`. CI run 38404520141 failed seven `AC-4` rows with `<suite>: seam <name>: no dot-source loads the hook`.
3. F-3: inspect `Get-EpicStateLoadedSourceClosure` and `Get-EpicStateProcessSpawningHook` (`EpicStateIsolation.Discovery.Helpers.ps1`); both recognise hooks only through `hooks/<name>.ps1` string literals.
4. I-3: count lines of the four named files; each is exactly 500.

Expected:
Each item is delivered or closed with a recorded decision.

Actual:
- F-3 (item 4): the isolation guard does not detect `Join-Path <root-variable> '<name>.ps1'` hook loads or ProcessStartInfo suites with variable-built paths.
- N-2 (item 5): optional rename of `-Surface` to `-Scope` across 45 consuming suites plus two guard suites (322 call lines in 47 files; research N4).
- F-6 (item 6): open question whether test-session memo caches should be a named exception in the PowerShell policy.
- F-1/F-2 (item 10): withheld in #903 because the Discovery guard flagged seven suites in CI run 38404520141; the four files were restored (commit `4e8d9f92d`).
- I-3 (item 11): four test files are at 500 lines and must be split before their next edit.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: #903 `issue.md` Operator Follow-ups 4, 5, 6, 10, 11; `ps-rows.2026-10-13T13-43.md` (failing `AC-4` testcase list).


## Scope & Non-Goals
- In scope:
  - F-1/F-2: reapply the withheld implementation with refinements R1 (root-variable and segment hook-reference identification) and R2 (helper-only `BeforeAll` blocks anchored at the last `.Helpers.ps1` dot-source, no F-2 finding), with hook-reference functions moved to a new `EpicStateIsolation.HookReference.Helpers.ps1`.
  - F-3: report-only detection of variable-built hook loads.
  - I-3: split the four named 500-line files as pure moves.
  - N-2 and F-6: record decisions (no code or policy change).
- Out of scope / non-goals:
  - Closure enforcement of variable-built hook loads (deferred; see `## Decisions`).
  - Any edit to the seven flagged suites.
  - Splitting the 13 other files at 490-499 lines and `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` (500).
  - The `-Surface` to `-Scope` rename.
- Explicitly excluded systems, integrations, or datasets:
  - Every file under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/` (including `.claude/rules/` and `.github/instructions/`).
  - Files likely owned by concurrent items #928, #929 and #936: SubagentStop validators and their suites (`tests/scripts/claude-hooks/validate-*-output*.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`), `hook-dependency-failure*.Tests.ps1` in both hook-suite directories, and the Codex preimplementation-gate modes and epic-scope suites (`enforce-orchestration-preimplementation-gate-modes*.Tests.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`).

## Root Cause Analysis
- F-1: `Get-EpicStateIsolationDirectCommand` treats only `ScriptBlockAst`, `ScriptBlockExpressionAst` and `FunctionDefinitionAst` ancestors as nested, so a mock under `if`, `switch`, a loop, `try` or `trap` counts as unconditional.
- F-2: `Get-EpicStateIsolationHookDotSource` falls back to the first dot-source when no dot-source is identified as the hook load (step iii), so a test-helper load can stand in for the hook.
- Withhold cause: removing the step (iii) fallback flagged seven suites whose `BeforeAll` blocks are correct but whose shapes the predicate does not describe (research Item 1 table):
  - Shape A (root-variable composition): `hook-command-consumers.Issue824`, `hook-command-invocation.Issue824Regression` dot-source `(Join-Path $script:RepoRoot "$HookRoot/<name>.ps1")` with `HookRoot` bound to `'.claude/hooks'`/`'.codex/hooks'`.
  - Shape B (hook loaded only inside `It`): `hook-dependency-failure.Claude`, `hook-dependency-failure.SpecialCases`, `hook-dependency-failure.Codex`; outermost `BeforeAll` dot-sources only `.Helpers.ps1` files.
  - Shape C (no hook load): `session-root-reads-850.Constraints`, `codex-epic-runtime-contracts`; hook paths are data only.
- F-3: the loaded-source closure and the process-spawning detector are seeded only from `hooks/<name>.ps1` literals.
- I-3: four test files reached the 500-line limit.
- F-6: the authoritative `.github/instructions/powershell-code-change.instructions.md` line 53 already permits required exceptions ("unless required"); the `.claude/rules/powershell.md` line 31 mirror omits that qualifier (mirror drift, not a missing exception).


## Proposed Fix

### Design summary (what changes where):
1. **F-1/F-2 (research Item 1).** Reapply the recovered withheld change: `Test-EpicStateIsolationConditionalAncestor` (F-1), its call in `Get-EpicStateIsolationDirectCommand`, `return $null` in place of the first-dot-source fallback, the `no dot-source loads the hook` finding in `Get-EpicStateIsolationFinding`, the `$script:UnderTest` fixture bindings (Branches, Predicate, legacy guard), and the recovered Branches rows. Add:
   - **R1:** `Test-EpicStateIsolationHookReference -Node -SuiteAst`, true when the node holds (a) a `hooks/<name>.ps1` literal; (b) an expandable string `"$<var>/<name>.ps1"` or `"$<var>\<name>.ps1"`; (c) `Join-Path <expr> '<name>.ps1'` (positional or `-ChildPath`); or (d) `Join-Path ... -AdditionalChildPath ..., 'hooks', '<name>.ps1'`; where `<var>` (or a variable in `<expr>`) is bound by assignment or hashtable entry (existing `Get-EpicStateIsolationVariableKey` rule, one level of indirection) to a string ending in a `hooks` segment (regex `(^|[\\/])hooks[\\/]?$`). Steps (i) and (ii) of the dot-source selector use it.
   - **R2:** when a block has dot-sources, none is identified, and every one is a test-helper load (argument holds a string literal whose leaf matches `\.Helpers\.ps1$` and is not a hook reference), emit no F-2 finding and use the last helper dot-source as the ordering anchor for `Get-EpicStateIsolationHelperSeam` and `Get-EpicStateIsolationPairFinding`. Presence rules still apply. The F-2 finding is guarded by `-not $helperOnly`.
   - Move `Test-EpicStateIsolationHookLiteral`, `Get-EpicStateIsolationVariableKey`, `Test-EpicStateIsolationVariableBoundToHook`, `Get-EpicStateIsolationHookDotSource` and the new R1/R2 classification functions into `EpicStateIsolation.HookReference.Helpers.ps1`, dot-sourced from the top of `EpicStateIsolation.Helpers.ps1` so its four consumers need no new dot-source line.
2. **F-3 (research Item 2).** Add `Get-EpicStateIsolationHookReference -Ast` (in the HookReference helper) returning one record per hook reference in a load position (`Name`, or `*` for a non-literal leaf; `Form` in `Literal`/`RootVariable`/`Segment`/`Dynamic`; `Root` in `.claude/hooks`/`.codex/hooks`/`$null`). `Get-EpicStateProcessSpawningHook` returns the union of literal and non-literal references for spawning suites (`*(<root>)` for a dynamic leaf). New `Get-EpicStateVariableHookLoad -SuiteText` (Discovery helper) and `Get-EpicStateVariableHookLoadReport` (Compliance helper, format `REPORT-VARIABLE-LOAD: <path> loads <names>`). New Discovery row `AC-5b variable-built hook-load report <Surface>` writes to the information stream and never fails. The closure remains literal-seeded.
3. **I-3 (research Item 3).** Pure moves:
   - `enforce-epic-worktree-removal-gate.Tests.ps1`: move the manifest-branch Describe (lines 430-500) to `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`, plus a `baseline mock interception probe` row.
   - `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`: move Contexts `cross-file mock resolution smoke` and `call-target resolution seam` (lines 154-234) to `enforce-prd-feature-before-planner.CallTarget.Tests.ps1` with its own `BeforeAll` and a probe row; the matrix, its factories and the N-2 call at line 101 stay.
   - Codex `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`: move the three `BeforeAll` helper functions (lines 32-69) to `...command-exemption.Helpers.ps1`; move the #671 and #663 Contexts to `...command-exemption.Selectors.Tests.ps1` with a probe row; the #539 Contexts stay.
   - `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`: move the allowlist declaration, the `ALLOWLIST POLICY` header paragraph and the four allowlist functions to `EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`, dot-sourced from the top of the original helper.
4. **N-2, F-6:** decisions only (see `## Decisions`).

### Boundaries and invariants to preserve:
- The Discovery suite contains no hard-coded suite list or exemption (`AC-2 no hard-coded suite list in N2` keeps passing).
- The loaded-source closure is seeded only from `hooks/<name>.ps1` literals; F-3 output is report-only and never fails a row.
- A block holding any non-helper, unidentified dot-source still yields `no dot-source loads the hook`.
- Splits are pure moves: test names unchanged; no case-only name collisions; consumers of `EnforcementHooksNoPythonInvocation.Helpers.ps1` unchanged.
- All new rows use in-memory inputs; no temporary files, `TestDrive`, wall-clock reads or process starts.

### Dependencies or blocked work:
- Concurrent items #928, #929 and #936 operate near `tests/scripts/claude-hooks` and Codex preimplementation-gate suites; this item edits none of their likely files. Suites they add later are judged by the tightened predicate.
- The withheld implementation is recovered from commit `4e8d9f92d` (reverse diff) as transcribed in research Item 1.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
See `## Write Set`.

#### Functions/classes/CLI commands impacted:
- New: `Test-EpicStateIsolationConditionalAncestor`, `Test-EpicStateIsolationHookReference`, a test-helper-load classifier (name chosen by the plan), `Get-EpicStateIsolationHookReference`, `Get-EpicStateVariableHookLoad`, `Get-EpicStateVariableHookLoadReport`.
- Changed: `Get-EpicStateIsolationDirectCommand`, `Get-EpicStateIsolationHookDotSource`, `Get-EpicStateIsolationFinding`, `Get-EpicStateProcessSpawningHook`.
- Moved without behavior change: `Test-EpicStateIsolationHookLiteral`, `Get-EpicStateIsolationVariableKey`, `Test-EpicStateIsolationVariableBoundToHook`; `Get-PythonInvocationAllowlist`, `Test-PythonInvocationAllowlistMatch`, `Select-UnallowedPythonInvocationFinding`, `Get-UnusedPythonInvocationAllowlistEntry`.

#### Data flow and validation changes:
- Dot-source identification: literal, bound literal, R1 root variable or segment; no first-dot-source fallback; helper-only blocks anchored at the last helper (R2).
- F-3 report lines flow to the information stream of the `AC-5` and `AC-5b` rows.

#### Error handling and logging updates:
- New finding text `no dot-source loads the hook` (recovered). Missing or unparseable suites keep their existing findings.
- `EpicStateIsolation.Helpers.ps1` header records the shape-B residual limit; `EpicStateIsolation.Discovery.Helpers.ps1` header (lines 16-19) states that variable-built loads are reported, not added to the closure.

#### Rollback/feature-flag considerations (if applicable):
- Test-only change; rollback is a revert of the PR. No flag.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Get-EpicStateIsolationHookReference` record: `Name` (string, `*` when non-literal), `Form` (`Literal` | `RootVariable` | `Segment` | `Dynamic`), `Root` (`.claude/hooks` | `.codex/hooks` | `$null`).
- Report line: `REPORT-VARIABLE-LOAD: <path> loads <names>`.
- Load positions: `.` and `&` arguments, `Import-Module` path arguments, `ProcessStartInfo` `FileName`/`ArgumentList.Add` arguments, process-start cmdlet `-FilePath`/`-ArgumentList` arguments, and assignments to a variable later used in one of those positions. `Join-Path` used only for reads or hashing (`Get-FileHash`, `Get-Content`, `ParseFile`) is not a load.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
- Every existing Branches, Predicate, legacy-guard and Discovery row keeps its name and passes.
- Every function moved to a new helper file remains available to existing consumers through the original file's dot-source.

#### Performance constraints (latency/throughput/memory):
- The Discovery suite continues to use the existing `$script:EpicStateParseCache` parse memo; no additional per-suite file parse beyond one AST walk for hook references.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - The research reading-based conclusions (no suite beyond the seven newly flagged; no F-1 finding masked behind F-2) hold; they are confirmed or refuted by the CI Discovery run.
  - `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` references `EnforcementHooksNoPythonInvocation.Helpers.ps1:328` as a historical record and is not resolved against the current file.
- Constraints (budget, performance, compatibility):
  - 500-line limit on every created or edited code file.
  - No temporary files in tests. Scratch files, if any, live under `SCRATCH/935/` (namespace `issue-935`) and are not committed.
  - PoshQC MCP results carry no per-test output or coverage text; per-row results and coverage come from PR CI artifacts (`poshqc-test-results`, `poshqc-linux-hook-test-results`, Pester coverage file).
- External dependencies (services, libraries, releases): Pester and PSScriptAnalyzer through PoshQC; GitHub Actions `poshqc` workflow.

## Data / API / Config Impact
- User-facing or API changes: none (test infrastructure only).
- Data or migration considerations: none.
- Logging/telemetry updates (if any): new `REPORT-VARIABLE-LOAD:` information-stream lines; `AC-5` report lines gain non-literal entries.
- Compatibility notes (CLI flags, config schemas, versioning): `Register-EpicStateBaselineMock -Surface` unchanged (N-2 closed).

## Test Strategy
Seeded from issue (dispositions per `## Decisions`):

- [ ] Apply F-1/F-2 with refinements R1 and R2; the seven flagged suites become compliant with no edit to them.
- [ ] Extend detection for F-3 (report-only).
- [ ] Split the 500-line files (I-3).
- [ ] Decide N-2 and F-6 (recorded).

- Regression tests to add or update:
  - `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`: recovered F-1 and F-2 rows.
  - `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Tests.ps1`: recovered `$script:UnderTest` bindings.
  - New `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`: R1, R2 and F-3 detector rows.
  - `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`: `AC-5b` report row.
  - New split suites: one `baseline mock interception probe` row each.
- Unit tests (Pester) for the fixed behavior and boundaries: as above; all fixtures are in-memory suite text parsed to AST.
- Edge cases and negative scenarios: matching vs non-matching `Get-Command` guard; `else`/multi-clause `if`; `switch`, loop, `try`, `trap`; variable bound to a non-`hooks` segment; two-level binding; mixed helper and non-helper dot-sources; mock placed between two helper dot-sources; non-load `Join-Path`; dynamic leaf.
- Error handling and logging verification: missing and unparseable suite rows keep passing; `AC-5b` never fails.
- Fail-before expectations (research Testing Implications):
  1. The recovered F-1/F-2 rows fail against the current helper.
  2. A Discovery run with F-1/F-2 reapplied and without R1/R2 reproduces the `no dot-source loads the hook` findings of CI run 38404520141 for each suite named in AC-6; any other failing row is listed by name.
  3. The R1 and R2 rows fail against the F-2-only predicate.
  4. The F-3 detector rows fail against the current `Get-EpicStateProcessSpawningHook`.
  Fail-before records are written to `evidence/regression-testing/`.
- Coverage impact and targets for changed lines/modules: no production file changes; all changed files are under `tests/`, which is excluded from coverage measurement. The Pester coverage file from `poshqc / PowerShell QC` (windows-latest) is compared against the baseline to confirm no regression; the Linux hook-suite job is not used for coverage.
- Toolchain commands to run: `run_poshqc_format` -> `run_poshqc_analyze` -> (type-check not applicable to PowerShell) -> `run_poshqc_test` on every changed `.ps1` file and suite; repeat until a single clean pass; then PR CI on both jobs.
- Manual validation steps (if required): read the `AC-5b` report lines from the CI log and record them under `evidence/other/` as the measured input for the deferred F-3 enforcement follow-up.


## Acceptance Criteria
- [x] AC-1: In `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, the rows `F-1 non-compliant <Branch>` for `ESR mock inside if ($false)`, `ESR mock inside try/catch` and `ESR mock inside a Get-Command guard naming another seam` each report `Mock of Get-EpicScopeCheckpointText missing from outermost BeforeAll`, and the rows `F-1 compliant <Branch>` for `ESR mock inside a matching Get-Command guard` and `baseline helper inside a matching Get-Command guard` report zero findings. Each of these rows passes in `poshqc / PowerShell QC` (windows-latest) and `poshqc / PowerShell hook suites (Linux)`, and a fail-before record under `evidence/regression-testing/` shows them failing against the pre-change helper.
- [x] AC-2: The row `F-2: reports no dot-source loads the hook when only a helper is dot-sourced` (fixture dot-sources only `Helper.ps1`, which does not match `\.Helpers\.ps1$`) passes in both CI jobs, and `Get-EpicStateIsolationHookDotSource` returns `$null`, not the first dot-source, when no dot-source is identified. A fail-before record shows the row failing against the pre-change helper.
- [x] AC-3: Every pre-existing row of `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`, `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` (including the AC-8 rows) and `enforce-gate-suites.EpicStateIsolation.Tests.ps1` keeps its name and passes in both CI jobs with the recovered `$script:UnderTest = Join-Path $PSScriptRoot 'hooks/enforce-x.ps1'` bindings in place.
- [x] AC-4: `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` contains R1 rows asserting that `Test-EpicStateIsolationHookReference` identifies (a) a `hooks/<name>.ps1` literal, (b) `"$<var>/<name>.ps1"` and `"$<var>\<name>.ps1"`, (c) `Join-Path <expr> '<name>.ps1'` in positional and `-ChildPath` form, (d) a `-AdditionalChildPath ..., 'hooks', '<name>.ps1'` segment list, each with the variable bound by assignment and by hashtable entry; and negative rows asserting no identification when the variable is bound to a string not ending in a `hooks` segment or is unbound. The rows pass in both CI jobs, and a fail-before record shows the positive rows failing against the F-2-only predicate.
- [x] AC-5: The HookReference suite contains R2 rows asserting that (a) a `BeforeAll` whose dot-sources are all `.Helpers.ps1` test-helper loads yields no `no dot-source loads the hook` finding; (b) a seam mock placed before the last helper dot-source in such a block yields an ordering finding; (c) a missing seam mock in such a block still yields the presence finding; (d) a block holding a helper dot-source and a non-helper, unidentified dot-source yields `no dot-source loads the hook`. The rows pass in both CI jobs, and a fail-before record shows rows (a) and (b) failing against the F-2-only predicate.
- [x] AC-6: A fail-before record under `evidence/regression-testing/`, taken from the CI JUnit artifact of a run with F-1/F-2 reapplied and R1/R2 absent, shows a failing `AC-4` row with message `no dot-source loads the hook` for each of `hook-command-consumers.Issue824`, `hook-command-invocation.Issue824Regression`, `hook-dependency-failure.Claude`, `hook-dependency-failure.SpecialCases`, `session-root-reads-850.Constraints` (claude-hooks), `codex-epic-runtime-contracts` and `hook-dependency-failure.Codex` (codex-hooks), and lists every other failing Discovery row observed in that run by name (no failure-count assertion is made).
- [x] AC-7: With the final change, the Discovery `AC-4 <Path> complies with the baseline isolation form for every closure seam` rows for each suite named in AC-6 pass in both CI jobs, with no edit to any of those files.
- [x] AC-8: With the final change, every row of `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (all `AC-2`, `AC-3`, `AC-4`, `AC-5`, `AC-5b` and `AC-6` rows, including those for the new split suites) passes in both CI jobs, and the rows `AC-2 no hard-coded suite list in N2` and `AC-2 no hard-coded suite list or decision D9 note in the legacy guard` pass. Per-suite results are recorded under `evidence/qa-gates/` from the CI JUnit artifacts.
- [x] AC-9: The header of `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` records the shape-B residual limit (a hook loaded only inside `It` bodies is outside the `BeforeAll` model; hook-local seams guarded by `if (Get-Command X)` are runtime no-ops in such suites) and the R2 helper-only relaxation.
- [x] AC-10: The HookReference suite contains F-3 detector rows for `Get-EpicStateIsolationHookReference` covering each form: RootVariable bare, RootVariable expandable, two-level binding, Segment, Dynamic spawn (`Name` `*`, reported as `*(<root>)`), and a non-load `Join-Path` used only by `Get-FileHash`, `Get-Content` or `ParseFile` (not reported). The rows pass in both CI jobs, and a fail-before record shows them failing before the detector change.
- [x] AC-11: A fixture row asserts that `Get-EpicStateProcessSpawningHook` reports a process-spawning suite whose hook path is variable-built (union of literal and non-literal references, `*(<root>)` for a dynamic leaf); it passes in both CI jobs and fails against the current function (fail-before record). The existing rows `AC-5 process-spawning report <Surface>` and `AC-5 process-spawning fixture is reported and does not fail` pass.
- [x] AC-12: The Discovery suite contains the row `AC-5b variable-built hook-load report <Surface>` for both surfaces; it writes `REPORT-VARIABLE-LOAD: <path> loads <names>` lines to the information stream and never fails. A non-vacuity row `F-3 non-vacuity <Surface> reports at least one variable-built hook load` (in the HookReference or Discovery suite) asserts at least one such line per surface on the committed tree and passes in both CI jobs. The `AC-5b` output from the PR CI log is recorded under `evidence/other/`.
- [x] AC-13: `Get-EpicStateLoadedSourceClosure` remains seeded only from `hooks/<name>.ps1` literals (no variable-built load joins the closure), and the header paragraph of `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` states the new detection and that variable-built loads are reported, not added to the closure.
- [x] AC-14: I-3 split 1: `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` is below 500 lines; the manifest-branch Describe is moved to `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` with unchanged test names plus one `baseline mock interception probe` row; the sum of Passed counts of the original and new suites in `poshqc / PowerShell QC` equals the baseline Passed count of the original suite plus one.
- [x] AC-15: I-3 split 2: `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` is below 500 lines and retains the target resolution matrix, its factories and the N-2 call; Contexts `cross-file mock resolution smoke` and `call-target resolution seam` are moved to `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1` with unchanged test names plus one probe row; the sum of Passed counts equals the baseline count plus one.
- [x] AC-16: I-3 split 3: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` is below 500 lines and retains the #539 Contexts; the helper functions defined in its `BeforeAll` (lines 32-69) are moved to `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1` (dot-sourced after the hook and the Baseline helper); the #671 and #663 Contexts are moved to `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` with unchanged test names plus one probe row; the sum of Passed counts equals the baseline count plus one.
- [x] AC-17: I-3 split 4: `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` is below 500 lines; the allowlist declaration, the `ALLOWLIST POLICY` header paragraph, `Get-PythonInvocationAllowlist`, `Test-PythonInvocationAllowlistMatch`, `Select-UnallowedPythonInvocationFinding` and `Get-UnusedPythonInvocationAllowlistEntry` are moved to `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`, dot-sourced from the top of the original helper; `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` are not edited and their Passed counts equal their baseline counts.
- [x] AC-18: Baseline Passed counts for each original I-3 suite named in AC-14, AC-15 and AC-16 and for each helper consumer named in AC-17 are recorded under `evidence/baseline/` before the split, and post-split counts under `evidence/qa-gates/`, both from CI JUnit artifacts.
- [x] AC-19: `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`, `BlastRadius.HistoricalRuns.Tests.ps1` and `test_blast_radius_historical_runs.py` pass in CI with no edit to them.
- [x] AC-20: Every created or edited code file in `## Write Set` is at or below 500 lines (in particular `EpicStateIsolation.Helpers.ps1`, `EpicStateIsolation.HookReference.Helpers.ps1`, `enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` and each I-3 original file); the measured line counts are recorded under `evidence/qa-gates/`.
- [x] AC-21: `git diff --name-only origin/main...HEAD` lists no path under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/` or `config/` (therefore no `.claude/rules/` or `.github/instructions/` change), and lists only paths in `## Write Set`.
- [x] AC-22: The same diff lists no suite named in AC-6, no `tests/scripts/claude-hooks/validate-*-output*.Tests.ps1`, no `validate-discovery-artifact-gate.Tests.ps1`, no `hook-dependency-failure*.Tests.ps1` in either hook-suite directory, no SubagentStop validator, and no `enforce-orchestration-preimplementation-gate-modes*.Tests.ps1` or `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (concurrent items #928, #929, #936).
- [x] AC-23: `run_poshqc_format` reports no change, `run_poshqc_analyze` reports zero findings, and `run_poshqc_test` passes for every created or edited `.ps1` file in a single clean pass; the PR CI jobs `poshqc / PowerShell QC` and `poshqc / PowerShell hook suites (Linux)` conclude `success` on the final PR head.
- [ ] AC-24: The Pester coverage file from `poshqc / PowerShell QC` on the final PR head shows overall line coverage not lower than the baseline recorded under `evidence/baseline/` and not below 85%; the comparison is recorded under `evidence/qa-gates/`. No production file is excluded from coverage.
  - Amendment (2026-10-16, coordinator decision): accepted under option 1 (Pester breakpoint attribution loss in production files this branch does not change), not met as written for the baseline comparison; the 85% floor and the no-exclusion clause still apply. Decision record: `evidence/other/cov1-decision-option1.2026-10-16T20-38.md`. Left unchecked under acceptance-criteria-tracking rule 4 until S9; P7-T10 records AC-24 as ACCEPTED-OPTION-1 when P7-T6 confirms the 85% floor and no exclusion on the final head, or as PASS when P7-T6 also records BASELINE-CLAUSE: MET.
- [x] AC-25: No created or edited test file uses `New-TemporaryFile`, `TestDrive`, `[System.IO.Path]::GetTempFileName`, `Get-Date`, `Start-Sleep`, `Start-Process` or `ProcessStartInfo` outside string fixtures (verified by Grep, recorded under `evidence/qa-gates/`).
- [x] AC-26: `## Decisions` in this spec records the dispositions for N-2 (closed, no action), F-6 (no policy change; mirror-drift note), F-3 enforcement (deferred), the shape-B residual limit, and the I-3 residue, and the PR description lists the same operator follow-ups.

## Decisions
- **D1 - F-1/F-2 (Operator Follow-up 10): deliver.** Reapply the recovered withheld implementation with R1 and R2; hook-reference functions move to `EpicStateIsolation.HookReference.Helpers.ps1` to keep `EpicStateIsolation.Helpers.ps1` under 500 lines. No edit to the seven flagged suites. Rejected: editing the seven suites (cannot express shapes B and C; overlaps #928 files) and a suite exemption list (contradicts `AC-2 no hard-coded suite list in N2`).
- **D2 - Shape-B residual limit (recorded).** Hooks loaded only inside `It` bodies are outside the guard's `BeforeAll` model. Module-scope seams remain covered by baseline mocks; hook-local seams guarded by `if (Get-Command X)` are runtime no-ops in those suites. Recorded in the `EpicStateIsolation.Helpers.ps1` header and as an operator follow-up.
- **D3 - F-3 (Operator Follow-up 4): detection delivered as report-only; closure enforcement deferred.** Enforcement would add requirements to the newly detected suites (estimated 15 or more needing baseline mocks and probe rows), needs a prior split of `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (497 lines), and overlaps #928/#929 activity in `tests/scripts/claude-hooks`. Follow-up: add variable-built loads to the closure using the `AC-5b` report as the measured list. Known report false positives (`check-powershell-test-purity.Tests.ps1`, `enforce-promotion-mcp-only.Issue824.Tests.ps1`) are accepted because the report never fails a row.
- **D4 - I-3 (Operator Follow-up 11): split the four named files as pure moves.** Residue recorded as an operator note: 13 other files at 490-499 lines and `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1` (500) are split before their next edit.
- **D5 - N-2 (Operator Follow-up 5): closed, no action.** The `-Surface` semantics are documented at the definition (`EpicStateIsolation.Baseline.Helpers.ps1` lines 37-42, #903 AC-41). A rename would touch 47 files (322 call lines; research N4), including seven files at 490 lines or more, the three `hook-dependency-failure*` suites (likely #928) and Codex preimplementation-gate suites near #936; `Invoke-EpicStateInterceptionProbe -Surface` is a true surface selector and would diverge; an `[Alias('Scope')]` would add a second name without removing the first.
- **D6 - F-6 (Operator Follow-up 6): no policy change in this item.** No named memo-cache exception is needed: the authoritative `.github/instructions/powershell-code-change.instructions.md` line 53 already reads "unless required", and `$script:EpicStateParseCache` is documented as a test-session-only memo at its definition (`EpicStateIsolation.Discovery.Helpers.ps1` lines 21-22, #903 AC-39). Mirror-drift note for the operator: `.claude/rules/powershell.md` line 31 omits "unless required" and may be aligned in a policy-owned change. `.claude/rules/` and `.github/instructions/` are not modified here.

## Write Set
Create:
- `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1`
- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1`

Edit:
- `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`

Feature-folder documents (create or edit):
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.<timestamp>.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/baseline/`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/regression-testing/`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/qa-gates/`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/evidence/other/`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/issue.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/research/research.2026-10-15T22-03.md`
- review and orchestration artifacts under `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/`

Delete: none.

Not edited (explicitly): the suites named in AC-6; every file under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`; the files listed in AC-22; the 13 other test files at 490-499 lines and `tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1`.

## Risks & Mitigations
- Technical or operational risks:
  - R2 relaxes F-2 for helper-only blocks; a suite could load a hook through a `.Helpers.ps1` file and pass on presence alone.
  - The "no additional suite flagged" and "no F-1 finding masked behind F-2" conclusions are reading-based; `Get-EpicStateSuiteCompliance` reports only the first finding per seam.
  - R1 can move the ordering anchor in a block holding both a root-variable hook load and a later literal load.
  - F-3 report contains known false positives.
  - Moving allowlist functions changes line numbers referenced by `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json`.
  - Suites added later by #928/#929 are judged by the tightened predicate.
  - The research filename stamp came from an HTTP time service, not the host clock.
- Mitigations and rollbacks:
  - Header documentation of the R2 limit; F-3 report surfaces variable-built loads.
  - Full-population Discovery run in CI with per-suite results recorded (AC-8).
  - AC-19 verifies the blast-radius historical tests.
  - Rollback is a revert of the PR.

## Rollout & Follow-up
- Release/rollout steps: merge after both PoshQC CI jobs succeed on the final PR head.
- Post-fix monitoring or clean-up tasks (operator follow-ups):
  1. F-3 enforcement using the `AC-5b` report; split `legacy-codex-hook-contracts.Tests.ps1` first.
  2. Shape-B limit for hook-local seams in suites that load hooks only inside `It`.
  3. F-6 mirror drift in `.claude/rules/powershell.md` line 31.
  4. I-3 residue: 13 files at 490-499 lines and `BlastRadiusConfig.Tests.ps1` at 500.
- Links: issue #935 (https://github.com/drmoisan/drm-copilot/issues/935); #737 and #903 feature folders (under `docs/features/active/` or `docs/features/archive/`); research `research/research.2026-10-15T22-03.md`; CI run 38404520141; commit `4e8d9f92d`.
