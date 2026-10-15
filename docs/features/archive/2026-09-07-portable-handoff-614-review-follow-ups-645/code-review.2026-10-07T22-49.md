# Code Review: Portable Handoff #614 Review Follow-ups, R16-R19 (#645)

---

**Review Date:** 2026-10-07
**Reviewer:** feature-review agent (pass 1)
**Feature Folder:** `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645`
**Feature Folder Selection Rule:** the only active feature folder changed on the branch; its suffix matches the issue number (645) in the branch name.
**Base Branch:** `main` (merge base `08ee030d9584bf15882fbb3654c8e38f34c7c359`; reviewed as `08ee030d...HEAD`, which excludes the `origin/main` merge at `f5e96db8`)
**Head Branch:** `feature/portable-handoff-614-review-follow-ups-645` at `38dac372`
**Review Type:** Initial review

---

## Executive Summary

The branch closes four deferred review items from the #614 handoff work:
- **R16:** three Pester cases that pin the exact rejection messages of `Get-EpicPlanningRegisteredMcpTool`, plus two committed fixtures.
- **R17:** 14 per-file Jest coverage thresholds for the handoff modules.
- **R18:** the 15 bare `catch {}` sites in four handoff modules are rewritten to bind `error: unknown`, and blocked results gain a redacted `failureCause` / `failure_cause` field.
- **R19:** the pinned-fixture Python test calls `raw_file_sha256`.

Production code changed in 8 TypeScript files: +179 lines covered by tests, net about +170 lines. All edits are additive or behavior-preserving. The reviewer inspected the full diff, every new test, the evidence tree, and the three coverage artifacts. The implementation quality is good. The cause design is simple. The redaction rule is enforced in one pure function. Code-selection and precedence behavior is unchanged, which unedited precedence and materializer tests confirm.

**What changed:**
- `describeHandoffFailureCause` was added to `orchestration-handoff-materializer-request.ts:32-46`.
- An optional `failureCause` was added to `blockedResult`, the authority `blocked`, both result interfaces, and the MCP result type, with conditional-spread mapping in the two handler adapters.
- Ten materializer catch sites, two authority sites, two path-boundary sites (through the new private `guardedResolution`), and one production projection site now bind and describe the caught value.
- The candidate-validate and candidate-replace failure paths are consolidated into `discardedCandidateResult` (DEV-11).
- `observedPlanSha256` now returns a discriminated union.

**Top 3 risks:**
1. The `error.name` token is not pattern-constrained (`materializer-request.ts:42-43`). A custom error subclass with an arbitrary `name` would pass that text into the cause. The current production throwers produce built-in names only, so this is a hardening item, not a present leak.
2. Three already-bound catch sites still return blocked results without a cause on their fallback arms (authority-service.ts:150-156, materializer.ts:282-292, materializer.ts:193-200 via materializer-production.ts:33-43). This is outside the spec's 15-site scope, but it leaves the `HANDOFF_UNSUPPORTED_VERSION` / `HANDOFF_VALIDATOR_UNAVAILABLE` fallback causes undiagnosed.
3. Spec AC-8 names one test file, while the authority cases live in a sibling file. The placement follows a pre-approved plan branch, but the AC text and the delivered layout disagree until the spec wording is updated.

