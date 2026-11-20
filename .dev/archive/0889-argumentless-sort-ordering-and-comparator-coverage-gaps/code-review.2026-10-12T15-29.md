# Code Review: Issue #889 (argument-less sort ordering and comparator coverage gaps)

- Timestamp: 2026-10-12T15-29
- Branch: `bug/argumentless-sort-ordering-and-comparator-coverage-gaps-889`
- Head: `ef38d9dcf55fce25eed9c5341dc1d5cd3f099633`
- Base: `origin/main`
- Overall verdict: **PASS** (0 Blocking, 6 Non-blocking)

## Executive Summary

The reviewer read the full production and test diff. All 19 conversions are correct: each replaces an argument-less `.sort()` on a `string[]` with `.sort(compareCodePoint)`, and the comparator (`src/lib/string-ordering.ts:53-66`) returns exactly -1, 0, or 1 and defines a strict total order. No sorted array can contain `undefined` or non-string elements at any of the 19 sites, so the default comparator's behavior of moving `undefined` to the end is not relied on anywhere. In-place mutation semantics are unchanged (`unknown.sort(...)` and `variantSpecific.sort(...)` in `codex-pack-selection.ts` mutated their local arrays before this change as well). No residual argument-less `sort`/`toSorted` call remains under `extensions/drm-copilot/src` (reviewer Grep: no matches).

The 21 new tests discriminate between code-point order and UTF-16 order. Every observable-site test inserts `"\u{1F600}"` (lead unit 0xD83D) before `"～"` (0xFF5E). Default order therefore places the supplementary character first, and each assertion requires the reverse. The recorded red run shows all 14 failing against unconverted sources. The null-arm tests run both input orders and assert a fixed result, so they cannot pass through stable-sort insertion order. The `targetRole` test establishes its preconditions (equal `sectionId`, distinct roles) before asserting the combined order.

No blocking defect was found. The six non-blocking findings concern test readability, consistency, and file-size headroom.

## Conversion Correctness (19 sites)

| # | Site (post-change line) | Element type | Comparator effect | Verdict |
|---|---|---|---|---|
| 1 | `push-down/claude-pack-selection.ts:118` | `string` (Set spread) | Manifest load and error order | Correct |
| 2 | `push-down/claude-pack-selection.ts:300` | `string` filtered to `CSHARP_PACK_NAMES` | No observable change (ASCII) | Correct |
| 3 | `push-down/codex-pack-selection.ts:68` | `string[]` `unknown` | Error message order | Correct |
| 4 | `push-down/codex-pack-selection.ts:74` | `string` (guarded by `MANIFEST_PACK_NAMES`) | No observable change (ASCII) | Correct |
| 5 | `push-down/codex-pack-selection.ts:103` | `string` filtered to `CSHARP_PACK_NAMES` | No observable change (ASCII) | Correct |
| 6 | `push-down/codex-pack-selection.ts:112` | `string[]` `unknown` | Error message order | Correct |
| 7 | `push-down/codex-pack-selection.ts:237` | `string` filtered to `CSHARP_PACK_NAMES` | No observable change (ASCII) | Correct |
| 8 | `subagent-tree/tree-assembler.ts:181` | `string` models | `TreeNode.models` order | Correct |
| 9 | `subagent-tree/tree-formatter.ts:30` | `string` models | Rendered model list order | Correct |
| 10 | `resolve/file-prompt-transforms.ts:188` | `string` variable names | Error message order | Correct |
| 11 | `resolve/file-prompt-transforms.ts:195` | `string` variable names | Substitution order | Correct |
| 12 | `validate/codex-topology-resolver.ts:125` | `string` (cast from validated `unknown[]`) | `languages` order | Correct |
| 13 | `validate/epic-orchestrator-state-core.ts:204` | `string` folders | Error order | Correct |
| 14 | `validate/epic-planner-git-integrity.ts:285` | `string` (`Object.keys`) | Error order | Correct |
| 15 | `validate/orchestrator-state-codex-model-routing.ts:459` | `string` agents | Error order | Correct |
| 16 | `validate/orchestrator-state-codex-topology.ts:300` | `string` allowed names | No observable change (ASCII; see below) | Correct |
| 17 | `validate/orchestrator-state-core.ts:254` | `string` (`Object.keys`) | Error order | Correct |
| 18 | `validate/orchestrator-state-core.ts:286` | `string` (`Object.keys`) | Error order | Correct |
| 19 | `validate/orchestrator-state-model-routing-existence.ts:68` | `string` agents | Error order | Correct |

Site 16 non-observability was verified independently. `allowedNames` holds `receipt.logical_agent` from receipts that pass `validateCodexTopologyReceipts`, which is resolved against fixed personas such as `codex-topology-resolver.ts:67-85` and `FORCED_ROOT_PERSONAS`. It also holds `deployment_agent` values from receipts that pass `validateCodexModelRoutingReceipt`, whose `resolveCodexDeployment` rejects any family outside `GENERATED_AGENT_FAMILIES` (`orchestrator-state-codex-model-routing.ts:240-251`). All of these values come from ASCII constants.

