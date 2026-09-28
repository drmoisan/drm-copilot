# Remediation Inputs: Portable Prepared Orchestration Handoff (Issue #614)

**Cycle entry timestamp:** 2026-09-07T08-00
**Author:** feature-review
**Feature Folder:** `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614`
**Base Branch:** `main`, resolved to `origin/main @ 0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Head Branch:** `feature/portable-prepared-orchestration-handoff-614 @ 645c40b02039c6c7203fcd5515e1e2ee2168bc01`
**Merge Base:** `0542c92a7c589cfe952a0dfd480223960fd1eb33`
**Pull Request:** https://github.com/drmoisan/drm-copilot/pull/638

## Source Audit Artifacts

These remediation inputs are derived from, and must be read alongside, the three audit artifacts produced in the same cycle:

- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/policy-audit.2026-09-07T08-00.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/code-review.2026-09-07T08-00.md`
- `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/feature-audit.2026-09-07T08-00.md`

## Blocking Status

**Blocking findings: 0.**

Every mandatory gate is green at head `645c40b0`, reproduced independently by this reviewer rather than accepted from the executor's evidence records. All seven toolchain stages pass in a single check-only sweep with the working tree byte-clean before, during, and after. All three coverage languages exceed the uniform 85% line threshold and, where the tooling measures it, the 75% branch threshold, repository-wide, on new files, and on modified files. No evidence-location violation and no prohibited coverage exclusion exists. All 28 acceptance criteria across `spec.md` and `user-story.md` verify as PASS.

This cycle does not gate the pull request. If the orchestrator is evaluating the remediation-loop exit gate, `blocking_count` is 0 and `exit_condition_met` may be set.

The prior cycle's two synthetic CI findings are resolved. CI-614-001 and CI-614-002 were remediated test-only at commit `645c40b0`, and both fixes were confirmed correct by direct inspection of the production seams they depend on rather than by accepting the remediation record. Neither is carried forward.

## Priority Ordering

No item in this cycle is new. R16 through R20 are the same five findings the 2026-09-07T02-00 cycle recorded as R8 through R15, re-scoped and re-quantified against the current head after two of that set were closed by intervening work. Each was independently re-verified as still present at head `645c40b0`; none was carried forward on the strength of the earlier record alone.

R16 is the item that matters most and is also the cheapest to close. It is the only finding that leaves an acceptance criterion's behavior asserted by construction rather than by test, and this cycle quantifies it precisely for the first time: four specific line numbers and a changed-line coverage figure.

Identifier note: previous cycles used R1-R7 and R8-R15. To avoid collision, this cycle numbers its items R16 onward. The mapping from previous identifiers is stated in each item.

---

## Enumerated Fix List

### R16 — Cover the four fail-closed paths in the PowerShell registry loader (Major, carried forward as R11/R4)

**File:** `.codex/hooks/enforce-epic-planning-only.ps1`, lines 58, 67, 72, 77. Tests to add in `tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1` or a new sibling suite.

**Finding.** `Get-EpicPlanningRegisteredMcpTool` is the hook's registry loader and its four `throw` statements constitute its entire rejection contract. None is executed by any test.

- Line 58 — `throw "EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '$RegistryPath' does not exist."`
- Line 67 — `throw "EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' is not registered."`
- Line 72 — `throw "EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' has an invalid operation."`
- Line 77 — `throw "EPIC_PLANNING_ONLY_BLOCKED: semantic MCP id '$semanticId' has an invalid transport alias."`

**Quantification.** The branch added 24 executable lines to this file and covered 20, so the changed-line subset is 83.33%, below the 85% uniform line floor as applied to changed lines. The file level is 91.82% (146/159) and no previously covered line lost coverage, so the language coverage verdict remains PASS and this is not a coverage failure. The four uncovered branch-added lines are exactly the four throws. The other nine uncovered lines (297, 326, 333, 334, 335, 340, 349, 353, 354) are pre-existing and match the baseline's uncovered set exactly.

**Why it matters.** These four paths are the hook-side half of AC7's requirement to reject malformed identifiers, unrelated servers, and approximate or unregistered operations. The validator-side half is fully covered by `semantic-mcp-alias-cases.json` and a 100%-covered `semantic-mcp-identity.ts`. If the registry's shape drifts, the hook would begin throwing at load and denying every preparation gate, and no test would fail first to warn of it.