**PR readiness recommendation:** **Go**. There are no Blocker or Major findings. All gates pass on evidence the reviewer re-derived, and the remaining items are Minor, Nit, or Info follow-ups.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-materializer-request.ts` | lines 42-43 | `error.name` is emitted verbatim for any `Error`. Only `code` is constrained by `^[A-Z][A-Z0-9_]*$`. | Accept `name` only when it matches an identifier pattern such as `^[A-Za-z][A-Za-z0-9_]*$`, otherwise emit `Error`. Add a helper test row with a path-bearing custom `name`. | This closes the one remaining non-literal input to the cause string and makes the redaction guarantee independent of thrower behavior. | Code inspection. The production throwers (`fs.*Sync`, `TextDecoder`, `JSON.parse`, `runner.run`) yield built-in names. The redaction test (failure-cause.test.ts:132-161) varies `message` only. |
| Minor (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-authority-service.ts`; `orchestration-handoff-materializer.ts` | authority 150-156; materializer 193-200, 282-292 | Pre-existing bound catches whose fallback arms (`HANDOFF_UNSUPPORTED_VERSION`, `HANDOFF_VALIDATOR_UNAVAILABLE`) return blocked results without `failureCause`. | Open a follow-up to attach `envelope-parse: <token>` and `destination-projection: <token>` on the non-`HandoffContractError` arms. Thread a cause from `validateEnvelope` via an optional field. | US-1 reads "every blocked handoff result that follows a caught error". The spec scope (15 bare sites, AC-8 enumeration) excludes these sites, so this is not an AC failure. | `git grep -cE "catch\s*\{"` at base = 15 bare sites, none at these lines. Code inspection at HEAD. |
| Minor (Non-blocking) | `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` | AC-8 (line 189) | AC-8 names only `orchestration-handoff-failure-cause.test.ts`. The A1-A6 authority cases are in `orchestration-handoff-failure-cause-authority.test.ts`. | In a later docs change, amend the AC-8 wording to name both files, citing P5-T11/P5-T12. | The single-file option would have produced a 608-line file, above the 500-line policy limit. Policy precedence and the pre-approved overflow branch justify the split; the AC text should match. | `evidence/other/authority-test-placement.2026-10-07T22-20.md` (442, then 608, then back to 442 lines; hash restored to `7fedb9d3`). DEV-12(c). |
| Nit (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts` | lines 84-101, 131-139, 152-155 | `guardedResolution` builds a `cause` string that both callers discard. | Keep as is until the D1 follow-up that surfaces path-boundary errno, or simplify to an `ok`/`value` result now. | Dead data. It matches spec D1, which keeps `HandoffPathBoundary` unchanged. | Code inspection. Spec D1 table row for path-boundary.ts. |
| Nit (Non-blocking) | `extensions/drm-copilot/src/lib/validate/orchestration-handoff-path-boundary.ts` | line 5 | The low-level path module now imports from `orchestration-handoff-materializer-request.ts`. | Consider moving `describeHandoffFailureCause` to a neutral module (for example `orchestration-handoff-contract-support.ts`) in a later change. | Dependency direction and cohesion. There is no runtime cycle, because materializer-request has only type imports (lines 1-7). | Code inspection. Grep of imports. |
| Nit (Non-blocking) | `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` | lines 75-76 | The test calls both `fixture_paths` and `fixture_bytes`. The plan bytes are read and discarded (`source_bytes, _ = ...`). | Read only the source bytes from `source_path.read_bytes()`, or keep as is. | This is a small redundant read with no correctness impact. | Diff inspection. |
| Info | `extensions/drm-copilot` | project tooling | No architecture-boundary tool (dependency-cruiser or equivalent) is configured, so policy loop stage 4 has no command to run. | Track separately if the project adopts boundary rules. | This is pre-existing project state, not introduced by this branch. | `ls extensions/drm-copilot`; `package.json` scripts. |
| Info | `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/spec.md` | lines 236-239 | The Definition of Done checklist remains unchecked, although every AC is checked. | Update at feature closure. | Document consistency. It is not an AC source. | spec.md inspection. |

No Blocker or Major findings. Blocking count: 0.

### Explicit evaluation points requested by the caller

1. **AC-8 two-file placement.** Verdict: PASS (Non-blocking documentation finding above).
   - Every result AC-8 enumerates has a named case with the unchanged `primaryFailureCode` and an exact `failureCause`:
     - materializer: M1 checkpoint-read, M2 envelope-decode, M3 git-status, M5 archive-write + readback, M7 candidate-write + readback, M9 candidate-validate, M10 candidate-replace, M11 cleanup appended;
     - authority: A1 envelope-read, A2 plan-read.
   - The idempotent-retry case M12 asserts that no `failureCause` key is present.
   - The only deviation is that A1/A2 are in a sibling file.
   - The plan pre-approved that placement (P5-T11/P5-T12) as the response to a measured 608-line single file, which the 500-line rule in `.claude/rules/general-code-change.md` prohibits. Repository policy outranks spec file naming in the policy reading order.
   - The criterion's substance (named cases and exact assertions) is met in full, and both files run in the recorded suites (`r18-authority-production-boundary.2026-10-07T22-23.md`, `ts-jest-coverage.2026-10-07T22-28.md`).
2. **Redaction.** Verdict: confirmed for `message`, `stack`, and filesystem paths.
   - `describeHandoffFailureCause` (materializer-request.ts:32-46) reads only `error.code` (accepted only if it matches `^[A-Z][A-Z0-9_]*$`, which cannot contain `/`, `\`, `:`, or `.`) and `error.name`. It never reads `message` or `stack`.
   - Every other `failureCause` value on the branch is a fixed literal (`workspace-root: unresolved`, `target-path: unresolved`, `destination-projection: invalid`), a helper return, or a `; `-join of helper returns. This covers materializer.ts lines 145, 158, 169, 184, 254, 301, 313, 364, 378, 386, 398, 412, 420, 443, 455, 472, and 485, and authority-service.ts lines 134, 142, 174, 178, 286, and 341.
   - The projection message in materializer-production.ts:51-53 embeds only the helper output and does not reach `failureCause`, because materializer.ts:301 uses the fixed literal.
   - Tests confirm this end to end: every materializer and authority fake throws an error whose `message` contains an absolute path (failure-cause.test.ts:28-33; failure-cause-authority.test.ts:24-29), and every assertion is exact equality on the cause.
   - Residual: `error.name` is unconstrained (Minor finding above).
3. **DEV-11 `discardedCandidateResult` equivalence.** Verdict: behavior-equivalent apart from the added `failureCause`.
   - Before: each of the two catch blocks called `this.discardCandidate(candidatePath)`, then returned `blockedResult(request, "HANDOFF_VALIDATOR_UNAVAILABLE", { handoffId, handoffHistorySha256, affectedPaths: [candidatePath] })`.
   - After (materializer.ts:462-474): the helper calls `discardCandidate` once, in the same order (removal before result construction), and returns the same code and the same three option fields, plus `failureCause`.
   - `discardCandidate` still calls `removeFile` exactly once and still swallows the removal failure. It now returns the cause (lines 480-487).
   - The unedited `orchestration-handoff-materializer.test.ts` assertions on `removeFile` (lines 347, 369, 392, 413-414, including `toHaveBeenCalledTimes(1)`) pass in the final run.
4. **500-line limit, temp files, thresholds.** Verdict: all PASS.
   - Every changed non-Markdown, non-fixture file is at or under 500 lines (largest: materializer.ts 488, jest.config.cjs 455, failure-cause.test.ts 442, test_orchestration_handoff_taskmaster_469.py 442).
   - The test-purity Grep over all 6 changed test files returns 0 matches, with a positive control selecting all 6.
   - `jest.config.cjs` adds 14 entries at exactly `{ lines: 85, branches: 75 }`. It has no `global` key and no `coveragePathIgnorePatterns`, `collectCoverageFrom` is unchanged, and no existing entry was modified (the diff is additions only).

---

## Implementation Audit

### Python implementation audit

#### What changed well

- `fixture_paths` factors path resolution out of `fixture_bytes`, which keeps its signature, so the hash test can call the shared `raw_file_sha256` public API. `NEGATIVE_SCENARIOS` is untouched; the hunk old ranges are 2-8, 20-25, 34-39, and 71-80, all outside lines 43-62.

#### Typing and API notes

- `fixture_paths(case: FixtureCase, fixture: dict[str, object]) -> tuple[Path, Path]` is fully typed. No production Python API changed; `scripts/dev_tools/orchestration_handoff_contract*.py` is unchanged against the base.

#### Error handling and logging

- No error handling was added. The test-support `_text`/`mapping` validators are reused.

### TypeScript implementation audit

#### What changed well

- One pure, documented helper owns the redaction rule. All call sites pass fixed stage labels.
- Conditional spreads keep the key absent when unset, which matches `exactOptionalPropertyTypes` and the AC-11 `not.toHaveProperty` contract.
- `observedPlanSha256` now uses a discriminated union instead of `null`, which carries the cause without widening any public type.
- `guardedResolution` removes the two bare catches without changing the `HandoffPathBoundary` contract (interface lines 19-29 unchanged).
- The write-then-readback recovery paths compose causes (`archive-write: EEXIST; archive-readback: EACCES`) and emit none on successful recovery (M12).

#### Type safety and maintainability

- No `any`, no suppressions, no non-null assertions were added. `catch (error: unknown)` is used at all 15 rewritten sites.
- The marker `Object.assign(new Error(...), { code: "HANDOFF_CANDIDATE_MISMATCH" })` is internal and is not added to `HandoffFailureCode`. `orchestration-handoff-contract.ts` and the registry are unchanged.
- In `resolveExistingTarget`, `isContained` now runs outside the guarded block (path-boundary.ts:155-158). `isContained` performs only string normalization and comparison, so no new throw path is exposed in practice.

#### Error handling and logging

- Failures stay explicit and structured. No logging was added; per spec D1, the cause travels in the result object. Cleanup failure is no longer silently discarded; it is appended as `; candidate-cleanup: <token>`.

### PowerShell implementation audit

#### What changed well

- The three new `It` cases call `Get-EpicPlanningRegisteredMcpTool` directly and assert the exact messages for hook lines 58, 72, and 77 with `Should -BeExactly`. They use the committed absent-path sentinel and two committed fixtures. The hook and its published copy are unchanged and byte-identical.

#### API and safety notes

- Test-only change. Variables are `$script:`-scoped in `BeforeAll`. Analyzer clean.

#### Error handling and logging

- Each case asserts that the caught record is non-null before reading `Exception.Message`, so a non-throwing regression fails with a clear `-Because` message.

---

## Test Quality Audit

The tests cover every rewritten site with a named, exact-equality case. The reviewer independently parsed `extensions/drm-copilot/coverage/lcov.info`, `artifacts/python/lcov.info`, and `artifacts/pester/powershell-coverage.xml` (all written after the last code commit), and the results matched the recorded evidence. Changed TypeScript production lines are 179/179 covered. The 14 handoff modules are each at or above 85% line and 75% branch; the lowest is path-boundary.ts at 84.75% branch, up from 81.13%. Pester shows hook lines 58, 72, and 77 covered (`ci=1`).

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause.test.ts` covers the helper table (7 rows and a redaction case), materializer rows M1-M17, path-boundary B1/B2, and projection P1. It runs in-memory with fakes. 442 lines.
- `extensions/drm-copilot/test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts` covers authority rows A1-A6 with fake file system, path boundary, and checkout context. It reads one committed fixture read-only. 186 lines.
- `extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts` adds two appended cases for `failure_cause` presence and absence. It is a pure append (`@@ -310,0 +311,87 @@`).
- `tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1` adds three exact-message cases; the existing line-67 case is unchanged.
- `tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py` now exercises `raw_file_sha256`.
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/toolchain-loop-single-pass.2026-10-07T22-38.md` records a single-pass loop. The reviewer confirmed that its Write Set hashes equal HEAD.
- `docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645/evidence/qa-gates/coverage-delta.2026-10-07T22-40.md` records per-language and per-module deltas, all non-decreasing.

### Quality assessment prompts

- **Determinism:** no timers, clocks, randomness, network, or temp files. Fakes throw fixed coded errors.
- **Isolation:** one blocked-result path per row; scenarios are rebuilt per case.
- **Speed:** in-memory fakes. The full Jest run (253 suites) completed in the recorded `test:coverage` pass.
- **Diagnostics:** exact-string assertions report expected and actual cause strings. Row labels name the arrange condition.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | The diff adds no credential, token, or environment read. |
| No unsafe subprocess or command construction | ✅ PASS | No subprocess change. The git invocation at materializer-production.ts:101-104 is unchanged. |
| Input validation at boundaries | ✅ PASS | Path validation (`lexicalCandidate`, `isContained`) is unchanged. MCP `inputSchema` is unchanged. |
| Error handling remains explicit | ✅ PASS | 15 bare catches were replaced by bound catches, each mapped to a cause. No new broad swallow; the cleanup failure is now reported. |
| Configuration / path handling is safe | ✅ PASS | Cause strings carry no path, message, or stack. The `name` hardening is recommended (Minor). |
| Failure-code precedence unchanged | ✅ PASS | The unedited precedence tests pass (Python `test_failure_precedence_matches_the_shared_registry`; TS registry-equality and registry-order tests). `config/orchestration-handoff-registry.json` and `orchestration-handoff-contract.ts` are unchanged. |

---

## Research Log

No external research was required. All conclusions derive from the branch diff, the feature folder documents, the recorded evidence, and the coverage artifacts in the worktree.

---

## Verdict

The change is ready for normal PR flow. The implementation meets the spec's R16-R19 scope with zero bare catches in the handoff sources, exact-message Pester coverage of the three previously untested throws, enforced per-file Jest floors, and a live call site for `raw_file_sha256`. Coverage and the single-pass toolchain loop were re-verified by the reviewer against current HEAD.

The three Minor findings (unconstrained `error.name`, cause-less fallback arms at three pre-existing bound catches, and AC-8 wording versus the two-file layout) are non-blocking. They are suitable for one follow-up issue. The Nit and Info items require no action before merge.
