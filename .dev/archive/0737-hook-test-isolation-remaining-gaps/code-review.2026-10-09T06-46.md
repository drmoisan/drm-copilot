# Code Review: Hook test isolation remaining gaps (#737, bundled #746)

**Review Date:** 2026-10-09
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737`
**Feature Folder Selection Rule:** The folder whose numeric suffix (737) matches the issue number supplied by the caller and the branch name.
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` (commit `7eef473959317fdebcac8a8d902baccc990fe46d`)
**Head Branch:** `bug/hook-test-isolation-remaining-gaps-exec-737` (commit `60eabbf334871031f12ac870562df1e64da9c600`)
**Review Type:** Initial review

---

## Executive Summary

The branch is a test-only change set of 119 PowerShell test and helper files (11 added, 108 modified) plus feature documents and evidence. It delivers a discovery guard over both hook surfaces (suite enumeration, string-literal closure scanning, seam census, compliance forms F1/F2/F3), an interception probe, hardening of the guard predicate against five false-pass paths, seven new predicate-branch rows, baseline null mocks and a probe row in 105 flagged suites, a third scan root (`.codex/hooks`) for the no-Python guard, a behavioral parity test for the two preimplementation gates, a `GENERATED_AGENT_FAMILIES` parity test, and the #746 helper fix. The reviewer confirmed with `git diff` that no file under `.claude`, `.codex`, `extensions`, `scripts`, `config`, or `src` changed, that no file exceeds 500 lines, that no added line uses a temporary-file, clock, RNG, network, or interpreter token, and that the final run (8430 tests, 0 failures, 10 pre-existing skips) is recorded in a JUnit file newer than the last code commit.

Implementation quality is high. Pure AST and text functions are separated from the two file-boundary readers, every guard function takes an injectable reader so fixtures run over in-memory text, each guard has compliant and non-compliant fixtures plus a non-vacuity row, and fail-before evidence exists for each new guard. The findings below are refinements of the guard's strength and of two documented trade-offs. None blocks the pull request.

