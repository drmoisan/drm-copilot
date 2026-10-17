# Research: hook coverage attribution gaps (Issue #936)

- Date: 2026-10-15
- Branch: `bug/hook-coverage-attribution-gaps-936` (base `adb9aa5f`, main)
- Work mode: minor-audit, preparation run (research only; no code change in this step)
- Sources: CI artifacts `poshqc-test-results` of runs 38410234897 (head 17a6497e), 38423196404 (head 41d406d2), and 38730332356 (main, head adb9aa5f); the `poshqc / PowerShell QC` job log of run 38423196404; the repository files cited below; PowerShell engine source (`debugger.cs`, `CompiledScriptBlock.cs`); Pester `rel/5.x.x` source (`CodeCoverageConfiguration.cs`).

## Summary

All three gap lines still report `ci="0"` on current main (run 38730332356), at the same line numbers as in #903. In every case, a test that passes in the coverage job executes the line in-process and asserts an effect that only that line produces. No test uses a child process, a separate runspace, a stub copy, or a bundled copy of the hook. The coverage population includes `.codex/hooks`, and the two same-basename `sourcefile` entries are kept apart by their `<package>` paths. A duplicate-basename or path-normalization misattribution is therefore ruled out.

The likely root cause is in PowerShell's breakpoint binding, not in the tests. CI coverage runs Pester in breakpoint mode (`CodeCoverage.UseBreakpoints` is not set, and Pester 5.x defaults it to `$true`). Each PowerShell line breakpoint binds to one compiled instance of a script file, and it is not rebound when the same, unchanged file is compiled again. When an earlier suite in the 10,000-test run first compiles a file, breakpoints on lines that suite does not execute stay attached to that first instance. If a later suite runs those lines in a new compiled instance, Pester records no hit. The covered and uncovered line sets of `Get-OrchestrationEpicScopeDecision` match this mechanism exactly, and they cannot be explained by "the line did not run". The mechanism has not been reproduced by experiment, so it is recorded as likely, not verified.

Recommended minimal fix: no production hook change and no coverage-configuration or workflow change. Document the cause in the headers of the two Codex test files that already execute and assert the lines. Record evidence from a single-suite coverage run (where no recompilation can occur) showing that the lines are attributed. Switching the repository to Pester's profiler-based tracer (`UseBreakpoints = $false`) would fix attribution itself, but it changes repo-wide measurement and needs an operator decision. It is listed under Risks and Open Questions.

## Evidence

### Coverage configuration (applies to all gaps)

- `.github/workflows/_poshqc.yml:8-42`: job `poshqc` (name `PowerShell QC`, `runs-on: windows-latest`) runs `Invoke-PoshQCTest -Root "${{ github.workspace }}"`. It uploads `artifacts/pester/powershell-coverage.xml` as artifact `poshqc-test-results` (lines 44-52). The Linux job `poshqc-linux-hooks` sets `$config.CodeCoverage.Enabled = $false` (line 78), so it produces no coverage.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27`: `CodeCoverage = @{ Enabled = $true; OutputFormat = 'CoverageGutters'; OutputPath = 'artifacts/pester/powershell-coverage.xml'; CoveragePercentTarget = 0 }`. It has no `Path` and no `UseBreakpoints` key (a repository-wide Grep for `UseBreakpoints` outside `docs/` returned no match).
- `config/poshqc-coverage.json:3-9`: roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. The bundled copies under `extensions/drm-copilot/resources/` are not in the population.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1:353-357`: the resolved population is assigned to `$config.CodeCoverage.Path` as absolute file paths.
- Pester `rel/5.x.x` `CodeCoverageConfiguration.cs`: `UseBreakpoints` is `new BoolOption("EXPERIMENTAL: When false, use Profiler based tracer ...", true)` and `SingleHitBreakpoints` defaults to `true`. CI therefore uses single-hit breakpoints. (The current pester.dev page lists `UseBreakpoints` default `$false`; that page describes the newer major version, not 5.x.)
- Pester version: `scripts/powershell/PoshQC/PoshQC.psm1:57` pins `5.6.1`, but the run 38423196404 log line 204 reads `Pester 5.9.0 already present.` Both versions are 5.x, so breakpoint mode is the default either way.
- Job log of run 38423196404, lines 1002-1007: `Code coverage population: source=config; files=202`, `Discovery found 10308 tests`, `Starting code coverage.` (once, before `Running tests.`). The breakpoints are set once for the whole run.
- Package entries in the main XML (run 38730332356): `<package name="D:/a/drm-copilot/drm-copilot/.claude/hooks">` starts at line 5 and `<package name="D:/a/drm-copilot/drm-copilot/.codex/hooks">` at line 16185. The same layout appears in the older runs, with `.codex/hooks` at line 16066.