**Fix.** Add four Pester cases, one per throw, each asserting the exact message. Make `-RegistryPath` the seam: the function already takes it as a mandatory parameter, so no production change is required.

1. Absent registry: pass a `-RegistryPath` pointing at a non-existent file under the repository.
2. Unregistered id: pass a committed fixture registry whose `semantic_tools` omits one of the `-SemanticIds` supplied.
3. Operation mismatch: pass a fixture whose entry `operation` disagrees with the id's suffix after the final dot.
4. Malformed alias: pass a fixture with a `transport_aliases` entry that does not match `^mcp__(?:drm-copilot|drm_copilot)__<escaped-operation>$`, for example a third server name or a truncated operation.

**Constraint.** The three fixture registries must be committed files under `tests/fixtures/codex-hooks/`, not created at run time. Do not use `TestDrive`, `New-TemporaryFile`, or `[IO.Path]::GetTempPath`.

**Acceptance.** All four throws show as covered in `artifacts/pester/powershell-coverage.xml`; the file's missed-line set reduces to exactly the nine pre-existing lines; changed-line coverage for the file rises to 100%; repository PowerShell line coverage does not fall below 94.77%.

### R17 — Register the 14 new modules in the TypeScript coverage gate (Major, carried forward as R10/R7a)

**File:** `extensions/drm-copilot/jest.config.cjs`, the `coverageThreshold` map.

**Finding.** The map contains zero entries matching `orchestration-handoff` or `semantic-mcp-identity`, and the file was not modified by this branch. Because the config deliberately carries no `global` key — its own comment states "Per-changed-file thresholds only (no `global` key)" — coverage for the 14 new production modules is measured but not enforced.

**Why it matters.** Measured coverage is 99.19% line and 93.68% branch today, so there is no present shortfall. The gap is durability: every comparable module group in this repository (`pr-context`, `subagent-tree`, `parallel-state`, `validate`) carries per-file entries, and this group does not, so a future regression on any of the 14 would land without failing the run.

**Fix.** Add 14 entries at `lines: 85, branches: 75`, one per new production module:

`./src/lib/validate/orchestration-handoff-authority-service.ts`, `-checkout-context.ts`, `-contract-support.ts`, `-contract.ts`, `-materializer-production.ts`, `-materializer-request.ts`, `-materializer-support.ts`, `-materializer.ts`, `-path-boundary.ts`, `-provider-adapters.ts`, `-validation.ts`, `./src/lib/validate/semantic-mcp-identity.ts`, `./src/mcp-handlers/orchestration-handoff-handlers.ts`, `./src/mcp-repo-automation-tool-definitions-handoff.ts`.

**Constraint.** Do not add an entry below `lines: 85, branches: 75`. Do not add a `coveragePathIgnorePatterns` entry. Do not add a `global` key, which would fail the run on unrelated legacy coverage and is the documented reason it is absent.

**Acceptance.** `npm --prefix extensions/drm-copilot run test:coverage` exits 0 with the 14 entries present, proving each module clears both floors under enforcement rather than only under measurement.

### R18 — Preserve the cause behind structured handoff failure codes (Major, carried forward as R12/R13)

**Files:** `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer.ts` (10 sites, including lines 162, 175, 298, 351, 357, 379, 385, 413, 426), `-authority-service.ts` (2 sites), `-path-boundary.ts` (2 sites), `-materializer-production.ts` (1 site). Fifteen sites total.

**Finding.** Each site is a bare `} catch {` that discards the caught value before returning a generic structured code, most often `HANDOFF_VALIDATOR_UNAVAILABLE`. `.claude/rules/general-code-change.md` permits a catch-all only when the error is immediately re-raised or propagated with added context; discarding it satisfies neither clause.

**Why it matters.** At line 162 a two-call `readFile` try block maps an absent file, a permission denial, and a corrupt read to one indistinguishable code. An operator diagnosing a stuck handoff has no signal about which occurred. This is a diagnosability cost rather than a correctness defect, which is why it is Major rather than a Blocker: the conversion to a deterministic code is the right boundary behavior, and each catch is narrowly scoped around one or two calls rather than a whole function body.