**What changed:**
Helper layer under `tests/scripts/claude-hooks/`: `EpicStateIsolation.Discovery.Helpers.ps1` (259 lines), `EpicStateIsolation.Compliance.Helpers.ps1` (207), `EpicStateIsolation.Baseline.Helpers.ps1` (177), and the rewritten predicate `EpicStateIsolation.Helpers.ps1` (474; 327 additions, 51 deletions). Guard suites: `...Discovery.Tests.ps1`, `...Predicate.Tests.ps1`, `...Branches.Tests.ps1`, `...Probe.Tests.ps1`, and the reduced legacy guard (5 additions, 29 deletions, fixed list and D9 note removed). Parity: `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` and `.Parity.Cases.ps1` under `claude-hooks`, `CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` under `claude-lib/codex-routing`. No-Python: `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (new) and the guard suite (34 additions, 46 deletions). #746: `codex-pretooluse-integration.Tests.ps1` (53 additions, 7 deletions). 104 further suites receive a baseline mock block and one probe row (typically 5 to 15 added lines each).

**Top 3 risks:**
1. The guard accepts any `Mock` that is not inside a nested script block or function, so a mock placed in a conditional branch counts as isolation (F-1). The four named seams are protected by the runtime probe; the hook-local extra seams are not.
2. The guard locates suite closures and process-spawning suites through `hooks/<name>.ps1` string literals, and two suites build the hook path from parts (F-3). A future suite written the same way is invisible to the guard.
3. The E4 fix makes one spawned handler run in a launcher context that returns before reading any checkpoint (F-4). The native-context decision for that hook is covered by a single in-process row, so the child-process matrix tests less of that hook than before.

**PR readiness recommendation:** **Go** - 0 Blocker and 0 Major findings; the six Minor, two Nit, and three Info findings are non-blocking and are listed with optional follow-ups.

---

## Findings Table

Blocking findings: 0. Non-blocking findings: 11.

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (non-blocking) | `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` and 26 flagged suites | `Get-EpicStateIsolationDirectCommand`, lines 181 to 201; conditional mocks such as `CleanupWorktreeManifestGateMatrix.Tests.ps1` lines 225 to 228 | F-1. The guard excludes only commands inside a `ScriptBlockAst`, `ScriptBlockExpressionAst`, or `FunctionDefinitionAst` ancestor. A `Mock` inside an `if` clause body is therefore a direct statement, so `if ($false) { Mock X { $null } }` would satisfy form F1. 26 suites use `if (Get-Command X -ErrorAction SilentlyContinue) { Mock X { $null } }` for hook-local extra seams. Static reading of the predicate; not executed. | Treat a `Mock` whose ancestor chain includes an `IfStatementAst`, `SwitchStatementAst`, loop, or `TryStatementAst` as non-direct, except for the exact `if (Get-Command <same name> ...)` guard shape. Add a predicate row for the conditional-branch false pass. | A conditional mock can be skipped at run time without the guard noticing. The runtime probe covers only the four named seams, not the hook-local `Get-CheckpointContent` family. This is a false-pass class that CR-2 did not list, so it is outside the spec's R-C. | `grep -rln "if (Get-Command .* -ErrorAction SilentlyContinue) { Mock" tests/scripts` returned 26 files; the same pattern is absent from the base ref (`git grep` at `7eef473959` returned no match for it). |
| Minor (non-blocking) | `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` | `Get-EpicStateIsolationHookDotSource`, lines 154 to 179 (fallback at line 178) | F-2. The hook dot-source is found by a `hooks/<name>.ps1` literal, then by a variable bound to such a literal, and otherwise falls back to the first dot-source. The spec (R-C) asks for identification by closure file name. When a suite builds the hook path from parts, the fallback restores the original first-dot-source behavior that AC-8 was meant to remove. | Resolve the hook dot-source by comparing the dot-source argument's leaf string against the closure file names that the census already computes, and report a finding when no dot-source matches. | The fallback is silent. It keeps AC-8's false-pass reachable for suites outside the literal convention. All 182 current suites pass, so no current false pass is shown. | Code reading, lines 154 to 179. AC-8 rows pass for the literal shape (`pester-targeted.2026-10-09T06-22.md`, `AC-8 *` Passed=2). |
| Minor (non-blocking) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1`; `enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1`; `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | Discovery.Helpers lines 117 to 132 and 211 to 228; Probe.Tests header lines 19 to 22; pretooluse line 10 | F-3. Closure discovery and process-spawning detection depend on `hooks/<name>.ps1` string literals. The probe harness composes its Codex resolver path from segments so the guard does not classify it as a hook suite (stated in its header). `codex-pretooluse-integration.Tests.ps1` builds hook paths from `$script:HookRoot` and a name variable, so the census reports `process-spawning=False` although the suite spawns every registered Codex handler (plan DEV-2 text; report line `DEV-2: ... NOT-IN-REPORT`). | Record the literal-convention limit in the guard file header, and file a follow-up to detect `Join-Path <root-variable> '<name>.ps1'` hook loads and `ProcessStartInfo` suites with variable-built script paths. | AC-5 (report process-spawning suites) is satisfied for literal-named hooks only. The known unreported case (E4) was fixed by a test edit; an unknown future case would not be reported. | `evidence/other/process-spawning-report.2026-10-09T05-29.md` (`REPORT-TOTAL: 6`, `DEV-2:` line); `evidence/regression-testing/dev2-e4-isolation.2026-10-09T04-06.md`. |
| Minor (non-blocking) | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Invoke-CodexHookProcess`, lines 95 to 99; new row at line 223 | F-4. To isolate E4 from the local item checkpoint, the child launched for `enforce-epic-wave-barrier.ps1` receives `CODEX_EPIC_CHILD_LAUNCH_ID` and `CODEX_EPIC_CHILD_EXECUTION_CONTEXT=epic_preparation_child`, a context in which the hook returns allow before it reads a checkpoint. The existing matrix row `allows every registered handler for every tool name its own matcher admits` therefore no longer exercises the native-context path of that one hook for each tool name. One in-process row (`DEV-2 wave barrier allows a benign Bash payload ...`) covers the native decision for a benign Bash payload with an empty checkpoint. No assertion text was removed. | Extend the in-process row to iterate the tool-name matrix with `Invoke-CodexEpicWaveDecision` and an empty checkpoint, or file a follow-up for an injectable repository root in the hook (out of scope here because production code is frozen). | The edit is documented (DEV-2), minimal, and the alternative was to leave a suite failing whenever a local checkpoint exists. It still narrows what the process-level matrix proves for one hook. | `git diff` of the file (hunks at new lines 92 to 99 and 223 to 230); `evidence/baseline/pester-full-baseline.2026-10-09T02-42.md` (baseline `Failed: 1` from this row); `evidence/qa-gates/pester-full.2026-10-09T06-33.md` (`Failed: 0`). |
| Minor (non-blocking) | `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` | Row `AC-19 extractor detects a divergent member`, lines 87 to 94; extractor regex line 31 | F-5. The divergent-member row asserts that the sorted text of a fixture-extracted set differs from the module set. It does not drive the Python-equality assertion (line 103) with a divergent text, so it shows that a comparison would see a difference but not that the equality row fails. The extractor requires the `frozenset({...})` form; a reformatted literal causes a thrown "no declaration" error (fail-closed, not a false pass). | Factor the equality assertion into a function that takes the two sets, and call it with the divergent fixture inside `Should -Throw`. | Strengthens AC-19's "text with a divergent member fails" from comparison-difference to assertion-failure. Current behavior is correct and fail-closed. | Test file lines 28 to 63, 83 to 108; `pester-targeted.2026-10-09T06-22.md` (`AC-19 *` Passed=9, Failed=0). |
| Minor (non-blocking) | `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1` | Lines 25 and 79 to 94 | F-6. `$script:EpicStateParseCache` is a script-scope memo keyed by the complete source text. `.claude/rules/powershell.md` asks to avoid mutable script-scoped variables. The memo is deterministic, but it retains every parsed text and AST for the session. | Key by a content hash, or accept the cost and note the exception in the file header. | Repository PowerShell standard; low practical risk at 182 suites. | Code reading; the full run passed (8420 passed, 0 failed). |
| Nit | `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` | Header lines 5 to 6 | N-1. The header says the helper is dot-sourced "by the scan-root rows file when that file exists". No such file exists; the five scan-root rows live in `enforcement-hooks-no-python-invocation.Tests.ps1`. | Remove the clause. | A conditional reference to a nonexistent file is a stale comment. | `ls tests/scripts/claude-runtime/` lists no scan-root rows file. |
| Nit | `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | Line 101 | N-2. `Register-EpicStateBaselineMock -Seam 'Get-PrdFeatureCheckpointFolder' -Surface 'Codex'` is used in a Claude-hook suite to select script-scope mocking. The parameter is named `Surface` but acts as a mock-scope switch. | Add a short comment at the call, or rename the parameter to `Scope` in a later change. | Avoids a misleading reading of the call. | `grep -n "Surface 'Codex'"` on the file returned line 101. |
| Info | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1` | Seven `AC-13 non-compliant ...` rows | I-1. Six of the seven AC-13 branch rows pass against the unmodified predicate, so the literal "fails before" wording holds for one row (the parse-error row). The plan records the interpretation (PI-3) and an absence-of-test dossier showing no row for these branches existed on the base ref. | None required. Keep the dossier with the evidence. | The rows close a test gap (the CR-3 finding) rather than a behavior gap; a failing-before run is impossible for already-correct code. | `evidence/regression-testing/predicate-fail-before.2026-10-09T03-04.md`; `fail-before-exception.2026-10-09T03-05.md` (`SearchResult: none`). |
| Info | `evidence/qa-gates/suite-counts-before-after.2026-10-09T06-17.md` | AC-23 comparison | I-2. Before and after Passed counts are equal only after subtracting probe rows (plan PI-1), and two suites are compared by `Failed=0` (the guard suite and E4, whose baseline `Failed` was 1). The literal "counts are equal" cannot hold because AC-6 requires an added probe row per suite. | None required. | The comparison rule is stated in the artifact and applied uniformly. | `COMPARE-DIFFERENT-COUNT: 0` in the artifact; PI-1 text in the plan. |
| Info | `enforce-epic-worktree-removal-gate.Tests.ps1`, `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` (codex), `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`, `EnforcementHooksNoPythonInvocation.Helpers.ps1` | Whole file | I-3. Four files sit at exactly 500 lines. The cap is "may not exceed 500", so they pass, but any further addition forces a split. | Split before the next edit to any of the four. | Prevents a future cap violation. | `wc -l` run by the reviewer. |

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The guard is built from small pure functions over an injected reader (`-ReadSource`), so every compliance form, the closure computation, and the unparseable-suite path are tested over in-memory text. No function creates a file or runs a process.
- The probe proves interception by effect, not by placement. It registers hostile in-memory payloads for the lower seams, calls the exported resolver, and asserts the result reason `epic-checkpoint-absent-or-unparseable`, one baseline-mock invocation, and zero hostile reads. The harness suite shows the probe fails when the mock is bound to a different module instance (`AC-6 probe fails when the baseline mock is bound to a different module instance`).
- CR-2 fixes are implemented as separate, readable steps: outermost `BeforeAll` blocks are all evaluated (`Get-EpicStateIsolationOutermostBlock`), every `Mock` of a seam is evaluated (`Get-EpicStateIsolationPairFinding`), nested script blocks and function bodies are excluded, and the import is matched by a parsed path argument with a separator-anchored regex (`Test-EpicStateIsolationModulePathNode`).
- The census uses AST function definitions rather than regex over file text, and separates module seams, hook-local seams, cwd-derived resolvers, and default-parameter seams (`Get-EpicStateSeamCensus`).
- The parity test uses a data-only case table with a declared divergence list that is checked in both directions (undeclared and stale), and an AST function-inventory check; it uses no hash and no text comparison. `Describe -ForEach` dot-sources exactly one gate per scope.
- The #746 fix is minimal (`return , $registrations.ToArray()`), and the replacement assertion helper fails for both `$null` and an empty array (`Assert-RegistrationSetNotEmpty`, with rows that prove each rejection).
- Mocks in the two WorktreeResolution suites use `-ParameterFilter` that admits only committed fixture paths (`*tests?fixtures*`), so fixture reads remain real while gitignored reads are blocked.