### Gap 1: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41`

- Current content, unchanged since #903 (`.codex/hooks/...-modes.ps1:36-42`): line 36 `$script:OrchestrationFeatureFolderResolutionImportFailure = $null`; line 38 `. (Join-Path $PSScriptRoot 'feature-folder-resolution.ps1')` inside `try`; line 41 (the catch body) `$script:OrchestrationFeatureFolderResolutionImportFailure = 'feature-folder-resolution.ps1'`.
- Main, run 38730332356, `.codex/hooks` package, `powershell-coverage.xml:20355-20358`:
  - `<sourcefile name="enforce-orchestration-preimplementation-gate-modes.ps1">`
  - `<line nr="36" mi="0" ci="1" .../>`, `<line nr="38" mi="0" ci="2" .../>`, `<line nr="41" mi="1" ci="0" mb="0" cb="0" />`
- Same in run 38410234897 (`:20236-20239`) and run 38423196404 (`:20236-20239`): `<line nr="41" mi="1" ci="0" .../>`.
- The `.claude/hooks` copy, same XML (`:4594-4597`): `<line nr="41" mi="0" ci="1" .../>`. The Claude twin of the same handler is attributed. Run 38410234897 `:4553-4556` shows the same.
- Executing tests: `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1:50-79` (rows "H2 codex preimplementation gate denies that epic/parallel delegation ..."). Each row runs `Mock Join-Path { throw ... } -ParameterFilter { $ChildPath -eq 'feature-folder-resolution.ps1' }` (lines 52 and 68), then `. $script:CodexGateHook` in-process (lines 54 and 70). It then asserts `$script:OrchestrationFeatureFolderResolutionImportFailure | Should -Be 'feature-folder-resolution.ps1'` (lines 55 and 71). Only line 41 assigns that value: a Grep of `.codex` for `OrchestrationFeatureFolderResolutionImportFailure\s*=` returns only modes lines 36 (`$null`) and 41.
- junit, main `pester-junit.xml:13413-13414`: both H2 deny rows report `status="Passed"`, classname `...\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1`.
- Not executing line 41: the M9 rows (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1:198-214`) assign the variable directly (line 202). They test the predicate's reaction, not the catch body.

### Gaps 2 and 3: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:206-207`

- Current content, unchanged since #903 (`.codex/hooks/...-epic-scope.ps1:203-209`): 203 `if ($outcome.Outcome -eq 'none') {`; 204 `return $null`; 206 `if ($outcome.Outcome -eq 'deny') {`; 207 `return Get-OrchestrationPreimplementationGateBlockDecision -Reason $outcome.Reason`; 209 `return Get-OrchestrationPreimplementationGateAllowDecision`.
- Main, run 38730332356, `.codex/hooks` package, `powershell-coverage.xml:20129-20189`. In the function `Get-OrchestrationEpicScopeDecision` (lines 182-209):
  - Covered: 182, 185-189, 193, 194, 196, 198, 199, 201, 203, 204 (`ci` 1 or 2).
  - Not covered: `<line nr="183" mi="1" ci="0" .../>`, `<line nr="190" mi="1" ci="0" .../>`, `<line nr="191" mi="1" ci="0" .../>`, `<line nr="206" mi="1" ci="0" mb="0" cb="0" />`, `<line nr="207" mi="1" ci="0" mb="0" cb="0" />`, `<line nr="209" mi="1" ci="0" .../>`.
- Run 38423196404 (`:20046-20065`) has the identical pattern. The #903 investigation (`docs/features/active/2026-10-11-round-2-review-nits-and-evidence-timestamps-903/evidence/other/rem1-ri2-investigation.2026-10-13T15-21.md:6, 14-72`) records that the local full-run XML is identical to CI row by row. The effect is deterministic and not CI-specific.
- The `.claude/hooks` copy, same XML (`:4397-4408`): the equivalent decision tail (`.claude/hooks/...-epic-scope.ps1:245-266`) is covered on lines 245-264 and 266, including the deny return 264 (`ci` 1) and the allow return 266 (`ci` 1).
- ES-D1 (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1:74-85`):
  - The suite dot-sources the canonical `.codex` file in-process in `BeforeAll` (line 21: `. (Join-Path $script:RepoRoot '.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1')`).
  - It defines in-memory stand-ins for the two gate decision constructors (lines 30-50) and mocks `Resolve-EpicScopeCheckpoint` (line 68).
  - It calls `Get-OrchestrationEpicScopeDecision -Command '' -FilePath 'scripts/powershell/Sample.ps1'` directly (line 79) and asserts the exact deny reason (line 83). Only the stand-in returns that reason, and only line 207 calls the stand-in.
  - There is no `Start-Process`, `ProcessStartInfo`, child `pwsh`, `Invoke-Command`, or new runspace in the file.
- junit, main `pester-junit.xml:12512`: `ES-D1 denies a path leg ... status="Passed"`.
- Internal inconsistency that excludes "not executed": line 201 is the body of the `-ReadinessFailure` scriptblock and has `ci` 1. `Resolve-OrchestrationEpicTargetOutcome` (`.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1:395-423`) invokes that scriptblock only on the `evaluate` verdict, and every such call returns Outcome `deny` or `allow`. Within one compiled instance of the function, any call that executes line 201 must then execute line 206. Line 201 records a hit and line 206 does not, so the two hits were recorded against different compiled instances.

### Test execution order (job log of run 38423196404)

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` ran at 15:41:28 (log line 1072). Its `codex` `-ForEach` row dot-sources `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (Parity.Tests.ps1:21, 25), which loads the Codex modes and epic-scope siblings. Its baseline mocks make the session root non-epic, which drives the epic-scope decision through the `none` path.
- The Codex suites that execute the gap lines ran about eight minutes later: `...-epic-scope.Decision.Tests.ps1` at 15:49:39 (line 1303), `...-epic-scope.Tests.ps1` at 15:49:40 (line 1304), and `codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` at 15:50:01 (line 1325). The whole `claude-lib` tree ran in between (lines 1173-1237).
- The covered lines of `Get-OrchestrationEpicScopeDecision` (182, 185-189, 193-199, 203-204) are exactly the lines on the `none` path. The uncovered lines (183, 190-191, 206-209) are exactly the lines that only the later Codex suites reach. Line 201 is the one exception: it sits in a nested scriptblock that first ran in the later suites (see Root Cause).

## Root Cause

### Mechanism (shared by all three gaps); status: likely, not experimentally verified

1. CI uses breakpoint-based coverage. `UseBreakpoints` is unset and defaults to `$true` in Pester 5.x. `SingleHitBreakpoints` defaults to `$true`. Breakpoints are set once, before the tests run (log line 1006).
2. PowerShell binds a pending line breakpoint to the sequence points of the first compiled instance of the file that is entered and contains that line. It then removes the breakpoint from the pending set (`debugger.cs`, `SetPendingBreakpoints`: `breakpoints.TryRemove(breakpointId, out _);`). The binding map is a `ConditionalWeakTable` keyed by the compiled block's `IScriptExtent[]` sequence-point array, not by file path.
3. A bound breakpoint is moved back to pending only when `RegisterScriptFile` sees different contents for the path, or sees that the weakly held old contents were collected (`oldScriptContents == null || !oldScriptContents.Equals(scriptContents, StringComparison.Ordinal)` followed by `UnbindBoundBreakpoints`). Recompiling an unchanged file does not rebind. The bound breakpoint's own `SequencePoints` reference the old extents and therefore the old script text, so the weak reference most likely stays alive. This last link is an inference from the type structure and was not observed.
4. Dot-sourcing a file reuses the compiled instance only through the script-block cache, keyed by `(fileName, fileContents)`. A cache hit returns `scriptBlock.Clone()`, which shares `CompiledScriptBlockData` and its sequence points. The whole cache is cleared once it holds more than 1024 entries (`CompiledScriptBlock.cs`: `if (s_cachedScripts.Count > 1024)` then `s_cachedScripts.Clear();`). After a clear, the next dot-source parses and compiles a new instance with no breakpoints bound to it.
5. Consequence: a line that the first compiled instance never executes keeps an orphaned breakpoint. A later suite that executes it in a new instance produces no hit. Nested scriptblock bodies, such as epic-scope line 201, compile lazily and stay pending until they first run, so they bind correctly even in a later instance.

The repository has a precedent for this failure family. `scripts/powershell/PoshQC/PoshQC.psm1:93-106` (issue #392 remediation cycle 2) records that "re-parsing and re-compiling a fresh ScriptBlock ... made Pester's code-coverage merge lose already-recorded hit credit". That module caches its parsed script blocks to avoid the problem.

No experiment has shown that a cache clear (or another recompilation) actually happens between 15:41:28 and 15:49:39 in the CI run. That link is the unverified part of the chain. The experiment under Verification Approach, step 1, resolves it.

### Gap 1 (modes:41)

- Verified: the line runs in-process in the coverage job (passing H2 rows; the asserted value is produced only by line 41). The test reaches it through a dot-source plus `Mock Join-Path`, which Pester can attribute.
- Verified: this is not an untested branch.
- Likely: lines 36 and 38 were attributed when the Codex modes file was first compiled (by the Codex leg of the Claude Parity suite). The breakpoint on 41 stayed bound to that instance, and the H2 rows ran 41 in a later instance.
- The Claude copy's line 41 is attributed. Its first compilation and its FailClosed suite run 1.3 minutes apart in the same `claude-hooks` folder (log lines 1056 to 1129), which is consistent with no recompilation in between. This is consistent with the mechanism but does not prove it.

### Gaps 2 and 3 (epic-scope:206, 207)

- Verified: ES-D1 dot-sources the canonical `.codex` file in-process and calls the function directly. The function, child-process, runspace, stub-file, bundled-copy, and duplicate-basename hypotheses are each excluded by the file evidence above.
- Verified: the hit on 201 together with the miss on 206 cannot come from a single compiled instance.
- Likely: the same stale binding as Gap 1. Lines 183, 190, 191, and 209 of the same function are part of the same anomaly. They are not in this issue's scope, but the same documentation note covers them.

### Not the cause (verified)

- Separate runspace or child process: none in either suite.
- Different file loaded: both suites load `.codex/hooks/...` through `$PSScriptRoot`-relative or repo-root-relative paths. Bundled copies are not in the population.
- Duplicate basename: hits are keyed by absolute path, and the CoverageGutters XML separates the entries by `<package name=...>`. The Claude entries show their own independent hits.
- Failing or skipped rows: all relevant rows report `Passed` in run 38730332356.

## Recommended Fix

Selected approach: document the cause and attach the existing executing tests to it, with evidence from a single-suite coverage run. No production, coverage-configuration, or workflow change. This meets the issue's Expected Behavior clause "the cause of the non-attribution is documented with a test that covers the line". The covering tests already exist and assert line-unique effects, so adding another full-run test would not change attribution: a new row would run in the same later compiled instance.

Files the fix touches, one per line:

```
tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/<timestamp>-isolated-coverage-attribution.md
```

Per-file rationale:

- `tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1` (currently 80 lines; about 90 after the change). Add a paragraph to the `.DESCRIPTION` header. It should state that the H2 deny rows execute modes line 41, cite the line-unique assertion at lines 55 and 71, say that full-run breakpoint coverage may report the line as `ci` 0 because of breakpoint binding to the first compiled instance, and point to the #936 evidence file. No test-logic change.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` (currently 97 lines; about 107 after the change). Add the same kind of paragraph to the `.DESCRIPTION` header for lines 206-207 (ES-D1) and 209 (ES-D2), naming the exact-reason assertion at line 83 as the proof of execution. No test-logic change.
- `docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/evidence/qa-gates/<timestamp>-isolated-coverage-attribution.md`. Record the single-suite coverage results (Verification Approach, step 1) and the CI `poshqc / PowerShell QC` element values (step 2). The `<timestamp>` follows the evidence timestamp convention.

Explicitly not touched:

- Production hooks: none. Mirror family for reference only, in case a later decision requires a hook edit (8 files: 2 hooks x 4 surfaces): `.claude/hooks/`, `.codex/hooks/`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, each holding `enforce-orchestration-preimplementation-gate-modes.ps1` and `...-epic-scope.ps1`.
- Coverage configuration: none (`config/poshqc-coverage.json` and `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` unchanged).
- CI workflow: none (`.github/workflows/_poshqc.yml` unchanged).
- `scripts/powershell/PoshQC/README.md`: not recommended. It is mirrored at `extensions/drm-copilot/resources/powershell/PoshQC/README.md`, so a note there would require a mirror edit and bundle-parity verification. The test headers put the note where it is used.

Rejected alternatives:

- Set `CodeCoverage.UseBreakpoints = $false` (profiler tracer) in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its mirror `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. This would likely fix attribution itself, because the tracer records hits by file position, not per compiled instance. It was rejected as the minimal fix because:
  - it changes measurement for all 202 files and for every extension consumer of PoshQC;
  - Pester 5.x labels the option EXPERIMENTAL;
  - it may affect `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` and `PoshQC.CoverageConfig.Tests.ps1`, which reference the runsettings;
  - it would shift the per-file figures that #884 is working on.

  It is retained as an open question for the operator.
- Add a new test for modes:41. Rejected because existing H2 rows already execute the line, and another full-run row would hit the same orphaned binding.
- Reorder suites, or make the first-compiling suite execute the lines. Rejected because it is fragile: it depends on discovery order and script-cache occupancy.
- Manipulate Pester's breakpoints from a test. Rejected because it couples tests to the coverage engine.

## Verification Approach

PowerShell verification follows Option A: PoshQC MCP tools locally, plus CI evidence. The PoshQC MCP test tool's result summary carries no per-line output, so per-line evidence must come from a coverage XML on disk or from the CI artifact.

1. Single-suite attribution (decisive for the mechanism). Run each of the two Codex suites alone with coverage scoped to the one hook file:
   - `Run.Path` = the test file;
   - `CodeCoverage.Path` = `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` or `...-epic-scope.ps1`;
   - `CodeCoverage.OutputFormat` = `CoverageGutters`, with the output written to the feature evidence folder.

   Expected result if the mechanism holds: `<line nr="41" ... ci="1"`, and `<line nr="206" ... ci="1"`, `<line nr="207" ... ci="1"`, `<line nr="209" ... ci="1"`. Record the line elements in the evidence file. If the single-suite run also reports `ci` 0, the mechanism is refuted, and the gap must be re-investigated before any documentation is written.

   This needs a direct Pester invocation with a custom configuration. The MCP runner uses installed-extension settings and does not accept a per-file coverage path, so the operator or a session with `pwsh` access may need to run this step (see Automation Feasibility).
2. CI confirmation. In the PR head's `poshqc / PowerShell QC` job (windows-latest; the Linux hook job has no coverage), download artifact `poshqc-test-results` and check:
   - `powershell-coverage.xml`, inside `<package name="D:/a/drm-copilot/drm-copilot/.codex/hooks">`:
     - `<sourcefile name="enforce-orchestration-preimplementation-gate-modes.ps1">`, element `<line nr="41" .../>`;
     - `<sourcefile name="enforce-orchestration-preimplementation-gate-epic-scope.ps1">`, elements `<line nr="206" .../>` and `<line nr="207" .../>`.

     Under the selected fix these are expected to remain `ci="0"`, and the evidence file records them as the documented exception. If the tracer alternative is chosen instead, all three must read `ci` of at least 1.
   - Do not match on `sourcefile name` alone. The `.claude/hooks` package holds entries with the same basename, at lines 4355 and 4594 on main.
   - `pester-junit.xml`: the H2 codex deny rows (`preimplementation gate modes handler proof on the codex surface.H2 codex preimplementation gate denies ...`) and `Codex epic-scope decision tail (issue #903).ES-D1 ...` / `ES-D2 ...` report `status="Passed"`.
3. Toolchain: PoshQC format, analyze, and test on the two edited test files through the MCP tools. Line counts of both files are well under 500.

## Scope Boundaries

- #884: works on per-file coverage of `.claude/lib/bash/compute-concurrency-batches.sh` (bash half) and `.codex/hooks/validate-feature-review-coverage.ps1` (PowerShell half; `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/issue.md:14, 40-42`). The recommended fix touches none of these files and no coverage configuration, so there is no overlap. The rejected tracer alternative would overlap in effect, because it changes the measured coverage of `validate-feature-review-coverage.ps1`. This is one more reason it needs an operator decision.
- #935 (`docs/features/potential/promoted/2026-10-15-hook-test-isolation-737-remainder.md`):
  - F-3 (isolation guard detection of `Join-Path <root-variable> '<name>.ps1'` hook loads and ProcessStartInfo suites): both recommended test files load their hook through `Join-Path` with a root variable (`FailClosed.Tests.ps1:18-19`, `Decision.Tests.ps1:21`). F-3 might therefore flag them, but it changes the guard helper, not these files.
  - N-2 (optional `-Surface` to `-Scope` rename): both files call `Register-EpicStateBaselineMock ... -Surface` (`FailClosed.Tests.ps1:21-26`, `Decision.Tests.ps1:24-25`). If N-2 proceeds, it edits lines in the same two files.
  - The #936 change is confined to the `.DESCRIPTION` header blocks (`FailClosed.Tests.ps1:3-14`, `Decision.Tests.ps1:4-16`), which do not intersect the `-Surface` call lines, so a textual merge conflict is unlikely.
  - I-3 (four 500-line files) and the F-1/F-2 flagged suites (#903 issue.md:233) do not include either file. Both files are at 80 and 97 lines.
  - Overlapping files: the two test files above, with N-2 only. No overlap with F-3's guard file, I-3, or F-1/F-2.

## Risks and Open Questions

1. The mechanism is likely, not verified. The decisive check is the single-suite run (Verification step 1). Whether a script-cache clear (more than 1024 entries) actually occurs between the Parity suite and the Codex suites is inferred, not observed. Another recompilation trigger is possible, but the conclusion and fix would be the same.
2. Operator decision: should the repository switch to the profiler tracer (`UseBreakpoints = $false`) to make attribution correct repo-wide? This changes measurement for every file and for extension consumers, and the option is EXPERIMENTAL in Pester 5.x. A one-off CI dispatch with the flag set would show the effect before any commit.
3. Same-class lines outside the issue: Codex epic-scope 183, 190, 191, and 209 (#903 PA-2), and possibly Codex targets line 167 (#903 exemption c, not checked here). Should the documentation note name them as well? The recommendation names 209 because ES-D2 lives in the same suite.
4. Pester version drift: `PoshQC.psm1:57` pins 5.6.1, but the CI log reports 5.9.0 already present. This does not affect the mechanism (both are 5.x breakpoint mode), but the reported version in #903 evidence is inaccurate.
5. The modes:41 non-attribution depends on run order and cache occupancy. Adding or removing unrelated suites could make it appear or disappear. Reviewers should not treat a future `ci` 1 or `ci` 0 on these lines as a regression signal by itself.

## Automation Feasibility

- Header edits, PoshQC format, analyze, and test through the MCP tools, and the CI artifact download and Grep checks need no human interaction.
- Verification step 1 needs a direct Pester invocation with a per-file `CodeCoverage.Path`. The PoshQC MCP test tool returns no per-line output and uses installed-extension settings, and agent worktrees deny command text containing `pwsh`. Step 1 may therefore need the operator, or a session permitted to run `pwsh`, to execute one Invoke-Pester command per suite. That command is the only human-interaction point identified.
- Open question 2 (tracer switch) needs an operator decision, not automation.

## Numeric Derivation Evidence

Numeric claim: the hook mirror family has 8 files (2 hooks x 4 surfaces). It is informational only; no `spec.md` acceptance criterion is proposed on it.

- Complete Family: every repository file named `enforce-orchestration-preimplementation-gate-modes.ps1` or `enforce-orchestration-preimplementation-gate-epic-scope.ps1`.
- Exhaustive Search Scope: the whole worktree.
- Inclusion Rules: an exact basename match.
- Exclusion Rules: test files (`*.Tests.ps1`) and documents.
- Primary Search Strategy or Query Expression: Glob `**/enforce-orchestration-preimplementation-gate-{modes,epic-scope}.ps1` at the worktree root.
- Primary Member Set: `.claude/hooks/{epic-scope,modes}`, `.codex/hooks/{epic-scope,modes}`, `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/{epic-scope,modes}`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/{epic-scope,modes}`.
- Primary Count: 8.
- Cross-check Search Strategy or Query Expression: a ripgrep content search (Grep tool, pattern `\A`, mode `files_with_matches`) over the worktree with file glob `**/enforce-orchestration-preimplementation-gate-{modes,epic-scope}.ps1`. It enumerates by ripgrep's file walk and content match, not by the Glob tool's path matcher.
- Cross-check Member Set: the same 8 paths.
- Cross-check Count: 8.
- Member-set Comparison: the normalized sets are identical (8 = 8). No member is missing or duplicated.