**Fix.** Bind the caught value and attach a redacted cause to the structured result. The correct form is already present in the same file at line 272, which uses `catch (error: unknown)` and makes a decision from the bound value. `blockedResult` already carries a details channel alongside `affectedPaths` and `unsupportedCapabilities`; extend it with an optional cause string rather than introducing a new channel.

**Constraint.** Do not change which failure code any condition returns. The deterministic `HANDOFF_*` selection is asserted by parity tests in Python, TypeScript, MCP, and hook suites, and by `test_failure_precedence_matches_the_shared_registry`. This item adds diagnostic detail only; it may not reallocate codes or reorder precedence. Do not include absolute paths or environment values in the cause string beyond what `affectedPaths` already exposes.

**Acceptance.** Zero bare `} catch {` remain in the four modules; each returns a cause alongside its code; the existing precedence and code-selection tests still pass unchanged; per-module coverage does not fall below its current figure.

### R19 — Wire or remove the unreferenced Python hashing helper (Minor, carried forward as R9)

**File:** `scripts/dev_tools/orchestration_handoff_contract_support.py`, `raw_file_sha256`; re-exported at `scripts/dev_tools/orchestration_handoff_contract.py:20`.

**Finding.** The helper is exported through the explicit `raw_file_sha256 as raw_file_sha256` idiom, which marks it public, but is called by no production module and no test. A directed search across `scripts`, `extensions/drm-copilot/src`, and `tests` returns exactly one non-defining hit, the re-export itself.

**Why it matters.** Dead public surface has to be maintained and read as though load-bearing, and it contributes to this module being the lowest-covered new Python file at 91.01% line and 81.58% branch. Its sibling `read_legacy_v1` is production-unwired but test-exercised, which is a defensible state; `raw_file_sha256` is neither.

**Fix.** Either call it from the fixture-hashing path that currently recomputes file digests inline, which is the preferable option because it removes a duplicated read-and-hash sequence, or remove both the definition and the re-export.

**Acceptance.** The symbol is either referenced by at least one non-defining production or test call site, or absent from both files. Python repository-wide coverage does not fall below 92.89% line and 85.51% branch.

### R20 — Complete the request literal in the path-boundary suite (Minor, new quantification of an item previously bundled in R15)

**File:** `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`, lines 182-190.

**Finding.** The `TransitionPreparedOrchestrationRequest` literal omits the ten independent-expected-context fields — `expectedRepositoryId`, `expectedWorkspaceRoot`, `expectedBranch`, `expectedSourceHeadSha`, and six more — yet the suite asserts a `materialized` outcome at line 253. A test-tree compile reports `error TS2740` at `(182,9)` naming the omission. The error is invisible at run time because `tsconfig.jest.json` sets `isolatedModules: true`, so ts-jest transpiles without diagnostics.

**Why it matters.** The suite stubs `dependencies.validation`, so this does not demonstrate a production defect and the `materialized` assertion is not wrong. The cost is that the literal will not fail if a future required field is added, which weakens the contract-conformance value of a test whose whole purpose is boundary wiring. This is the same independent-expected-context surface that commit `e22d002d` was written to make mandatory.

**Fix.** Import and spread `INDEPENDENT_CONTEXT` from `orchestration-handoff-materializer-test-support.ts`, as the sibling suites already do, rather than restating the fields.

**Acceptance.** `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` no longer reports TS2740 at that location; the suite's assertions are unchanged and still pass.

---

## Out-of-Scope Observations (No Remediation Item; File Separately If Desired)

These are recorded for the orchestrator's awareness. None is caused by this branch and none belongs in a remediation plan scoped to issue #614.

