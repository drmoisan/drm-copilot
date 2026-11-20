# Feature Audit: shared code-point string comparator consolidation (#796)

---

**Audit Date:** 2026-10-09
**Feature Folder:** `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796`
**Base Branch:** `main` (resolved `origin/main`)
**Head Branch:** `bug/duplicated-string-comparators-outside-pr-context-796`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `46dd56a8c2d6df15571f5f088ae2d677e5123b55`)
- **Head branch/commit:** `bug/duplicated-string-comparators-outside-pr-context-796` (commit `5d3caa21d5ed2b0224fa569b89ed0cddf875b313`)
- **Merge base:** `46dd56a8c2d6df15571f5f088ae2d677e5123b55`
- **Evidence sources:**
  - Primary: `git diff origin/main...HEAD` (95 files, +3145/-400), read directly by the reviewer
  - Secondary baseline diff: `git diff -U0 origin/main...HEAD -- extensions/drm-copilot/src` (exported to the session scratch directory for coverage mapping)
  - Feature evidence: `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/{baseline,regression-testing,qa-gates,other}/` (48 files), including the executor handoff `evidence/other/handoff.2026-10-09T23-30.md`
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info` (parsed, not regenerated); reviewer-run Prettier, ESLint, typecheck, Jest, and Python parity commands
- **Feature folder used:** `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` line 13 carries the explicit marker `- Work Mode: full-bug`; under that mode `spec.md` is the sole AC source and no `user-story.md` exists.
- **Scope note:** `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` are absent from this worktree and the MCP collector was not available to this session; the reviewer used the branch diff against the caller-supplied base directly. AC-9 is evaluated under the operator coverage standing decision recorded beneath AC-9 in `spec.md`; the reviewer also checked the stricter reading (Notes column).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/spec.md` — only source (`## Acceptance Criteria`, checkbox items AC-1..AC-10)

### Acceptance criteria

1. AC-1: Single definition. `extensions/drm-copilot/src/lib/string-ordering.ts` exists, exports `compareCodePoint(left: string, right: string): number`, and contains no `import` statement. Verified by: (a) `git grep -nE "function compareCodePoint|const compareCodePoint" -- extensions/drm-copilot/src` returns exactly one match, in `string-ordering.ts`; (b) `git grep -nE "\bcompareStrings\b|\bcompareOrdinal\b" -- extensions/drm-copilot/src` returns no matches; (c) `git grep -nE "^\s*import\b" -- extensions/drm-copilot/src/lib/string-ordering.ts` returns no matches.
2. AC-2: No remaining ordinal string comparator copies. The research primary query `rg -n "(\?\s*1\s*:\s*-1|return\s+-1|\?\s*-1\b)" extensions/drm-copilot/src`, together with the multiline query `rg -nU "if\s*\([^()]*\s<\s[^()]*\)\s*\{?\s*return\s+-1" extensions/drm-copilot/src`, returns matches only in `src/lib/string-ordering.ts` or at the numeric-comparator sites enumerated in research section 1.5. Each of the 24 inventoried sites (N1-N6, I1-I16, G1, G2) and `pr-context/collector-output.ts:112-118` calls `compareCodePoint` imported from the shared module.
3. AC-3: Direct imports, no re-export. Every production import of `compareCodePoint` under `extensions/drm-copilot/src` resolves to `string-ordering` (`git grep -n "compareCodePoint" -- extensions/drm-copilot/src` shows every `import` line referencing a `string-ordering` path), `pr-context/models.ts` neither defines nor re-exports it, and the `models.ts` module header no longer lists it.
4. AC-4: Shared comparator unit tests. `extensions/drm-copilot/test/lib/string-ordering.test.ts` passes and contains named tests covering: equal strings (returns 0); empty and proper-prefix strings (prefix sorts first); BMP-only ordering; a supplementary character versus U+E000 and versus U+FFFF (supplementary sorts last); results restricted to -1, 0, 1; antisymmetry; and enumerative reflexive/antisymmetric/transitive checks over a fixed domain that includes a lone high surrogate, a lone low surrogate, a high surrogate followed by U+E000, U+E000, U+FFFF, and a supplementary character. The domain includes the research triple and the transitivity check passes on it. A test also asserts that, for well-formed strings in the domain, the result equals the order of their code-point sequences.
5. AC-5: Consumer regression tests. At least one named test per consumer module family passes and asserts code-point order on a supplementary-versus-U+E000..U+FFFF input through the consumer's own function: codex-native-converter, push-down, subagent-tree (`compareByAgentId` and the `compareCandidates` path tiebreak), and pr-context (`renderVerificationEvidenceSection`). Fail-first evidence showing each new consumer test failing against the pre-change code is recorded under the feature folder's `evidence/` tree.
6. AC-6: No expected-output changes. All pre-existing Jest tests in `extensions/drm-copilot` pass, and `git diff <base>...HEAD -- extensions/drm-copilot/test tests/fixtures` shows no modified expected value in any pre-existing assertion or fixture; the only removals are the `compareCodePoint` describe blocks moved out of `test/lib/pr-context/models.test.ts`. `test/lib/push-down/claude-blast-radius-overlay-parity.test.ts` and `tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py` pass unchanged.
7. AC-7: Coverage configuration. `extensions/drm-copilot/jest.config.cjs` `coverageThreshold` contains `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }`.
8. AC-8: Full TypeScript toolchain passes in a single pass from `extensions/drm-copilot`: `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:coverage` complete without errors and without auto-fixing files.
9. AC-9: Coverage targets. The `npm run test:coverage` report shows line coverage >= 85% and branch coverage >= 75% for `src/lib/string-ordering.ts` and for every changed production file, and no changed file's line or branch coverage is lower than its baseline captured before the change. (Spec note beneath AC-9 records the coordinator standing decision of 2026-10-09: the no-decrease clause is satisfied when every changed file is >= 85% lines and >= 75% branches and no instrumented changed line is uncovered.)
10. AC-10: File size and test location. No production or test file added or changed by this work exceeds 500 lines, and every added test file is under `extensions/drm-copilot/test/`, mirroring the `src/` path of the module under test.