#### API and safety notes

- Helpers use `[CmdletBinding()]`, mandatory parameters, `[ValidateSet]`, and `[OutputType]`. `Register-EpicStateBaselineMock` accepts an empty collection explicitly (`AllowEmptyCollection`), which supports the `-ForEach` shape with no extra seams.
- Approved verbs and singular nouns are used. PSScriptAnalyzer reports 0 findings across 120 files.
- The process-start cmdlet name is assembled from two fragments in the detector so the file never holds it as one token (`Discovery.Helpers.ps1` line 221). The same concern applies to the families test (`('Start-' + 'Process')`). This is deliberate and commented.
- The leading-comma idiom is applied where a single-element array must survive the pipeline (`Get-ModuleFamilySet`, `Get-ConfigFamilySet`, `Get-PythonFamilySet`, `Get-CodexPreToolUseRegistration`, `Get-GuardedPowerShellFile`).

#### Error handling and logging

- Guard failures are finding strings in the form `<path>: seam <name>: <violated rule>`, asserted by content (`AC-4 helper form naming the wrong seam is a finding`). Missing and unparseable suites produce a finding naming the path (`AC-2 missing suite yields a finding`, `AC-2 unparseable suite yields a finding`).
- `Invoke-EpicStateInterceptionProbe` throws on an empty seam list, an unknown seam name, and a Codex request for a Claude-only seam, so misuse fails loudly.
- One `catch` swallows an expected parameter-binding error after the seam call (`Baseline.Helpers.ps1` lines 86 to 88). It logs through `Write-Verbose` and carries a comment explaining that only the invocation counts matter. This is acceptable and narrow.