1. **`quality-tiers.yml` does not exist.** `.claude/rules/quality-tiers.md` names it as the repository-root source of truth and states that adding a project without a tier classification fails CI. It is absent. The tier-dependent gates — property-test density, mutation score, untyped-escape-hatch budget, determinism retry rate, golden tests, E2E scope — therefore cannot be evaluated against an authoritative classification. This cycle's policy audit records them as unevaluable and asserts no tier for any module. The uniform gates are tier-independent under Authoritative Decision #2 and all pass. Carried unchanged from the 2026-09-07T02-00 cycle.
2. **The PowerShell coverage gate is advisory in tooling.** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` sets `CoveragePercentTarget = 0`, so the 85% line threshold for PowerShell is enforced by reviewer computation from `artifacts/pester/powershell-coverage.xml` rather than by the run's exit code. A green Pester run is not by itself evidence that PowerShell coverage cleared the floor. The 94.77% figure in this cycle was computed from the JaCoCo report counters directly.
3. **The extension test tree does not typecheck.** `npx tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits 2 with 331 errors across 69 files. No enforced gate covers this axis: `npm run typecheck` compiles `src` only and exits 0, and ts-jest suppresses diagnostics under `isolatedModules: true`. Of the 331, 318 sit in 63 files this branch never touched. The 13 in branch files are individually assessed in the code review; only the one at R20 is substantive. Whether the test tree should typecheck at all is a repository-level decision, not a #614 decision.
4. **Headroom against the 500-line limit.** `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` is at exactly 500 lines; `scripts/dev_tools/orchestration_handoff_contract.py` and `extensions/drm-copilot/src/repo-automation-service.ts` are at 498; `extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts` is at 497. The limit is satisfied. R18 adds lines to one of the 497/498 files and R19 may add lines to another, so an extraction may be required first.
5. **No dependency-cruiser configuration exists.** `.claude/rules/general-code-change.md` names dependency-cruiser as the example architecture-boundary tool for stage 4, and no `.dependency-cruiser*` file exists anywhere in the repository. The boundary is currently verified by directed import scans, which this cycle reproduced: zero matches for `dev_tools` or test-tree specifiers across 199 files under `extensions/drm-copilot/src`. Pre-existing and repository-wide.

---

## Acceptance Criteria Re-check Instruction

No acceptance criterion changed state in this audit. All 15 `spec.md` criteria and all 13 `user-story.md` criteria are `[x]` at head and every one was confirmed PASS by independent re-evaluation against the current tree rather than carried forward from the prior cycle's verdicts. No checkbox was newly checked or unchecked, and neither source file was modified by this reviewer.

Two criteria carry a recorded caveat that does not change their verdict. AC7 and user-story item 21 require that hook and validator allowlists reject malformed, unrelated, and unregistered identifiers. The validator half is fully covered; the hook half is implemented correctly and fails closed but is untested, which is R16. The criteria's substantive requirements — one shared registry, both transport spellings resolving to the same operation — are directly demonstrated, so both pass.

The unchecked items under `spec.md` `## Definition of Done` and `## Seeded Test Conditions (from potential)` are not acceptance criteria under `full-feature` work mode and were not modified. Their substance is met on the evidence gathered. The orchestrator may wish to have them checked as a documentation-hygiene action before merge; that is not a delivery gap.

---

## Do Not Do

