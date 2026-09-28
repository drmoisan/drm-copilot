# Feature Audit: collector-core-no-whichgh-branch-untested (#714)

---

**Audit Date:** 2026-09-27
**Feature Folder:** `docs/features/active/collector-core-no-whichgh-branch-untested-714`
**Base Branch:** `origin/main`
**Head Branch:** `bug/collector-core-no-whichgh-branch-untested-714`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `daae7f79`)
- **Head branch/commit:** `bug/collector-core-no-whichgh-branch-untested-714` (commit `300d05e4`)
- **Merge base:** `daae7f79` — `git rev-list --left-right --count origin/main...HEAD` returns `0  12`, confirming `origin/main` is an ancestor of `HEAD` with no divergence (a clean rebase).
- **Evidence sources:**
  - Primary: `docs/features/active/collector-core-no-whichgh-branch-untested-714/spec.md` (Acceptance Criteria section)
  - Secondary baseline diff: `git diff origin/main...HEAD` (re-run directly during this audit)
  - Feature evidence: `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/**`
  - Additional evidence: `extensions/drm-copilot/coverage/lcov.info` (independently re-parsed), `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (read directly)
- **Feature folder used:** `docs/features/active/collector-core-no-whichgh-branch-untested-714`
- **Requirements source:** `spec.md` only, per work mode `full-bug`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug` explicitly (line 5), with a note that the underlying GitHub issue body originally carried `- Work Mode: minor-audit` but the orchestration kickoff for parallel run `followups-2026-09-27` selected `full-bug`, which is the persisted, authoritative mode for this branch. Per `.claude/skills/acceptance-criteria-tracking` and `.claude/skills/feature-review-workflow`, `full-bug` resolves the AC source to `spec.md` only; `user-story.md` is correctly not produced for this work mode (confirmed absent from the feature folder, and explicitly noted as intentional in `spec.md` D6).
- **Scope note:** `git diff origin/main...HEAD --name-status` (re-run during this audit) shows exactly 26 changed paths: 25 new files under the feature folder (`issue.md`, `spec.md`, plan, research, and 21 evidence artifacts) and exactly one production-tree path, `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (new). No path under `extensions/drm-copilot/src/` is changed. The local worktree `main` ref is stale relative to `origin/main` and was not used as the diff base for this reason (see policy-audit.2026-09-27T11-15.md, Scope Confirmation section, for the full staleness note).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/collector-core-no-whichgh-branch-untested-714/spec.md` — only source (work mode `full-bug`)

### Acceptance criteria

Transcribed verbatim from `spec.md`, lines 125-130:

1. A new Jest test in `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` calls `collectPrContext` with no `whichGh` option, so the `whichGh === undefined` arm of the `GhClient` construction in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` is executed.
2. The previously untaken outcome of the `whichGh === undefined ? {} : { whichGh }` conditional (located by the text anchor `whichGh === undefined`, not a fixed line number) is reported covered: every `BRDA` entry that `extensions/drm-copilot/coverage/lcov.info` records for that line of `collector-core.ts` reports a non-zero hit count. The v8 coverage provider records one tracked outcome for this ternary, with a Phase 0 baseline hit count of 0.
3. Branch coverage of `collector-core.ts` rises above the Phase 0 baseline measured on the same tree immediately before this change (expressed relative to that baseline, not the fixed 91.22% figure, because sibling issue #716 may independently change the file's branch count), and line coverage does not regress.
4. The new test in `collector-core-default-resolver.test.ts` is deterministic: it spawns no real `gh` process, touches no real filesystem, and does not depend on the host `PATH`, on `origin/main`, on gitignored state, or on Windows-only paths.
5. The full TypeScript toolchain (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`, all within `extensions/drm-copilot`) passes with no production code changes.

All five criteria are checkbox-based (`- [x]`) in `spec.md` and were already checked at the time of this audit.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | New test calls `collectPrContext` with no `whichGh` option, executing the `whichGh === undefined` arm | PASS | Direct read of the test file: the `collectPrContext({...})` call (lines 55-62) contains no `whichGh` key at all. `evidence/qa-gates/verify-new-test.2026-09-27T10-30.md` records the isolated run: exit 0, `Tests: 1 passed, 1 total`, 0.459 s. | `cd extensions/drm-copilot && npx jest --config jest.config.cjs test/lib/pr-context/collector-core-default-resolver.test.ts` | Verified by direct file read during this audit; no `whichGh: undefined` form is used, which is the only way to satisfy `options.whichGh === undefined` by absence under `exactOptionalPropertyTypes: true`. |
| 2 | Every `BRDA` entry for the anchor line reports a non-zero hit count | PASS | Anchor line independently re-located at line 136 (direct source read of `collector-core.ts`: `...(whichGh === undefined ? {} : { whichGh }),`). `extensions/drm-copilot/coverage/lcov.info` independently re-parsed during this audit, `SF:src\lib\pr-context\collector-core.ts` block: `BRDA:136,2,0,1` and `BRDA:136,3,0,52` — both non-zero. | `grep -n "SF:src.lib.pr-context.collector-core.ts" -A 60 extensions/drm-copilot/coverage/lcov.info` | See "BRDA Plural-Wording Discrepancy" below: the entry count grew from one (baseline) to two (post-change), a coverage-instrumentation artifact, not a defect. Both entries are non-zero, satisfying the criterion's plural wording. |
| 3 | Branch coverage of `collector-core.ts` rises above the Phase 0 baseline; line coverage does not regress | PASS | `evidence/qa-gates/coverage-delta-collector-core.2026-09-27T10-30.md`: branch coverage 90.3846% (baseline) -> 92.4528% (post-change), a strict increase; line coverage 98.4456% -> 98.4456% (unchanged). Independently re-derived from `lcov.info` during this audit: `LF:386`, `LH:380` in the current tree, matching the recorded baseline `LF`/`LH`. | (re-parse of `extensions/drm-copilot/coverage/lcov.info`, `SF:` block for `collector-core.ts`) | No production line in `collector-core.ts` changed (`git diff origin/main...HEAD -- extensions/drm-copilot/src/lib/pr-context/collector-core.ts` returns no output), so the branch-coverage increase is attributable solely to the new test exercising the previously-dead arm. |
| 4 | The new test is deterministic (no real `gh`, no real filesystem, no PATH/`origin/main`/gitignored-state dependency) | PASS | Direct read of the test file confirms: no `child_process` import, no `fs`/`node:fs` import, no `process.env` read, no `jest.mock`. Only in-memory fakes (`TreeFileSystem`, `RecordingRunner`) are used. | (direct file read; no command needed) | Confirmed independently during this audit by re-reading the full test file content. |
| 5 | Full TypeScript toolchain passes with no production code changes | PASS | `evidence/qa-gates/final-typescript-{prettier,lint,typecheck,test-coverage}.2026-09-27T10-30.md` all record `EXIT_CODE: 0`. `git diff origin/main...HEAD --name-status` (re-run during this audit) confirms zero changes under `extensions/drm-copilot/src/`. | `cd extensions/drm-copilot && npm run format`; `npm run lint`; `npm run typecheck`; `npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary` | All four commands and results independently corroborated against the evidence artifacts and, for the scope claim, against a fresh `git diff` run during this audit. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. None required for this feature. As a general housekeeping note independent of this audit's PASS verdict: confirm in the next CI run that repo-wide and `collector-core.ts` coverage figures remain consistent with the values recorded here, since sibling issue #716 may independently touch the same file (per `spec.md` D5).

