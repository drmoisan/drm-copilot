# Feature Audit — collect-pr-context-explicit-target (Issue #675)

- Reviewer: feature-review agent
- Date: 2026-09-17
- Work mode: `full-bug` (from `issue.md`: `Work Mode: full-bug`) — AC source is `spec.md` only, per `.claude/skills/acceptance-criteria-tracking/SKILL.md`. `user-story.md` does not exist for this feature and is correctly not referenced.
- AC source file: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md`, section `## Acceptance Criteria` (lines 428-485).

## Scope and Baseline

- **Base branch:** `epic/worktree-scoped-state-resolution-integration` (via feature branch merge-base `79fd5a95c00cd99238b69a3195788206ae96f4cd`)
- **Head branch/commit:** `feature/2026-09-13-collect-pr-context-explicit-target-675` (commit `b873778fb5035fd73b01bef82f166e12fab19dee`)
- **Merge base:** `79fd5a95c00cd99238b69a3195788206ae96f4cd` (current); plan/spec originally cited `499e288ae85b1e8923ae62ab9c4313ad0cdbaa40`, independently confirmed still a valid ancestor of HEAD and to produce an identical result for every check in this feature's scope — see Reported Deviations item 1 below.
- **Evidence sources:**
  - Primary: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/qa-gates/final-jest-coverage.2026-09-13T20-49.md`
  - Secondary baseline diff: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/baseline/phase0-jest-coverage.2026-09-13T20-49.md`
  - Feature evidence: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/**` (baseline, qa-gates, regression-testing, issue-updates)
  - Additional evidence: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/evidence/qa-gates/coverage-delta.2026-09-13T20-49.md`
- **Feature folder used:** `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** Determined from `issue.md` metadata marker `Work Mode: full-bug`, per the `full-bug` rule in `.claude/skills/acceptance-criteria-tracking/SKILL.md` (spec.md is the sole AC source; `user-story.md` is correctly absent).
- **Scope note:** Full-branch review against the current epic-integration merge-base; no working-tree-only or versioned-feature-scope assumption applies.

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md` — only source (heading-scoped `## Acceptance Criteria` section)

### Acceptance criteria (grouped as spec.md presents them)

**Schema and input resolution (4):** both tool-definition surfaces declare `target_ref` with `required` unchanged; the cross-surface schema-parity test exists and passes; `resolveCollectPrContextToolInput` resolves a supplied `target_ref` and omits it when absent; an empty/whitespace/non-string `target_ref` is rejected naming `target_ref` in the error.

**Explicit target reaches git (2):** the explicit target ref reaches the underlying `git` invocation rather than the session HEAD; the service-call result reports `target_resolution: explicit` with the resolved head ref and sha.

**Fallback is observable, not silent (3):** the service-call result reports `target_resolution: session-fallback` when no target is supplied; the rendered summary's `Head ref (source):` line appears after `Head ref (resolved):` and distinguishes the explicit and fallback cases; the MCP dispatch result projects `target_resolution` and the resolved head fields.

**Empty diff fails loudly (6):** `diff-emptiness.ts` exports `classifyPrContextDiffState`; a table-driven test suite covers all state-classification mechanisms; the service call raises naming the resolved head ref/sha/merge base/base on the refs-resolved-no-change state; it raises naming the requested base on the refs-unresolved state with a distinct message; it writes both artifacts before raising on an empty diff; the dispatch layer returns `ok: false` with the empty-diff failure text.

**No regression (4):** no test was deleted from the five repaired suites; the four named pre-existing guard tests in `pr-context-service-call.test.ts` still pass; the two named pre-existing guard tests in the dispatch-verification suite still pass; no file under `.claude/` or `extensions/drm-copilot/resources/` was modified.

**Policy gates (7):** `diff-emptiness.ts` has a `coverageThreshold` entry and every other in-scope production file already has or retains one; no `coveragePathIgnorePatterns` key and `collectCoverageFrom` unchanged; no changed/added non-Markdown file exceeds 500 lines; no `: any`/`as any` introduced; no banned determinism construct introduced; the full toolchain passes in a single uninterrupted pass; toolchain evidence lives under the canonical `evidence/` tree only.

**Documented limitation (1):** `diff-emptiness.ts`'s doc comment records the wrong-target-with-commits-ahead limitation and the `workspace_root`-scoping limitation.

Total: 27 acceptance criteria across 7 groups, matching the heading-scoped count in spec.md's `## Acceptance Criteria` section (see AC Count Reconciliation below for why this differs from spec.md's own whole-document Status-line figure).

## AC Count Reconciliation (see policy-audit for full detail)

spec.md's Status line (line 7) states "31 of 31 acceptance criteria checked off." Independently counted, the heading-scoped `## Acceptance Criteria` section (from `## Acceptance Criteria` to the next `##` heading, `## Risks & Mitigations`) contains **27** checkbox items, all checked. The "31 checked / 4 unchecked / 35 total" figures in spec.md's Status line and in plan.md's Phase 9 preamble are a **whole-document** checkbox tally that also includes the "Impact/Severity: High" radio marker (1) and the three seeded Test-Strategy checkboxes (3), none of which are acceptance criteria under the `minor-audit`/`full-bug` heading rule. This is a wording imprecision in spec.md's own summary sentence, not a miscount of substance: every one of the 27 actual AC items is present, checked, and independently verified below. The 4 unchecked lines in the whole document (`- [ ] Blocker`, `- [ ] Medium`, `- [ ] Low`, `- [ ] Attached minimal logs or screenshot`) are confirmed to sit in the `## Repro & Evidence`/`Impact/Severity` template sections, outside the `## Acceptance Criteria` heading span, and are pre-existing bug-report-template radio-markers, not acceptance criteria. This characterization from the delegation prompt is **verified accurate**.

## Acceptance Criteria Evaluation Table

| # | Group | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- | --- |
| 1 | Schema and input resolution | Both definition surfaces declare `target_ref`; `required` unchanged | PASS | `grep -c target_ref` = 1 on both files (independently reproduced); `required: ["workspace_root", "base"]` unchanged at line 56 of `mcp-tool-definitions.ts` and the corresponding entry in `mcp-repo-automation-tool-definitions.ts` |
| 2 | Schema and input resolution | Parity test `declares the same input-schema properties and required arrays on both tool-definition surfaces` exists and passes | PASS | Test found in `test/mcp-repo-automation-tool-definitions.test.ts`, derives keys dynamically (no hard-coded property list); included in the 3011/3011 passing run |
| 3 | Schema and input resolution | `resolves target_ref when supplied and omits it when absent` exists and passes | PASS | Found in `test/mcp-tool-inputs.test.ts` line 276; asserts both the supplied and the absent case |
| 4 | Schema and input resolution | `rejects an empty target_ref instead of treating it as absent` exists and passes | PASS | Found at line 297; covers empty string, whitespace-only, and non-string (`42`), asserting the error names `target_ref` |
| 5 | Explicit target reaches git | `passes the explicit target ref to git rather than the session HEAD` exists and passes | PASS | Found in `test/lib/pr-context/pr-context-service-call-target.test.ts`; asserts the argv contains the explicit ref and does not contain the session branch name |
| 6 | Explicit target reaches git | `reports target_resolution explicit and the resolved head ref and sha...` exists and passes | PASS | Same file; asserts `targetResolution === "explicit"`, `resolvedHeadRef`, `resolvedHeadSha` |
| 7 | Fallback is observable | `reports target_resolution session-fallback when no target ref is supplied` exists and passes | PASS | Same file; asserts `"session-fallback"` and presence of resolved ref/sha |
| 8 | Fallback is observable | Both `renders Head ref (source)...` tests exist and pass, asserting position after `Head ref (resolved):` and distinguishable text | PASS | Found in `test/lib/pr-context/collector-output-head-source.test.ts` (128 lines); `renderHeadRefSourceLine` in `summary-helpers.ts` is called immediately after the `Head ref (resolved):` line is constructed in `buildBaseHeadSection`'s fixed array |
| 9 | Fallback is observable | `projects target_resolution and the resolved head onto the dispatch result` exists and passes | PASS | Found in `test/repo-automation-dispatch-pr-context-verification.test.ts`; asserts the three snake_case fields on the dispatch result |
| 10 | Empty diff fails loudly | `diff-emptiness.ts` exists and exports `classifyPrContextDiffState` | PASS | `grep -c "export function classifyPrContextDiffState"` = 1 (independently reproduced) |
| 11 | Empty diff fails loudly | `diff-emptiness.test.ts` exists and passes with >=1 test per each of the four mechanisms | PASS | File contains 6 tests covering refs-unresolved (base-unresolved and head-unresolved variants), merge-base-equals-head-sha, unequal-with-no-change, and populated |
| 12 | Empty diff fails loudly | `raises naming the resolved head ref, head sha, merge base and base...` exists and passes | PASS | Found in `pr-context-service-call-target.test.ts`; asserts a regex matching all four values in order |
| 13 | Empty diff fails loudly | `raises naming the requested base when the base or head could not be resolved` exists and passes, message differs from the empty-diff message | PASS | Same file; explicitly asserts `unresolvedMessage !== noChangeMessage` |
| 14 | Empty diff fails loudly | `writes both artifacts and then raises when the diff is empty` exists and passes | PASS | Same file; asserts `writtenPaths` contains both artifact paths after the throw |
| 15 | Empty diff fails loudly | `returns ok false with the empty-diff failure text when the collected diff is empty` exists and passes | PASS | Found in `repo-automation-dispatch-pr-context-verification.test.ts`; asserts `ok === false` and summary contains "PR context diff is empty" |
| 16 | No regression | No existing test deleted from the five repaired suites | PASS | `git diff 499e288a HEAD -- <5 files>` independently reproduced: 0 removed `it(` lines, 0 `deleted file mode` lines |
| 17 | No regression | Four named pre-existing tests in `pr-context-service-call.test.ts` still pass | PASS | Included in the 3011/3011 passing run; file structure confirms all four test names still present |
| 18 | No regression | Two named pre-existing tests in the dispatch-verification suite still pass | PASS | Included in the 3011/3011 passing run |
| 19 | No regression | No file under `.claude/` or `extensions/drm-copilot/resources/` modified/added/deleted | PASS | `git diff --name-only 79fd5a95 HEAD -- .claude extensions/drm-copilot/resources` and `git status --porcelain -- .claude extensions/drm-copilot/resources` both independently reproduced empty |
| 20 | Policy gates | `jest.config.cjs` has a `coverageThreshold` entry for `diff-emptiness.ts` (85/75) and for every other in-scope non-interface production file | PASS | Entry confirmed present with `lines: 85, branches: 75`; all other changed production files (`pr-context-service-call.ts`, `collector-output.ts`, `summary-helpers.ts`, `mcp-tool-inputs.ts`, `mcp-tools.ts`, `mcp-tool-definitions.ts`, `mcp-repo-automation-tool-definitions.ts`, `repo-automation-service.ts`) already carried entries pre-change; `repo-automation-service-contract.ts` and `index.ts` are documented interface-only/barrel exemptions, both still inside `collectCoverageFrom` |
| 21 | Policy gates | No `coveragePathIgnorePatterns` key; `collectCoverageFrom` unchanged | PASS | `grep -c "coveragePathIgnorePatterns"` = 0 (independently reproduced); `collectCoverageFrom` = `["src/**/*.ts", "!src/**/*.d.ts"]` |
| 22 | Policy gates | No non-Markdown changed/added file exceeds 500 lines | PASS | Independently measured `wc -l` on every changed production and test file; largest is `repo-automation-service.ts` at 498, `collector-output.ts` at 494, `mcp-tool-inputs.ts` at 483, `test/mcp-tool-inputs.test.ts` at 495 — all within cap |
| 23 | Policy gates | No `: any` or `as any` introduced under `src/` | PASS | Independently grepped, both the anchored diff and the created files — zero matches |
| 24 | Policy gates | No banned determinism construct (`setTimeout`, `Date.now(`, `mkdtemp`, `tmpdir`) introduced under `src/` or `test/` | PASS | Independently grepped, both the anchored diff and the created files — zero matches |
| 25 | Policy gates | Full toolchain (prettier, eslint, tsc, jest+coverage) passes in a single pass | PASS | Independently re-executed all four stages; all exit 0; jest reports 220/220 suites, 3011/3011 tests, 0 failed; figures identical to the executor's report |
| 26 | Policy gates | Toolchain evidence written under `evidence/` (canonical `baseline` singular), none under non-canonical `artifacts/` paths | PASS | `evidence/baseline/` and `evidence/qa-gates/` populated with numeric, non-placeholder values (spot-checked); `python validate_evidence_locations.py --root .` exits 0; branch diff/status scan for `artifacts/{baselines,qa,evidence,coverage}/` finds nothing |
| 27 | Documented limitation | `diff-emptiness.ts`'s doc comment records the wrong-target-with-commits-ahead limitation and the `workspace_root`-scoping limitation | PASS | Confirmed by direct inspection of the module doc comment (lines 20-29 of `diff-emptiness.ts`) |