Items 4, 5, 6, and 9 are abbreviated here for length; the full text is in `spec.md` lines 308-314 and was evaluated in full.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 Single definition | PASS | (a) one match `src/lib/string-ordering.ts:53`; (b) no match in `src` (and none in `test`); (c) no match. Signature `compareCodePoint(left: string, right: string): number` confirmed by diff. | `git grep -nE "function compareCodePoint\|const compareCodePoint" -- extensions/drm-copilot/src`; `git grep -nE "\bcompareStrings\b\|\bcompareOrdinal\b" -- extensions/drm-copilot/src extensions/drm-copilot/test`; `git grep -nE "^\s*import\b" -- extensions/drm-copilot/src/lib/string-ordering.ts` | Reviewer run; exit codes 0, 1, 1. A repo-wide search outside `docs/features/` also found no `compareOrdinal` or `compareStrings`. |
| 2 | AC-2 No remaining copies | PASS | Primary query: 4 lines: `string-ordering.ts:59`, `string-ordering.ts:65`, `validate/orchestration-handoff-contract.ts:149` (`?? -1` default), `subagent-tree/quick-pick-labels.ts:130` (numeric `rightMs === undefined` branch). Multiline query: no matches. Diff inspection confirms each of N1-N6, I1-I16, G1, G2 and `collector-output.ts:114` now calls `compareCodePoint` imported from `../string-ordering`. | Grep tool with the two spec patterns over `extensions/drm-copilot/src`; supplementary search `(\?\s*1\s*:\s*0\|\?\s*-1\s*:\|:\s*-1\s*;)` | The two non-shared-module hits are not string comparators. Supplementary search found only `string-ordering.ts` and a numeric exit-code ternary in `cli.ts:241`. |
| 3 | AC-3 Direct imports, no re-export | PASS | Every `import` of `compareCodePoint` in `src` (26 files) references `"../string-ordering"`; no `export { compareCodePoint }` anywhere; `models.ts` imports it for `sortedSet` only; header (lines 19-21) lists `splitLines`, `sortedSet`, `escapeRegExp` only. | `git grep -n "compareCodePoint" -- extensions/drm-copilot/src extensions/drm-copilot/test` | Typecheck exit 0 confirms resolution. |
| 4 | AC-4 Shared comparator unit tests | PASS | `test/lib/string-ordering.test.ts`: identical returns 0; empty and prefix; BMP `a`/`b`, case; D2 (U+E000 vs U+10000) and D1 (U+FFFF vs U+1F600); range test; antisymmetry; enumerative reflexive/antisymmetric/transitive over a domain containing `\uD800`, `\uDC00`, `\uD800`, ``, `￿`, `😀`, `\u{10000}`; research-triple cycle test; well-formed code-point-sequence equivalence test. Fail-before (uncorrected moved implementation): 2 failed (transitivity, cycle). | `npm --prefix extensions/drm-copilot test -- test/lib/string-ordering.test.ts ...` (reviewer run, part of 1068 passing tests) | The spec triple (byte-checked: `"\u{10000}"`, `"\uD800"` followed by U+E000, U+E000) matches the domain entries and the test constants. |
| 5 | AC-5 Consumer regression tests | PASS | Six `issue #796` tests: `normalizeSelectedPaths` (inventory.test.ts), `classifyProjectDirectories` (blast-radius-derive-manifests.test.ts), `stringifySorted` (copilot-customizations-engine.test.ts), `compareByAgentId` via `assembleTree` (tree-assembler.test.ts), `compareCandidates` tiebreak via `buildRootSessionPickEntries` (quick-pick-labels.test.ts), `renderVerificationEvidenceSection` (collector-output-ordering.test.ts). Fail-before artifacts: `evidence/regression-testing/fail-before-{inventory,derive-manifests,copilot-engine,tree-assembler,quick-pick-labels,collector-output}.*.md`; pass-after `pass-after-consumers.2026-10-09T22-22.md`. | Reviewer Jest run over the five affected trees (all pass); reviewer read of the six test bodies and fail-before artifacts | Each test asserts a literal expected order through the consumer's own function. |
| 6 | AC-6 No expected-output changes | PASS | Modified pre-existing test files other than `models.test.ts` show additions only (reviewer `git diff --diff-filter=M -U0`). `models.test.ts`: 0 added, 222 removed, consisting of the `compareCodePoint,` import member and the three `compareCodePoint` describe blocks. No path under `tests/fixtures` changed. Executor full suite 3945/3945 pass. TS parity suite passed (reviewer run); Python parity 4/4 passed (reviewer run). | `git diff --diff-filter=M --stat origin/main...HEAD -- extensions/drm-copilot/test tests/fixtures`; `git diff -U0 ... models.test.ts`; `poetry run pytest -q tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py` | Removal of the import member accompanies the moved blocks; it is not an expected-value change. |
| 7 | AC-7 Coverage configuration | PASS | `jest.config.cjs` diff adds `"./src/lib/string-ordering.ts": { lines: 85, branches: 75 }`. | `git diff origin/main...HEAD -- extensions/drm-copilot/jest.config.cjs` | |
| 8 | AC-8 Full TypeScript toolchain | PASS | Executor pass 2: `npm run format` with every file `(unchanged)` and identical porcelain before/after; lint, typecheck, test:coverage exit 0 (264 suites, 3945 tests). Reviewer at HEAD: Prettier check exit 0, lint exit 0, typecheck exit 0, affected Jest trees pass. | `npm --prefix extensions/drm-copilot exec -- prettier --check ...`; `npm --prefix extensions/drm-copilot run lint`; `npm --prefix extensions/drm-copilot run typecheck` | The reviewer did not re-run `test:coverage` (contract: inspect existing artifact). |
| 9 | AC-9 Coverage targets | PASS | All 27 changed production files >= 85% lines and >= 75% branches (lowest line 87.08% render-pr-helpers.ts; lowest branch 84.78% engine-pipeline.ts); `string-ordering.ts` 100%/100%; 0 of 168 added executable lines uncovered. Reviewer reproduction matches `evidence/qa-gates/coverage-delta.2026-10-09T23-14.md` row for row. | `node <scratch>/cov.js extensions/drm-copilot/coverage/lcov.info <scratch>/src.diff` | Passes under the standing decision. Under the literal no-decrease wording, five files show a lower percentage (four on lines, validation.ts on branches), but each has the same count of uncovered lines or branches as at baseline, so no changed-line regression exists. |
| 10 | AC-10 File size and test location | PASS | Largest added or changed file under `src`, `test`, and `jest.config.cjs`: `collector-output.ts` 491 lines. All 7 added test files are under `extensions/drm-copilot/test/lib/<subsystem>/`, mirroring the `src/lib/<subsystem>/` directory of the module under test. | `git diff --name-only --diff-filter=AM origin/main...HEAD -- extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/jest.config.cjs` piped to `wc -l` | `reporting-coverage.test.ts` and `collector-output-ordering.test.ts` use suffixed file names in the mirrored directory; the latter is named by the spec. Recorded as a code-review Nit. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 10 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, confirm the PR CI run (`ci.yml`) is green at the merge head, which re-runs `test:coverage` on Linux.
2. Address the non-blocking test gaps from `code-review.2026-10-09T21-56.md` (null-path tie branches; role-order assertion in `engine-pipeline.test.ts`) and the argument-less `.sort()` follow-up recorded in `spec.md`.

Blocking findings: 0.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file if they are markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All ten AC items in `spec.md` were already checked (`- [x]`) by the executor in commit `5d3caa21d`. The reviewer evaluated each independently as PASS, so all ten remain checked. The reviewer made no change to `spec.md` and added no criteria.

### AC Status Summary

- Source: `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/spec.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/spec.md` | 10 | 10 | 0 | Checkbox-backed; already checked by executor; confirmed by reviewer |