## Test Review

- **Arrange-Act-Assert.** Present and labelled in all 21 tests. In the null-arm tests, the Act and Assert steps sit inside a `for` loop over input orders (see F-1).
- **Determinism.** No timers, clocks, or RNG. The `SequencedReadFileSystem` queue is consumed in call order, and its constructor seeds the backing file so that `isFile` checks pass. Exhausting the queue throws an explicit error rather than returning stale data.
- **Discrimination: code-point tests.** All 14 tests use exact-equality assertions (`toEqual`, `toBe`, or `toThrow(new ManifestError(...))`). One exception is the claude-pack test, which anchors a regex at `^Pack manifest is missing for pack '～'`; this suffices because only the first error thrown is observable. The second `file-prompt-transforms` test asserts a substitution-order effect (`"donedone"` against a residual placeholder). The reviewer confirmed by tracing the code that the reverse order leaves `${😀}` behind.
- **Discrimination: null-arm tests.** Each test feeds `[nonNull, null]` and `[null, nonNull]` and requires the same output. A comparator that ignored the target or source key would return insertion order for one of the two inputs and fail. At `validation.ts:364-365`, the test supplies `null` on both operands, as AC-5 permits, and the target path decides the order.
- **Discrimination: targetRole test.** Preconditions assert that each text alone yields one gate trace, with roles `shared-skill` and `hook` and an identical `sectionId`. The combined run must yield `["hook", "shared-skill"]`, which is the reverse of read order. Recorded mutation evidence shows a failure when line 241 returns 0.
- **Isolation.** Each test targets one sort site or one tiebreak arm. Tests that call a whole validator filter error lists to the message family under test, so unrelated validation errors do not couple the test to other rules.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Non-blocking (F-1) | `test/lib/codex-native-converter/reporting-render.test.ts`, `reporting-coverage.test.ts`, `validation.test.ts` | New `889-null-arm` tests | Each test loops over both input orders inside one `it`. A failure message does not identify which input order failed. | Use `it.each` with a labelled input-order parameter, or include the order in a custom assertion message. | Clearer failure diagnostics; general-unit-test policy asks for actionable failure messages. | Diff of the three files (loops `for (const findings of inputOrders)` and similar) |
| Non-blocking (F-2) | `test/lib/codex-native-converter/reporting-render.test.ts` | `889-null-arm: sorts a null trace target path ...` | Asserts relative position via `indexOf("\`first\`") < indexOf("\`second\`")` rather than the full ordered row list. The sibling finding test asserts the exact filtered lines. | Filter the trace table rows and assert the exact ordered list, matching the finding test. | Exact assertions are more precise and consistent; the current form still satisfies AC-5. | Diff lines in the trace null-arm test |
| Non-blocking (F-3) | `test/lib/subagent-tree/tree-assembler.test.ts` and 13 other tests | `889-cp-order` tests | The reference pair is redefined inline in 14 tests. `tree-assembler.test.ts` writes `"～"` while the others use the literal `"～"`. | Optionally define `HIGH_BMP` and `SUPPLEMENTARY` once in a shared test-support module and use one literal style. | Consistency and reduced duplication; behavior is identical. | Diff of the 11 `889-cp-order` test files |
| Non-blocking (F-4) | `test/lib/codex-native-converter/reporting-coverage.test.ts` | File name | The test file for `src/lib/codex-native-converter/reporting.ts` is named `reporting-coverage.test.ts`, not `reporting.test.ts`. The file predates this branch; it was only extended here. | Track a rename or consolidation separately; do not change it in this issue. | Test-location mirroring rule; pre-existing condition, not introduced by this change. | `git diff --stat origin/main...HEAD` shows the file as modified (+50), not created |
| Non-blocking (F-5) | `src/lib/validate/epic-orchestrator-state-core.ts`, `orchestrator-state-codex-model-routing.ts` | Whole file | Files are at 492 and 487 lines against the 500-line limit. | Plan a split before the next functional change to either file. | Low remaining headroom; the next edit is likely to require a refactor. | Reviewer `wc -l` |
| Non-blocking (F-6) | Evidence (`evidence/qa-gates/ts-*.2026-10-12T15-19.md`) | AC-7 records | AC-7 names `npm run lint`, `npm run typecheck`, `npm run test:coverage`. The evidence records the `npx` commands those scripts expand to, with a documented mapping. | No change required. In future plans, either allow `npm run` in the executor allowlist or phrase the AC in terms of the underlying commands. | Avoids a literal-wording mismatch between the AC and the evidence. The reviewer's own runs confirm exit 0. | `evidence/other/reduced-audit-handoff.2026-10-12T15-19.md` (mapping section) |

Blocking findings: 0. Non-blocking findings: 6.

## Verdict

**PASS.** The production change is correct and minimal, and the tests discriminate the behavior they target. No finding requires remediation before merge.