**All 27 acceptance criteria: PASS.** No PARTIAL, FAIL, or UNVERIFIED items.

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 27 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional, non-blocking: reword spec.md's Status-line AC count from the whole-document tally ("31 of 31") to the heading-scoped count (27/27) in a follow-up documentation edit.
2. Optional, non-blocking: update the stale `LF:115` line-count figure in the `jest.config.cjs` `index.ts` exemption comment to the current `LF:123`.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md` (`## Acceptance Criteria` heading section)
- Total AC items: 27
- Checked off (delivered): 27
- Remaining (unchecked): 0
- Items remaining: none

Per the acceptance-criteria-tracking skill's check-off protocol: all 27 items evaluated as PASS above were **already checked `[x]`** in spec.md prior to this review; no new check-off was required or performed. The 4 unchecked lines elsewhere in spec.md (`- [ ] Blocker`, `- [ ] Medium`, `- [ ] Low`, `- [ ] Attached minimal logs or screenshot`) are confirmed non-AC template markers in the `## Repro & Evidence` section and are correctly left unchecked; they are not part of the AC count and require no action.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules: all 27 criteria evaluated as PASS above were already checked `[x]` in `spec.md` prior to this review; none required a new check-off during this audit pass.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md` | 27 | 27 | 0 | Checkbox-backed, sole authoritative AC source for this `full-bug` feature |

