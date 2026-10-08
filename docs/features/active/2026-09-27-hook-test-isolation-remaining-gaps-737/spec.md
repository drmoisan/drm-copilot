# 2026-09-27-hook-test-isolation-remaining-gaps (Spec)

- **Issue:** #737 (primary); #746 (bundled secondary)
- **Parent (optional):** epic #852 (`enforcement-hook-precision`), child C5b
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 0.2

## Context

#709 (PR #728) mocked the epic-checkpoint read in a fixed set of gate suites and added a structural guard that enumerates those suites from a hard-coded list. Gaps remain in four areas:

1. Suites outside the fixed list can read gitignored local orchestration state (`artifacts/orchestration/...`), on both the Claude (`tests/scripts/claude-hooks/`) and Codex (`tests/scripts/codex-hooks/`) surfaces.
2. The guard does not prove that a suite's mock intercepts the read, and the guard predicate can pass wrongly or has untested branches.
3. The no-Python guard (`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`) does not scan `.codex/hooks` (#707).
4. Two parity gaps carried over from closed issues: the main `enforce-orchestration-preimplementation-gate.ps1` across Claude and Codex (#555), and `GENERATED_AGENT_FAMILIES` between the Python authority and `CodexDeployment.psm1` (#646).

Bundled issue #746: `Get-CodexPreToolUseRegistration`, a test-local helper in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, returns `$registrations.ToArray()` without the leading-comma idiom, so a single registration unrolls to a scalar and #711 added workarounds.

This child executes after #736 (C5a), #732 (C1b), and #850 (C3) merge into `epic/enforcement-hook-precision-integration`. Those children change suites and hooks first, so the suite population is discovered mechanically at execution time and is not frozen in this document. #335 is closed as obsolete and is excluded.

Environment:
- OS/version: developer machines (CI has no local state)
- Python version: n/a (Pester)
- Command/flags used: the Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`
- Data source or fixture: #709 `evidence/other/follow-ups.md`; the #707 follow-ups; `research/research.2026-10-08T14-00.md`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low

## Repro & Evidence

Steps to Reproduce:
1. D8: epic gate suites may read `artifacts/orchestration/epic-orchestrator-state.json` (or other `artifacts/` state) without a mock. Research corrects the premise: after #690 the four named hook families read through absolute-path seams beneath resolver-produced roots and are largely hermetic by construction. Residual real reads exist (for example `Get-EpicMergeGateSessionWorktreeRoot` is unmocked in three merge-gate suites). The exposure must be re-derived on the integration branch.
2. D5: the Codex suites are not covered by #709's mocks or guard. Research corrects the premise "no `.codex` hook uses epic-scope resolution": #707 ported the resolver into the Codex gate family, and a script-scope `Get-EpicScopeCheckpointText` seam exists.
3. D9: the structural guard checks a hard-coded list of suites. The list is now eight suites, not seven, and a new suite that reads epic state is not caught.
4. Review findings:
   - CR-1: no test proves a suite's mock binds to the module instance the hook uses.
   - CR-2: the guard predicate has false-pass paths.
   - CR-3: guard branches are untested.
   - CR-7: a stale comment ("the three library modules are imported without -Force") in two `*.WorktreeResolution.Tests.ps1` suites.
5. #707: the no-Python guard scans only `.claude/hooks` and `.claude/lib`.
6. #746: the registration helper's unroll and the #711 workarounds.

Expected:
Every gate suite on both surfaces is hermetic against local orchestration state. The guards discover their targets instead of using fixed lists, and cover both surfaces.

Actual:
The gaps listed above.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: #709 and #707 follow-ups on main; research record cited above.

## Root Cause Analysis

Same class as #510: gitignored local state leaking into tests. Specific causes:

- Suite selection in the guard is by a fixed list (D9), so new or previously unlisted suites that load a closure containing a read seam are never checked.
- The predicate in `tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1` checks placement, not interception, and has these false-pass paths (CR-2):
  - Ordering is measured against the first dot-source command in the `BeforeAll`, not the dot-source of the hook, so an earlier helper dot-source lets a mock and import placed between the helper and the hook pass while binding to the wrong module instance.
  - The search covers nested script blocks (function bodies and similar), so a `Mock` or `Import-Module` inside a function that is never invoked satisfies the guard.
  - Only the first outermost `BeforeAll` is checked, so a file with several top-level `Describe` blocks passes if only the first isolates.
  - Only the first matching `Mock` of a seam is evaluated, so a later `Mock` of the same command with a non-null body is not seen.
  - The import match is a regex over joined element text, so any argument containing the module file name satisfies it, including a string that is not an import path.
- Predicate branches without a test row (CR-3): no outermost `BeforeAll`; parse error returned as a finding; ESR-side "import absent, mock present"; no dot-source at all in the `BeforeAll`; the `-ModuleName:value` colon-bound form; a `MockWith` body with a `param`, `begin`, or `process` block; a non-string module-name element.
- Codex suites that mock only some of the Codex gate seams, plus process-spawning Codex suites that launch hook scripts from the real repository root, can read local state.
- The no-Python guard and its detection helper are each at the 500-line cap, so a scan-root extension cannot be added in place.
- `Get-CodexPreToolUseRegistration` emits `$registrations.ToArray()` without wrapping, so PowerShell unrolls the array.
- Two parity gaps (main gate; `GENERATED_AGENT_FAMILIES`) are covered only by byte-identity or a hard-coded test copy that cannot detect a Python-only change.

## Scope & Non-Goals
- In scope:
  - A discovery guard over both surfaces with mechanical suite discovery, closure computation, and seam census.
  - Baseline hermetic mocks in every suite the guard flags.
  - CR-1 interception probe, CR-2 false-pass fixes, CR-3 predicate rows, CR-7 comment correction.
  - Extending the no-Python guard to `.codex/hooks`.
  - Preimplementation-gate behavioral parity test and `GENERATED_AGENT_FAMILIES` parity test.
  - #746 helper fix and removal of the #711 workarounds.
- Out of scope / non-goals:
  - Changes to production hook or library code (`.claude/hooks`, `.codex/hooks`, `.claude/lib`). Research found none required; a production defect surfaced by the census is recorded and handled as a separate decision.
  - #335 (closed as obsolete).
  - Adding a production seam (environment variable or injectable root); rejected in #709 D1(c).
  - Byte or normalized-text parity of the two main gates (bodies differ by design).
  - Running Python in any hook or in the new parity tests.
- Explicitly excluded systems, integrations, or datasets: the bundled mirror under `extensions/drm-copilot/resources/` is not scanned by the no-Python guard; no mirror exists for the test files in scope.

## Decisions

Orchestrator decisions on the research's open questions (numbered D1 to D10 in this spec; they are independent of #709's D-numbers except where stated):

1. **Seam set.** The discovery guard covers the epic-scope and worktree-run checkpoint-text seams (`Get-EpicScopeCheckpointText`, `Get-WorktreeRunCheckpointText`) and the item-checkpoint seams (`Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot`). None is advisory-only. This resolves research O1.
2. **Closure-wide baseline mocks.** A suite is in scope when the hook files it loads, plus their import closure, contain a seam, regardless of whether a given row reaches the seam. Over-inclusion is accepted and supersedes #709 D9's rejection. This resolves research O2 (option A).
3. **Read predicate.** The census predicate widens from `artifacts/orchestration/` to any `artifacts/` read, so the PR-context, PR-body, and receipt reads added by C3 (#850) are covered. This resolves research O3.
4. **Process-spawning Codex suites.** A census is performed at execution time. Any suite found to depend on local state is fixed. The guard reports, and does not fail on, process-spawning suites whose independence cannot be proven statically, and the report is recorded as evidence. This resolves research O4.
5. **Mechanical discovery at execution time.** Discovery runs on the integration branch after #736, #732, and #850 merge. This spec does not freeze a suite list. Acceptance criteria are verified by named Pester tests and their pass counts, not by a fixed list or a literal member count.
6. **Preimplementation-gate parity.** Behavioral parity over a shared case table with explicitly declared divergences (for example Codex-only `apply_patch` legs), following the existing `enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1` pattern. Byte identity of the bundled copies remains covered by existing tests and is not re-asserted.
7. **`GENERATED_AGENT_FAMILIES` parity.** A Pester test compares `CodexDeployment.psm1` (via `InModuleScope`) against a text parse of the Python literal in `scripts/dev_tools/resolve_codex_deployment.py`, with no Python executed. It replaces the hard-coded copy in `tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1` if appropriate.
8. **#746.** Return `,$registrations.ToArray()` in the test-local helper and remove the #711 workaround(s). Assertions must still fail on an empty or missing registration set. Research found no bundled mirror for that file; if any changed file has a mirror under `extensions/drm-copilot/resources/`, update it and keep bundle-parity tests green.
9. **No-Python guard split.** The guard and its helper are at the 500-line cap. Extending scan roots to `.codex/hooks` requires moving the scan-root definition and file enumeration into a new helper file.
10. **Constraints.** No Python in hooks; no temporary files in tests; 500-line cap per file; line coverage of at least 85% for any changed PowerShell production file; #335 excluded.

## Requirements

Design details below follow the research record; compliance forms and rules are normative for the guard, while exact file names are suggestions.

### R-A. Discovery guard (both surfaces)
- A1. Suites are every `*.Tests.ps1` directly under `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, computed by directory enumeration. The guard asserts each surface yields at least one suite (non-vacuity) and never asserts a literal count.
- A2. For each suite, the loaded-source closure is built by scanning string literals matching `hooks/<name>.ps1` and then transitively scanning string literals ending `.ps1` or `.psm1` in loaded files that resolve to existing files (beside the file or under `../lib/<dir>/`). Literal scanning, not dot-source statement scanning, is required because the closure includes variable-driven loads.
- A3. A seam is a function in a closure file whose body contains a read primitive (`Get-Content`, `[System.IO.File]::ReadAllText`, `ReadAllLines`) and either whose name matches `Checkpoint` or whose body or defining file contains an `artifacts/` literal (Decision 3). Seam classes: module text seams; hook-local content seams; cwd-derived resolvers (bodies containing `(Get-Location).Path`); default-parameter `[scriptblock]` seams (report-only unless a call omits the injection). The item-checkpoint seams are included (Decision 1).
- A4. A suite complies with a seam by one of three forms: (F1) a direct statement of the outermost `BeforeAll` declares a null-returning mock of the seam (module seams use `-ModuleName` and a preceding `Import-Module` without `-Force`, both after the hook dot-source; script-defined Claude or Codex seams are mocked without `-ModuleName`, after the dot-source); (F2) seam-under-test, where every direct call passes a literal path beginning `/synthetic-worktrees/` and the suite mocks `Test-Path` and `Get-Content` with a `-ParameterFilter` on that literal; (F3) for cwd-derived resolvers only, the outermost `BeforeAll` mocks the resolver to a `/synthetic-worktrees/` root. Suites within about ten lines of the 500-line cap may use a shared baseline helper function that registers the mocks, recognized by name.
- A5. For process-spawning suites (text contains `ProcessStartInfo` or the composed process-start token and names a hook script), the guard reports the hook launched and does not fail (Decision 4). The report is recorded as evidence.
- A6. The fixed `-ForEach` list and the D9 known-limit note in `enforce-gate-suites.EpicStateIsolation.Tests.ps1` are removed.

### R-B. CR-1 interception proof
- A shared probe runs inside each in-scope suite's own scope after the baseline mock exists. It registers hostile in-memory payloads for the lower seams (no file), calls the exported resolver by name, and asserts the resolver result reflects the baseline mock (`IsEpicScope` false with reason `epic-checkpoint-absent-or-unparseable`), that the suite's mock was invoked exactly once, and that the lower hostile read was invoked zero times. An equivalent probe covers `Get-WorktreeRunCheckpointText` and the item-checkpoint seams through an exported entry that reads them. The Codex surface uses the script-scope form without `-ModuleName`.
- The guard requires each in-scope suite to call the probe from inside an `It` (AST check).
- The `Should -Invoke` counting semantics for a root-level `BeforeAll` mock are confirmed by a first probe run before the probe is relied upon.

### R-C. CR-2 false-pass fixes
Predicate must: identify the hook dot-source by closure file name rather than the first dot-source; search only direct statements of the outermost `BeforeAll` (excluding nested script blocks and function bodies); evaluate every top-level `BeforeAll`; evaluate every `Mock` of a seam and reject a non-null body anywhere; and match the import by a parsed module-path argument rather than a regex over joined text.

### R-D. CR-3 untested branches
Predicate-discrimination rows over in-memory fixtures cover each branch listed in Root Cause Analysis, each with a compliant and a non-compliant fixture where meaningful.

### R-E. CR-7
The stale comment is corrected in `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` and `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` so that it names the modules actually imported without `-Force`, without a count that can go stale.

### R-F. No-Python guard on `.codex/hooks`
- Scan roots become `.claude/hooks`, `.claude/lib`, and `.codex/hooks`. The root definition and `Get-GuardedPowerShellFile`-style enumeration move into a new helper file shared by both surfaces.
- The mirror-exclusion assertion for `extensions/*` is kept. The "exactly two scan roots" comment and the roots assertion are updated.
- The extended guard is run first to confirm that no `.codex/hooks` finding exists; research expects none (static). A finding would be classified under the guard's existing carve-outs or recorded as a production defect.

### R-G. Preimplementation-gate parity
- A shared case table (data only) covers path classification, command classification (non-`apply_patch` forms), delegation classification, readiness, and decision rows. Each row has one expected value both runtimes must produce, or a declared per-surface expectation with a written reason.
- An AST function-inventory check asserts that each gate's function set equals the shared set plus a declared per-surface-only set, so an undeclared function or divergence fails.
- Per-runtime isolation follows the AttributionTrailer pattern (`Describe -ForEach` over the two runtimes with dot-sourcing in the per-runtime `BeforeAll`), with the Claude target resolver mocked to a synthetic root and the baseline epic-state mocks applied.
- The table is authored against the post-#732 gates at execution time. No text comparison is used.

### R-H. `GENERATED_AGENT_FAMILIES` parity
- A new Pester test file asserts: the `CodexDeployment.psm1` set equals `config/orchestration-routing.json` `codex_model_policy.generated_agent_families` (case-sensitive ordinal, via `InModuleScope`); the same set equals the families parsed from the Python literal's text in `resolve_codex_deployment.py`; each parsed set is non-empty using the leading-comma idiom.
- In-memory extractor rows show that zero declarations fail and that a divergent fixture fails.
- No interpreter is launched.

### R-I. #746
- `Get-CodexPreToolUseRegistration` returns `,$registrations.ToArray()`.
- The `@($null).Count` workaround at the registration count assertion is replaced by assertions that fail for both an empty array and `$null`.
- The documentation `Context` that exercises the legacy expression is replaced by rows that call the helper directly with `Get-Content` mocked to in-memory lines: one registration yields an array of one; zero registrations yields an empty array that is not `$null`.
- Unchanged assertions that remain sound under #711 are left as they are.

### R-J. Cross-cutting
- All new inputs are committed files or in-memory strings; no temporary files.
- Before-and-after Passed/Failed/Skipped counts are recorded for each edited suite from a direct `Invoke-Pester` run over an explicit file list.
- Fail-before evidence is recorded for each new guard by running it against the unedited suites. Evidence is written under `<FEATURE>/evidence/<kind>/`.

## Proposed Fix

### Design summary (what changes where):
Test-only change set: new discovery helper and discovery guard, a shared probe, edits to flagged suites (baseline mocks, probe call), split of predicate rows, a new no-Python scan-root helper, two new parity test files, and the #746 edit. Existing suites are edited only to add baseline mocks, the probe call, and the CR-7 comment.

### Boundaries and invariants to preserve:
Pass/fail outcomes of every edited suite are unchanged. Hooks are not modified. Byte identity between roots and bundled copies is unchanged.

### Dependencies or blocked work:
#736, #732, and #850 must be merged into the integration branch first.

### Implementation strategy (what changes, not sequencing):
Units: (1) measure-only census and discovery helpers; (2) discovery guard; (3) baseline mocks for flagged suites; (4) interception probe and CR-7; (5) no-Python guard extension; (6) preimplementation parity; (7) families parity; (8) #746.

#### Files/modules to change:
Under `tests/scripts/claude-hooks/`: `EpicStateIsolation.Helpers.ps1`, `enforce-gate-suites.EpicStateIsolation.Tests.ps1`, new discovery helper and guard files, new predicate-row file, flagged suites. Under `tests/scripts/codex-hooks/`: flagged suites and `codex-pretooluse-integration.Tests.ps1`. Under `tests/scripts/claude-runtime/`: the no-Python guard, its helper, and a new scan-root helper. Under `tests/scripts/claude-lib/codex-routing/`: a new families parity test and possibly `CodexDeployment.Parity.Tests.ps1`.

#### Functions/classes/CLI commands impacted:
Test helpers only. No production function changes.

#### Data flow and validation changes:
Suite and closure discovery at Pester discovery time from the committed tree.

#### Error handling and logging updates:
Guard findings name the suite, seam, and violated rule. Unparseable or missing suites produce a finding.

#### Rollback/feature-flag considerations (if applicable):
Revert the change set; no runtime effect.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Guard input: the committed tree. Output: Pester pass/fail rows and recorded census evidence.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
No production API change.

#### Performance constraints (latency/throughput/memory):
Discovery and AST parsing add bounded time to the PowerShell test run; no process spawning or network.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): a PowerShell route (PowerShell tool or PoshQC MCP tools) is available for direct `Invoke-Pester`; a root-level `BeforeAll` mock applies to child blocks (established by #709's probe) and its invocation count is observable via `Should -Invoke` (to be confirmed).
- Constraints (budget, performance, compatibility): no Python in hooks; no temporary files; 500-line file cap; deterministic tests; line coverage of at least 85% for any changed PowerShell production file.
- External dependencies (services, libraries, releases): #736, #732, #850 merged first; Pester 5.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none; `config/orchestration-routing.json` is read, not changed.

## Test Strategy
- Regression tests to add or update: the discovery guard, predicate-discrimination rows, interception probe rows, the no-Python guard rows for `.codex/hooks`, the preimplementation parity test, the families parity test, and the #746 helper rows.
- Unit tests for the fixed behavior and boundaries: Pester, using in-memory fixtures for predicate rows; each guard has compliant and non-compliant fixtures, a non-vacuity row, and a missing or unparseable suite row.
- Edge cases and negative scenarios: each CR-2 path and CR-3 branch; empty and `$null` registration sets; zero-declaration and divergent extractor fixtures.
- Error handling and logging verification: finding messages are asserted by content for at least one rule.
- Coverage impact and targets for changed lines/modules: no production PowerShell file is expected to change; if one does, line coverage must be at least 85%.
- Toolchain commands to run: PoshQC format, then analyze, then Pester (`mcp__drm-copilot__run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`), plus direct `Invoke-Pester` over explicit file lists for counts.
- Integration scenario to retest: run the suites with a deliberately present local epic checkpoint and expect identical results; the interception probe expresses this with in-memory payloads.
- Manual validation steps: none.

## Acceptance Criteria

- [ ] AC-1: A census run on the integration branch, executed after #736, #732, and #850 are merged, records per surface the discovered suites, the closure-derived seams, and the findings against the unedited suites. The record is stored under the feature `evidence/` tree as fail-before evidence, and the discovery guard fails against the unedited suites for at least one flagged suite.
- [ ] AC-2: A discovery guard test enumerates suites by directory enumeration of `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, contains no hard-coded suite list, and includes a non-vacuity test per surface that fails if that surface yields zero suites. The fixed `-ForEach` list and the D9 known-limit note are absent from `enforce-gate-suites.EpicStateIsolation.Tests.ps1`.
- [ ] AC-3: The guard computes each suite's loaded-source closure by string-literal scanning and flags a suite when the closure contains any seam in the Decision 1 set (epic-scope, worktree-run, and item-checkpoint seams) or any `artifacts/` read seam under Decision 3. A predicate row using an in-memory fixture shows a closure-only (variable-driven) load is detected, and a row shows that a suite whose rows never reach the seam is still flagged when its closure contains one.
- [ ] AC-4: After the baseline mocks are added, the discovery guard reports zero findings on both surfaces on the integration branch, and every suite it selects complies via form F1, F2, or F3 (or the shared baseline helper form for suites near the 500-line cap).
- [ ] AC-5: The guard reports, without failing, each process-spawning Codex suite whose local-state independence cannot be statically proven, naming the hook launched. A predicate row shows a process-spawning fixture is reported and does not produce a failure. The report is recorded under `evidence/`. Any such suite found by the census to depend on local state is fixed, and the fix is cited in the evidence.
- [ ] AC-6: A shared interception probe exists, and each in-scope suite calls it from inside an `It`. A guard row, using an in-memory fixture, fails when an in-scope suite lacks a probe call. Another row demonstrates the probe fails (hostile payload read, suite mock invocation count zero) when the baseline mock is bound to a different module instance than the one the resolver uses, and passes when it is bound correctly.
- [ ] AC-7: With a hostile ready epic checkpoint registered through in-memory lower-seam mocks, each probe asserts `IsEpicScope` is false with reason `epic-checkpoint-absent-or-unparseable`, exactly one invocation of the suite's baseline mock, and zero invocations of the lower hostile read. Equivalent assertions cover `Get-WorktreeRunCheckpointText` and the item-checkpoint seams on the Claude surface and the script-scope seam form on the Codex surface. No temporary file is created.
- [ ] AC-8: CR-2 false-pass path "ordering against the wrong dot-source": a predicate row with an earlier helper dot-source, followed by an import and mock, followed by the hook dot-source, produces a finding. A companion row with the hook dot-source first and the import and mock after it produces no finding.
- [ ] AC-9: CR-2 false-pass path "nested script block": a predicate row whose `Mock` and `Import-Module` appear only inside a function body in the outermost `BeforeAll` produces a finding.
- [ ] AC-10: CR-2 false-pass path "only the first top-level `BeforeAll` checked": a predicate row with two top-level `Describe` blocks, where only the first isolates, produces a finding.
- [ ] AC-11: CR-2 false-pass path "only the first `Mock` evaluated": a predicate row containing a null-returning `Mock` of a seam followed by a later `Mock` of the same seam with a non-null body produces a finding.
- [ ] AC-12: CR-2 false-pass path "regex import match": a predicate row where the module file name appears only inside a non-import string or comment-like argument produces a finding, and a row with a genuine import argument produces none.
- [ ] AC-13: CR-3 untested branches each have a predicate row that fails before the row's fixture is handled correctly and passes after: no outermost `BeforeAll`; parse error returned as a finding; ESR-side import absent with mock present; no dot-source at all in the `BeforeAll`; the colon-bound `-ModuleName:value` form; a `MockWith` body containing a `param`, `begin`, or `process` block; a non-string module-name element.
- [ ] AC-14: The stale comment "the three library modules are imported without -Force" no longer appears in `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` or `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, a replacement comment names the modules actually imported, and a repository text search for the stale phrase under `tests/` returns no match.
- [ ] AC-15: `enforcement-hooks-no-python-invocation.Tests.ps1` scans `.codex/hooks` in addition to `.claude/hooks` and `.claude/lib`. The repository-scan assertion in that test fails if enumerated files lie outside those three roots, and a row asserts at least one `.codex/hooks` file is enumerated. The `extensions/*` exclusion assertion remains and passes.
- [ ] AC-16: The scan-root definition and file enumeration live in a new helper file under `tests/scripts/claude-runtime/`. The comment that states exactly two scan roots is updated, and the extended guard passes against `.codex/hooks`, or any finding is resolved or documented with the carve-out that justifies it.
- [ ] AC-17: A preimplementation-gate parity test runs one shared case table against both `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, with per-runtime dot-sourcing in `BeforeAll`. Every row's outcome matches its expected value for both runtimes, or matches a per-surface expectation declared with a written reason. A fixture row proves an undeclared per-surface divergence fails the test.
- [ ] AC-18: An AST function-inventory test asserts each gate's defined function names equal the shared set plus a declared per-surface-only set. A fixture row shows that an undeclared added function fails the test. The parity test reads only the canonical `.claude/hooks` and `.codex/hooks` files and performs no text comparison of gate bodies.
- [ ] AC-19: A `GENERATED_AGENT_FAMILIES` parity test asserts that the set in `CodexDeployment.psm1` (read via `InModuleScope`) equals the set parsed from the text of `scripts/dev_tools/resolve_codex_deployment.py` and equals `codex_model_policy.generated_agent_families` in `config/orchestration-routing.json`, using case-sensitive ordinal comparison. Extractor rows show that a Python-literal text with zero declarations fails and that a text with a divergent member fails. Each parsed set has a non-vacuity assertion that fails for an empty or `$null` set. The test launches no interpreter.
- [ ] AC-20: `Get-CodexPreToolUseRegistration` in `codex-pretooluse-integration.Tests.ps1` returns `,$registrations.ToArray()`. A direct helper test with in-memory `Get-Content` output shows one registration returns an array of count one (not a scalar), and zero registrations return an empty array that is not `$null`.
- [ ] AC-21: The `@($null).Count`-compensating workaround in `codex-pretooluse-integration.Tests.ps1` is removed. The replacement registration-count assertions fail for an empty array and fail for a `$null` result; the documentation `Context` that exercised the legacy expression is replaced by the direct helper rows in AC-20.
- [ ] AC-22: If any file changed by this feature has a mirror under `extensions/drm-copilot/resources/`, the mirror is updated to match, and the bundle-parity tests (`legacy-codex-hook-contracts.Tests.ps1` root/bundle identity, `CodexRouting.Manifest.Tests.ps1`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`) pass. If no changed file has a mirror, the evidence records that finding, and those tests pass unchanged.
- [ ] AC-23: For every existing suite edited by this feature, a direct `Invoke-Pester` run over an explicit file list records Passed, Failed, and Skipped counts before and after, and the counts are equal (Failed is zero in both). Records are stored under `evidence/`.
- [ ] AC-24: Executed against a deliberately present local epic checkpoint (a gitignored `artifacts/orchestration/epic-orchestrator-state.json` in the working tree), the selected hook suites on both surfaces produce the same Passed, Failed, and Skipped counts as without it, and the result is recorded under `evidence/`.
- [ ] AC-25: No file added or edited by this feature exceeds 500 lines (verified by line count over the changed-file list), and the files `enforcement-hooks-no-python-invocation.Tests.ps1` and `EnforcementHooksNoPythonInvocation.Helpers.ps1` are each at or below 500 lines after the change.
- [ ] AC-26: No new or edited test creates or uses a temporary file, and no hook file under `.claude/hooks` or `.codex/hooks` is modified by this feature, verified by diff review of the changed-file list.
- [ ] AC-27: PoshQC format and analyze report zero findings on all changed files, and the PoshQC Pester run over the configured paths passes with zero failures. Line coverage for any changed PowerShell production file is at least 85%; if no production file changed, the evidence states so.
- [ ] AC-28: Evidence artifacts (census output, fail-before and fail-after guard results, before/after suite counts, process-spawning report) are written only under `docs/features/active/2026-09-27-hook-test-isolation-remaining-gaps-737/evidence/<kind>/`.

## Risks & Mitigations
- Technical or operational risks:
  - Upstream children (#736, #732, #850) change suites and hooks, so the discovered population differs from the preparation-time view. Mitigation: mechanical discovery and no frozen list or count.
  - Suites near the 500-line cap cannot absorb a multi-line baseline mock. Mitigation: shared baseline helper recognized by the guard, or trimming.
  - Closure-wide over-inclusion adds mocks to suites that never reach a seam. Mitigation: accepted by Decision 2; the mocks change no outcome, verified by AC-23.
  - `Should -Invoke` may not count a root `BeforeAll` mock as expected. Mitigation: a first probe run confirms semantics before reliance.
  - The census may reveal a production defect. Mitigation: record it and decide separately; do not change hooks in this child.
  - Process-spawning Codex suites may be locally state-dependent in ways static analysis cannot prove. Mitigation: report-first guard and execution-time census.
- Mitigations and rollbacks: all changes are test-only and revert by reverting the pull request.

## Rollout & Follow-up
- Release/rollout steps: single pull request for #737 and #746 into `epic/enforcement-hook-precision-integration`, after C5a, C1b, and C3 merge.
- Post-fix monitoring or clean-up tasks: file follow-ups for any production defect or unprovable process-spawning suite found by the census.
- Links: issue #737, issue #746, epic #852, #709 (PR #728), #707, #711, #555, #646, `research/research.2026-10-08T14-00.md`, `docs/features/epics/enforcement-hook-precision/epic.md`