### BRDA Plural-Wording Discrepancy — Confirmed Non-Issue

Two discrepancies flagged during plan execution were independently re-verified during this audit:

1. **Anchor-line shift, 135 -> 136.** The plan's Planner Internal Review Record (authored before the rebase onto `origin/main` at `daae7f79`) cited the conditional at line 135. After the rebase pulled in PR #720 (issue #716, the `compareCodePoint` deduplication), an import-block change shifted the conditional to line 136. This was caught by the plan's own anchor-discipline rule (locate by text, not fixed line number, per `spec.md` D5): `evidence/baseline/anchor-line.2026-09-27T10-30.md` records the corrected line. Independently re-verified during this audit by reading `collector-core.ts` directly: the ternary is at line 136, exact text `...(whichGh === undefined ? {} : { whichGh }),`. Consistent with `spec.md`'s own D5/Risk section, which anticipated exactly this scenario. Not a gap.

2. **BRDA entry count, one -> two.** The Phase 0 baseline recorded exactly one `BRDA:` entry for the anchor line (`BRDA:136,2,0,0`, hit 0). After the new test was added, the v8/istanbul instrumentation emits two entries for the same line (`BRDA:136,2,0,1` and `BRDA:136,3,0,52`), and the file's total branch count (`BRF`) rose from 52 to 53. Independently confirmed during this audit by re-parsing `lcov.info` directly. No production line in `collector-core.ts` changed between the two measurements, so the count change is attributable solely to the coverage instrumentation's response to the newly-exercised branch. `spec.md` AC2's wording is explicitly plural ("every `BRDA` entry ... reports a non-zero hit count"); both entries (hit counts 1 and 52) are non-zero, so the plural wording is satisfied. Not a gap.

### Sibling-Issue Independence (#716)

`spec.md` D5 documents this branch's dependency posture relative to sibling issue #716 (`compare-code-point-helper-duplicated`), which also touches `collector-core.ts`. Independently confirmed during this audit:
- `extensions/drm-copilot/src/lib/pr-context/models.ts` contains the sole definition of `compareCodePoint` (line 340: `export function compareCodePoint(...)`).
- `collector-core.ts` imports `compareCodePoint` (line 22, inside a multi-line import block) rather than redefining it, and uses it at lines 200-202 and 385.
- No duplicate `compareCodePoint` definition exists anywhere in `src/`.

This confirms issue #716's fix has already landed on `origin/main` (via PR #720, `daae7f79`) and that this branch's rebase correctly picked it up without reintroducing a duplicate.

### Baseline Comparison (`issue.md` vs. `spec.md`)

`issue.md` (the original bug report) states the coverage regression as 91.22% -> 89.28%, a fixed pre-#588-regression figure. `spec.md` D5 correctly supersedes this with a Phase-0-baseline-relative target (90.3846%, measured on this tree immediately before the change, per `evidence/baseline/collector-core-coverage-baseline.2026-09-27T10-30.md`) to avoid coupling the acceptance criteria to a percentage that sibling issue #716 could independently shift. The measured post-change branch coverage (92.4528%) exceeds both the fixed 91.22% figure from `issue.md` and the Phase 0 baseline, so the fix restores coverage above the originally-reported pre-regression level as well as satisfying the relative criterion.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### AC Status Summary

- Source: `docs/features/active/collector-core-no-whichgh-branch-untested-714/spec.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: None.

All five AC items were already checked `[x]` in `spec.md` at the time of this audit, and this audit independently re-verified each one as PASS. Per the acceptance-criteria-tracking skill, no further check-off action was required (items already PASS and already checked require no state change). No source-file checkbox change was made during this audit for that reason.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 5 | 5 | 0 | Checkbox-backed; sole authoritative source for `full-bug` work mode |
| `issue.md` | 5 | 0 | 5 | Checkbox-backed, but not authoritative for `full-bug` work mode (its AC items remain unchecked by design; `spec.md` supersedes it per D5) |