---

## Test Quality Audit

The guard and parity tests are well constructed: each guard has compliant and non-compliant fixtures, a non-vacuity row, and a missing or unparseable input row; every CR-2 path and CR-3 branch has a named row; the fail-before evidence shows the guards fail against the unedited suites (104 failing `AC-4` rows in `discovery-guard-fail-before.2026-10-09T03-18.md`) and pass after. The with and without hostile-checkpoint differential (5258 tests, every suite `EQUAL`) is the strongest integration evidence that the mocks isolate local state.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` - per-suite compliance and probe-presence rows generated from directory enumeration; contains a self-check that the file holds no hard-coded suite literal. Gap: relies on `hooks/<name>.ps1` literals (F-3).
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` and `...Branches.Tests.ps1` - paired compliant and non-compliant fixtures for AC-8 to AC-13; in-memory text only.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1` - probe pass and fail rows and surface rows; unloads the module family first so the rows measure only the mock binding (commit `0f24b15d`).
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` - 80 behavior rows over five case tables for two runtimes, declared-divergence check with a failing-fixture row, function-inventory check with a failing-fixture row.
- `tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1` - three-way set equality with non-vacuity rows (see F-5).
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` - five scan-root rows including a codex-hooks enumeration row and the retained `extensions/*` exclusion.
- `evidence/qa-gates/pester-full.2026-10-09T06-33.md`, `coverage-total.2026-10-09T06-33.md`, `local-state-differential-after.2026-10-09T06-17.md`, `evidence/regression-testing/*fail-before*.md` - full-run result, coverage, differential, and fail-before records.

### Quality assessment prompts

- **Determinism:** No clock, RNG, sleep, network, or temporary-file token in any added line. Suite and closure enumeration are ordinal-sorted. The population run passes identically with and without a local checkpoint. A randomized-order run was not performed; the suites are independent by construction.
- **Isolation:** One behavior per row; probe mocks are registered inside the calling `It`, and the helper orders the epic-scope branch last because it registers a hostile mock that would otherwise shadow the suite's run-seam mock (documented in `Invoke-EpicStateInterceptionProbe`).
- **Speed:** The new suites start no process. The configured run took 412 s in total (`pester-junit.xml`); no per-suite duration comparison exists.
- **Diagnostics:** Findings include suite path, seam, and rule; `-Because` text is present on guard and parity assertions.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Added lines contain only synthetic paths (`/synthetic-worktrees/...`) and synthetic JSON payloads. |
| No unsafe subprocess or command construction | PASS | No process launch in new suites. E4's existing `ProcessStartInfo` use is unchanged except for two environment variables with fixed literal values. |
| Input validation at boundaries | PASS | Probe and helper validate surface and seam names; the families extractor throws on zero declarations. |
| Error handling remains explicit | PASS | See Error handling and logging above. |
| Configuration and path handling is safe | PASS | All paths resolve from `$PSScriptRoot`; the families test reads `config/orchestration-routing.json` and `scripts/dev_tools/resolve_codex_deployment.py` as committed text. The scan-root helper keeps the `extensions/*` and `.claude/lib/bash/*` exclusions. |
| Production code untouched | PASS | Empty `git diff --name-only` over `.claude`, `.codex`, `extensions`, `scripts`, `config`, `src`. |
| Evidence location | PASS | `validate_evidence_locations.py --root .` exited 0; no path under `artifacts/` in the branch diff. |

---

## Research Log

No external research was required. The review relied on the repository rules (`.claude/rules/powershell.md`, `general-unit-test.md`, `general-code-change.md`, `quality-tiers.md`, `tonality.md`), the feature spec and plan, and local git and file inspection.

---

## Verdict

The change is ready for the normal pull-request flow. It satisfies the scope the spec defines, leaves production code unchanged, meets the 500-line, coverage, determinism, and no-temporary-file rules, and carries fail-before and fail-after evidence for each new guard. The final test evidence is tied to the final test content: the only commits after the last test change (`0f24b15d`) touch the feature folder.

The Minor findings F-1 to F-3 are guard-strength refinements that are outside the criteria in the spec and are suitable for a follow-up issue; F-4 is a documented trade-off; F-5 and F-6 are optional tightening. Blocking findings: 0. This conclusion matches the Findings Table and the Go recommendation above.