No source-file checkbox change was made during this review: all 27 acceptance criteria were already checked off by the atomic-executor during plan execution (per the acceptance-criteria-tracking skill's "check off as soon as the corresponding task passes" timing rule), and this audit independently confirmed each check-off against concrete evidence rather than performing any new check-off itself.

## Reported Deviations — Evaluation

1. **P0-T8 diff-anchor mismatch.** Evaluated as **acceptable, no remediation required**. Independently re-derived: `499e288a` remains a valid ancestor of HEAD, and the 20 commits added to the integration branch between plan authoring and execution touch only `docs/features/**` paths, none of which intersects this feature's inspected scope (`extensions/drm-copilot/src`, `extensions/drm-copilot/test`, `.claude`, `extensions/drm-copilot/resources`). Both anchors produce identical results for every acceptance criterion. The deviation is transparently documented in `evidence/baseline/phase0-diff-anchor.2026-09-13T20-49.md` and left correctly unchecked in plan.md rather than being silently marked complete.
2. **`collector-output.ts` extraction timing (Phase 2 vs. Phase 3 text).** Evaluated as **acceptable, correctly applied**. `collector-output.ts` measures 494 lines (within the 500-line cap); `buildBaseHeadSection` and `renderHeadRefSourceLine` are confirmed present in `summary-helpers.ts` (460 lines, within cap), matching spec.md's pre-authorized fallback text verbatim ("moving the `collectPrContext` input type to `repo-automation-service-contract.ts`... An extraction is expected to be required there"; R8's mitigation naming `summary-helpers.ts` explicitly). The extraction landing in the Phase 2 commit rather than a later Phase 3 slot is a sequencing detail with no functional or policy consequence — the plan's own task list is guidance for delivery order, and the acceptance criteria (file-line-count based) are satisfied regardless of which commit performed the extraction.
3. **`resolvedBase` fifth field on `CollectAndWriteResult`.** Evaluated as **acceptable, narrowly scoped**. Traced to a pre-existing `PrContextResult.resolvedBase: string | null` field already computed by unchanged code (`collector-core.ts`, `models.ts` — both zero-diff against `79fd5a95`). The addition introduces no new git call, no new parsing logic, and no untyped escape hatch (confirmed by the zero-`any` scan and the passing `tsc --noEmit`). It is used in exactly one place, the refs-resolved-no-change error message, consistent with the feature's stated intent of making the empty-diff failure message actionable.
4. **Two pre-existing test-fake bugs fixed in Phase 6.** Evaluated as **acceptable, correctly scoped**. Root cause independently confirmed in `src/lib/subprocess-runner.ts` (stdout decoded only `instanceof Buffer`). The fix supplies `Buffer.from(...)` for the two diff subcommands in the two affected files only, does not alter any assertion, and matches the pattern already established elsewhere in the suite. It does not mask any other defect: the two files drive the in-process collector through `SubprocessRunner` specifically, and the sibling branch-discovery fakes in the same files (which use a different runner and were not affected by this bug) were correctly left untouched.

## Toolchain and Coverage — Independently Verified

See `policy-audit.2026-09-17T12-57.md` for full detail. Summary: prettier, eslint, and tsc all independently re-run and confirmed exit 0 with zero findings; jest independently re-run and confirmed 220/220 suites, 3011/3011 tests, 0 failed, Statements/Lines 96.85%, Branches 90.55%, Functions 90.57% — identical to the executor's reported figures. Per-file coverage for every new/modified production TypeScript file independently computed from `coverage/lcov.info` and cross-checked against `evidence/qa-gates/coverage-delta.2026-09-13T20-49.md`; all values matched exactly and all files clear the 85% line / 75% branch gates.

## Overall Feature-Audit Verdict

**PASS — ready to merge.** All 27 acceptance criteria are satisfied and independently verified. All four reported deviations are acceptable and correctly documented. No blocking finding was identified in this review or in the accompanying policy-audit and code-review artifacts. The three advisory (non-blocking) findings — spec.md's imprecise whole-document AC count in its Status line, a stale line-count figure in a `jest.config.cjs` comment, and a slightly generic validation-error wording — do not affect delivered behavior, test coverage, or the correctness of any acceptance criterion, and do not require remediation before merge.