- **Do not narrow the audit or remediation scope.** The scope of any remediation plan derived from these inputs is the full branch diff against `0542c92a7c589cfe952a0dfd480223960fd1eb33`, not a subset of it. Do not mark any language's coverage `N/A`, "plan scope only", "informational only", "context only", or "out of scope" when that language has changed files in the branch diff. TypeScript, Python, and PowerShell each have changed files and each requires an explicit PASS or FAIL verdict with computed figures. C# is the only language with zero changed files.
- **Do not weaken any policy.** Do not add a `coverageThreshold` entry below `lines: 85, branches: 75`. Do not add a `coveragePathIgnorePatterns` entry, and do not add any `exclude` entry matching a path under `src/`. Do not lower a threshold to make a file pass. Do not add a `global` key to `jest.config.cjs`.
- **Do not exclude a production file from coverage measurement.** `src/repo-automation-service-contract.ts` reports 0% because it is interface-only with five `export interface` members and no runtime construct; it stays inside `collectCoverageFrom`. Excluding it would convert a documented and permitted 0% into a prohibited exclusion.
- **Do not change which failure code any condition returns.** R18 may add diagnostic detail; it may not reallocate codes or reorder the 16-entry precedence list. The list is pinned by exact-equality tests on both the Python and TypeScript sides.
- **Do not modify the committed fixtures.** All four pinned digests under `tests/fixtures/orchestration-handoff/taskmaster-469/` were independently recomputed from the on-disk bytes at head `645c40b0` and match, and both source checkpoints were confirmed to have identical index-blob and worktree digests. Do not regenerate, reformat, or re-serialize any fixture file, and do not remove the two `.gitattributes` `-text -eol` entries. A byte change to any of them breaks AC2, AC3, and AC13 and was already the subject of an earlier repair in this feature.
- **Do not reintroduce a dependence on gitignored state in tests.** Commit `645c40b0` removed the last one by replacing a read of `artifacts/orchestration/orchestrator-state.json` with the committed fixture `tests/fixtures/codex-hooks/epic-planning-preparation-checkpoint.json`. R16's three new fixture registries must be committed files for the same reason.
- **Do not create or use temporary files in tests.** The added suites are free of `tmp_path`, `TemporaryDirectory`, `NamedTemporaryFile`, `mkdtemp`, `os.tmpdir`, `TestDrive`, and `GetTempPath`, confirmed by a directed scan of every changed test file this cycle. Keep it that way.
- **Do not reintroduce a platform-dependent path literal.** Commit `645c40b0` replaced `"C:/workspace"` with `path.resolve("virtual-workspace")` because a drive-letter literal is absolute on Windows and relative on POSIX, which broke five jest suites on the Linux runner. Any new absolute path in a test must be derived at run time. The residual drive-letter literals in two files were verified to reach no absolute-path predicate on any success path and may remain.
- **Do not introduce a real clock, sleep, or wall-clock read.** The materializer takes an injected clock seam returning a fixed ISO string; use it. `setTimeout`, `setInterval`, `Date.now`, and `Math.random` are absent from every changed file and must stay absent.
- **Do not write evidence outside the canonical scheme.** All evidence goes to `docs/features/active/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/<kind>/`. `artifacts/baselines/`, `artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`, `artifacts/coverage/`, `artifacts/regression-testing/`, and `artifacts/post-change/` are forbidden and are enforced by the `enforce-evidence-locations.ps1` PreToolUse hook.
- **Do not add a dependency.** The handoff surface uses only standard-library modules on the Python side and existing project dependencies on the TypeScript side. None of R16 through R20 requires a new one.
- **Do not expand scope into #467 or #543.** AC15 and user-story item 28 depend on this branch changing neither the Codex-native parallel scheduling surface nor the epic-planner ready gate. Do not create any `parallel-*` skill or agent file and do not modify `scripts/dev_tools/validate_epic_planner_state.py`.
- **Do not run the PowerShell formatter without the recorder seam.** `Invoke-PoshQCFormat` has no check flag and rewrites every drifted file, which would both violate the no-source-modification constraint on review and invalidate the clean-working-tree evidence. Substitute a recorder for its `-WriteFile` scriptblock parameter.
- **Do not silently skip a verification step.** If a listed verification command cannot run, record the reason in the cycle evidence rather than omitting the step.

---

## Handoff Note

Under `.claude/skills/remediation-handoff-atomic-planner/SKILL.md`, the remediation plan is authored by `atomic-planner`, not by `feature-review`. This agent produces the remediation inputs only, and no `remediation-plan.2026-09-07T08-00.md` accompanies this file, consistent with the 2026-09-07T02-00 cycle where blocking count was likewise 0 and the orchestrator elected deferral.

Because `blocking_count` is 0 and all 28 acceptance criteria pass, the recommended disposition is to merge on green CI and carry R16 through R20 into a single follow-up issue rather than to run another remediation cycle on this branch. R16 is the one worth prioritizing there: it is four Pester cases, requires no production change, and is the only item that moves an acceptance criterion's behavior from asserted-by-construction to asserted-by-test.

If the orchestrator instead elects to run a remediation cycle, it should delegate plan authoring to `atomic-planner` with these inputs and the three audit artifacts inlined in the delegation prompt, then route the resulting plan through `atomic-executor` preflight before execution. R16 and R17 are independent of each other and of R18 through R20 and may be executed in any order; R18 touches a file near the 500-line limit and should be sequenced after any extraction it requires.
